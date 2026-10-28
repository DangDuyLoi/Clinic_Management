<?php

namespace App\Http\Controllers;

use App\Models\LuotKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Exception;
use Carbon\Carbon;
use App\Jobs\SendBookingEmailJob; // Thư viện để chạy Queue gửi Email (Bước 4)
use App\Services\FCMService;
use App\Models\User;
use Illuminate\Support\Facades\Log;


class LuotKhamController extends Controller
{
    // 1. API Lễ tân: Tiếp nhận bệnh nhân (Chuyển trạng thái sang "Chờ khám")
    public function tiepNhan(Request $request, $id)
    {
        $luotKham = LuotKham::find($id);
        if (!$luotKham) {
            return response()->json(['message' => 'Không tìm thấy lượt khám'], 404);
        }

        $luotKham->update(['trang_thai' => 'cho_kham']);

        // Gửi thông báo đẩy FCM cho bệnh nhân
        try {
            $hoSo = DB::table('ho_so_benh_an')->where('ma_ho_so', $luotKham->ma_ho_so)->first();
            if ($hoSo) {
                $phone = $hoSo->so_dien_thoai;
                if (empty($phone) && !empty($hoSo->ma_benh_nhan)) {
                    $bn = DB::table('benh_nhan')->where('ma_benh_nhan', $hoSo->ma_benh_nhan)->first();
                    $phone = $bn?->so_dien_thoai;
                }

                if ($phone) {
                    $phone0 = str_starts_with($phone, '+84') ? '0' . substr($phone, 3) : $phone;
                    $phone84 = str_starts_with($phone, '0') ? '+84' . substr($phone, 1) : $phone;

                    $user = User::whereIn('phone_number', [$phone, $phone0, $phone84])->first();

                    if ($user && !empty($user->fcm_token)) {
                        $thoiGian = Carbon::parse($luotKham->thoi_gian_den_kham)->format('H:i d/m/Y');
                        FCMService::sendNotification(
                            $user->fcm_token,
                            '🎉 Check-in thành công!',
                            "Lượt khám #{$luotKham->ma_luot_kham} ({$thoiGian}) đã được tiếp nhận tại quầy lễ tân. Vui lòng chuẩn bị vào phòng khám khi có thông báo.",
                            [
                                'type' => 'checkin_success',
                                'ma_luot_kham' => (string)$luotKham->ma_luot_kham,
                                'trang_thai' => 'cho_kham'
                            ]
                        );
                        Log::info("Đã gửi FCM checkin_success cho lượt khám #{$luotKham->ma_luot_kham}");
                    } else {
                        Log::info("Không tìm thấy fcm_token cho user số ĐT: {$phone}");
                    }
                }
            }
        } catch (\Exception $e) {
            Log::error('Lỗi khi gửi FCM tiếp nhận: ' . $e->getMessage());
        }

        // Nếu mở từ trình duyệt (quét mã QR bằng camera điện thoại/máy quét)
        if (!$request->wantsJson() && !str_contains($request->header('Accept', ''), 'application/json')) {
            $hoTen = (isset($hoSo) && $hoSo) ? ($hoSo->ho_chu_lot . ' ' . $hoSo->ten) : 'Bệnh nhân';
            $thoiGian = Carbon::parse($luotKham->thoi_gian_den_kham)->format('H:i d/m/Y');
            return response()->view('checkin_success', [
                'luotKham' => $luotKham,
                'hoTen' => $hoTen,
                'thoiGian' => $thoiGian,
            ]);
        }

        return $this->successResponse($luotKham, 'Đã tiếp nhận bệnh nhân, chuyển vào hàng đợi chờ khám.');
        return response()->json([
            'message' => 'Đã tiếp nhận bệnh nhân, chuyển vào hàng đợi chờ khám.',
            'data' => $luotKham
        ], 200);
    }

    // 2. API Bác sĩ: Cập nhật chẩn đoán, lời khuyên và kê đơn thuốc (MỚI)
    public function capNhatKetQua(Request $request, $id)
    {
        $luotKham = LuotKham::find($id);

        if (!$luotKham) {
            return response()->json(['message' => 'Không tìm thấy lượt khám'], 404);
        }

        if ($luotKham->trang_thai === 'hoan_thanh') {
            return response()->json(['message' => 'Lượt khám này đã được xử lý xong'], 400);
        }

        // Validate cơ bản
        $validator = Validator::make($request->all(), [
            'chan_doan' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Dữ liệu không hợp lệ', 'errors' => $validator->errors()], 422);
        }

        // Cập nhật thông tin chẩn đoán
        $luotKham->update([
            'chan_doan' => $request->input('chan_doan'),
            'loi_khuyen' => $request->input('loi_khuyen'), // Thêm lời khuyên
            'trang_thai' => 'hoan_thanh'
        ]);

        // Xử lý kê đơn thuốc (nếu bác sĩ có gửi mảng don_thuoc lên)
        $danhSachThuoc = $request->input('don_thuoc');

        if (is_array($danhSachThuoc) && count($danhSachThuoc) > 0) {
            // Tạo 1 record đơn thuốc chung
            $donThuocId = DB::table('don_thuoc')->insertGetId([
                'luot_kham_id' => $id,
                'ghi_chu' => 'Đơn thuốc cho lượt khám ' . $id,
                'created_at' => now(),
                'updated_at' => now()
            ]);

            // Thêm từng loại thuốc vào chi tiết đơn thuốc
            foreach ($danhSachThuoc as $thuoc) {
                DB::table('chi_tiet_don_thuoc')->insert([
                    'don_thuoc_id' => $donThuocId,
                    'ten_thuoc' => $thuoc['ten_thuoc'] ?? 'Chưa rõ',
                    'so_luong' => $thuoc['so_luong'] ?? 1,
                    'cach_dung' => $thuoc['cach_dung'] ?? '',
                    'created_at' => now(),
                    'updated_at' => now()
                ]);
            }
        }

        return response()->json([
            'message' => 'Lưu kết quả khám và đơn thuốc thành công!',
            'luot_kham_id' => $id
        ], 200);
    }

    // 3. API Bệnh nhân: Đặt lịch khám (Có xử lý Race Condition & Validation nâng cao)
    public function datLich(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ma_ho_so' => 'required|integer',
            'ma_bac_si' => 'required|integer',
            'thoi_gian_den_kham' => 'required|date_format:Y-m-d H:i:s|after:now',
        ], [
            'thoi_gian_den_kham.after' => 'Thời gian khám phải lớn hơn thời gian hiện tại.',
            'thoi_gian_den_kham.date_format' => 'Định dạng thời gian không hợp lệ (Chuẩn: YYYY-MM-DD HH:MM:SS).'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Dữ liệu không hợp lệ',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $result = DB::transaction(function () use ($request) {
                // Tự động giải phóng các lượt khám chưa thanh toán quá 15 phút
                LuotKham::where('trang_thai', 'cho_thanh_toan')
                    ->where('created_at', '<=', Carbon::now()->subMinutes(15))
                    ->update(['trang_thai' => 'huy']);

                $soNguoiDaDat = LuotKham::where('ma_bac_si', $request->ma_bac_si)
                                        ->where('thoi_gian_den_kham', $request->thoi_gian_den_kham)
                                        ->where('trang_thai', '!=', 'huy')
                                        ->lockForUpdate()
                                        ->count();

                $gioiHanLuotKham = 1;

                if ($soNguoiDaDat >= $gioiHanLuotKham) {
                    throw new Exception('Khung giờ này của bác sĩ đã có người đặt hoặc đã đầy. Vui lòng chọn giờ khác.');
                }

                $ngayKham = Carbon::parse($request->thoi_gian_den_kham)->toDateString();
                $soThuTu = LuotKham::where('ma_bac_si', $request->ma_bac_si)
                    ->whereDate('thoi_gian_den_kham', $ngayKham)
                    ->where('trang_thai', '!=', 'huy')
                    ->count() + 1;

                // Lưu vào database với trạng thái ban đầu là "cho_thanh_toan" và STT đã chốt
                $luotKhamMoi = LuotKham::create([
                    'ma_ho_so' => $request->ma_ho_so,
                    'ma_bac_si' => $request->ma_bac_si,
                    'so_thu_tu' => $soThuTu,
                    'thoi_gian_den_kham' => $request->thoi_gian_den_kham,
                    'trang_thai' => 'cho_thanh_toan',
                    'chan_doan' => null
                ]);

                // BƯỚC 4: Đẩy tác vụ gửi Email/thông báo vào Queue để chạy ngầm
                SendBookingEmailJob::dispatch($luotKhamMoi);

                return $luotKhamMoi;
            });

            return response()->json([
                'message' => 'Đặt lịch thành công! Vui lòng hoàn tất thanh toán để nhận mã QR.',
                'data' => $result
            ], 201);

        } catch (Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    // 4. API Bệnh nhân: Lấy danh sách khung giờ trống của Bác sĩ trong 1 ngày
    public function layGioTrong(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ma_bac_si' => 'required|integer',
            'ngay_kham' => 'required|date_format:Y-m-d'
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Dữ liệu không hợp lệ', 'errors' => $validator->errors()], 422);
        }

        $maBacSi = $request->ma_bac_si;
        $ngayKham = $request->ngay_kham;

        // Tự động giải phóng các lượt khám chưa thanh toán quá 15 phút
        LuotKham::where('trang_thai', 'cho_thanh_toan')
            ->where('created_at', '<=', Carbon::now()->subMinutes(15))
            ->update(['trang_thai' => 'huy']);

        // 1. Lấy danh sách khung giờ từ Database (bảng khunggio)
        $khungGioDb = DB::table('khunggio')
            ->orderBy('gio_bat_dau')
            ->get();

        if ($khungGioDb->isEmpty()) {
            $khungGioList = [
                ['start' => '07:30:00', 'end' => '08:30:00'],
                ['start' => '08:30:00', 'end' => '09:30:00'],
                ['start' => '09:30:00', 'end' => '10:30:00'],
                ['start' => '10:30:00', 'end' => '11:30:00'],
                ['start' => '13:00:00', 'end' => '14:00:00'],
                ['start' => '14:00:00', 'end' => '15:00:00'],
                ['start' => '15:00:00', 'end' => '16:00:00'],
                ['start' => '16:00:00', 'end' => '17:00:00'],
            ];
        } else {
            $khungGioList = $khungGioDb->map(function ($kg) {
                return [
                    'start' => $kg->gio_bat_dau,
                    'end' => $kg->gio_ket_thuc,
                ];
            })->toArray();
        }

        // 2. Lấy các lịch khám đã đặt của bác sĩ trong ngày (loại trừ các lịch bị hủy 'huy')
        $cacLichDaDat = LuotKham::where('ma_bac_si', $maBacSi)
            ->whereDate('thoi_gian_den_kham', $ngayKham)
            ->where('trang_thai', '!=', 'huy')
            ->get();

        $soLuongTheoGio = [];
        foreach ($cacLichDaDat as $lich) {
            $timeOnly = Carbon::parse($lich->thoi_gian_den_kham)->format('H:i:s');
            $timeShort = Carbon::parse($lich->thoi_gian_den_kham)->format('H:i');
            $soLuongTheoGio[$timeOnly] = ($soLuongTheoGio[$timeOnly] ?? 0) + 1;
            $soLuongTheoGio[$timeShort] = ($soLuongTheoGio[$timeShort] ?? 0) + 1;
        }

        $gioTrong = [];
        $chiTiet = [];

        foreach ($khungGioList as $kg) {
            $start = $kg['start'];
            $end = $kg['end'];
            $startShort = substr($start, 0, 5);
            $endShort = substr($end, 0, 5);
            $timeRange = "{$startShort} - {$endShort}";

            $daDat = $soLuongTheoGio[$start] ?? $soLuongTheoGio[$startShort] ?? 0;
            $gioiHan = 1; // 1 người khám cho 1 bác sĩ tại 1 khung giờ
            $conCho = ($daDat < $gioiHan);

            if ($conCho) {
                $gioTrong[] = $start;
                $gioTrong[] = $startShort;
                $gioTrong[] = $timeRange;
            }

            $chiTiet[] = [
                'gio_bat_dau' => $start,
                'gio_ket_thuc' => $end,
                'time_range' => $timeRange,
                'label' => $timeRange,
                'con_cho' => $conCho,
                'da_dat' => $daDat,
                'gioi_han' => $gioiHan,
            ];
        }

        return response()->json([
            'message' => 'Lấy danh sách giờ trống thành công',
            'ma_bac_si' => $maBacSi,
            'ngay_kham' => $ngayKham,
            'danh_sach_gio_trong' => array_values(array_unique($gioTrong)),
            'chi_tiet' => $chiTiet,
        ], 200);
    }

    // 5. API Bệnh nhân: Lấy danh sách lượt khám theo mã hồ sơ
    public function danhSachTheoHoSo(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'danh_sach_ma_ho_so' => 'required|array',
            'danh_sach_ma_ho_so.*' => 'integer'
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Dữ liệu không hợp lệ', 'errors' => $validator->errors()], 422);
        }

        $danhSach = DB::table('luot_kham')
            ->whereIn('luot_kham.ma_ho_so', $request->danh_sach_ma_ho_so)
            ->leftJoin('ho_so_benh_an', 'luot_kham.ma_ho_so', '=', 'ho_so_benh_an.ma_ho_so')
            ->leftJoin('BacSi as bs_table', 'luot_kham.ma_bac_si', '=', 'bs_table.ma_bs')
            ->leftJoin('ChuyenKhoa as ck', 'bs_table.ma_chuyen_khoa', '=', 'ck.ma_chuyen_khoa')
            ->leftJoin('users as bac_si', 'luot_kham.ma_bac_si', '=', 'bac_si.id')
            ->select(
                'luot_kham.ma_luot_kham',
                'luot_kham.so_thu_tu',
                'luot_kham.thoi_gian_den_kham',
                'luot_kham.trang_thai as trang_thai_kham',
                'luot_kham.ma_bac_si',
                'bs_table.phong_kham',
                DB::raw("COALESCE(ck.ten_chuyen_khoa, 'Khoa Khám Bệnh') as khoa"),
                DB::raw("COALESCE(ck.ten_chuyen_khoa, 'Khám chuyên khoa') as chuyen_khoa"),
                DB::raw("TRIM(CONCAT(COALESCE(ho_so_benh_an.ho_chu_lot, ''), ' ', COALESCE(ho_so_benh_an.ten, ''))) as ten_benh_nhan"),
                DB::raw("COALESCE(bs_table.ho_ten, bac_si.name, 'Bác sĩ chuyên khoa') as ten_bac_si"),
                DB::raw("CASE WHEN luot_kham.trang_thai = 'cho_thanh_toan' THEN 'ChuaThanhToan' ELSE 'DaThanhToan' END as trang_thai_thanh_toan")
            )
            ->orderBy('luot_kham.thoi_gian_den_kham', 'desc')
            ->get();

        return response()->json([
            'message' => 'Thành công',
            'data' => $danhSach
        ], 200);
    }

    // 6. API Bệnh nhân: Kiểm tra trạng thái lượt khám (dùng cho polling sau khi thanh toán và check-in)
    public function checkStatus($id)
    {
        $luotKham = LuotKham::find($id);
        if (!$luotKham) {
            return response()->json(['message' => 'Không tìm thấy lượt khám'], 404);
        }

        $hoSo = DB::table('ho_so_benh_an')->where('ma_ho_so', $luotKham->ma_ho_so)->first();
        $bacSi = DB::table('BacSi')->where('ma_bs', $luotKham->ma_bac_si)->first()
            ?? DB::table('users')->where('id', $luotKham->ma_bac_si)->first();

        $isPaid = in_array($luotKham->trang_thai, ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh']);
        $isCheckedIn = in_array($luotKham->trang_thai, ['cho_kham', 'dang_kham', 'hoan_thanh']);

        return response()->json([
            'status' => 'success',
            'data' => [
                'ma_luot_kham' => $luotKham->ma_luot_kham,
                'trang_thai' => $luotKham->trang_thai,
                'thoi_gian_den_kham' => $luotKham->thoi_gian_den_kham,
                'ten_benh_nhan' => $hoSo ? trim(($hoSo->ho_chu_lot ?? '') . ' ' . ($hoSo->ten ?? '')) : null,
                'ten_bac_si' => $bacSi?->ho_ten ?? $bacSi?->name ?? 'Bác sĩ chuyên khoa',
                'phong_kham' => $bacSi?->phong_kham ?? 'Phòng 102 - Lầu 1 Khu A',
                'is_paid' => $isPaid,
                'is_checked_in' => $isCheckedIn,
                'trang_thai_thanh_toan' => $isPaid ? 'DaThanhToan' : 'ChuaThanhToan',
            ]
        ], 200);
    }

    // 7. API Bệnh nhân: Theo dõi tiến trình hàng đợi theo thời gian thực (Live Queue Tracker)
    public function layTienTrinhHangDoi(Request $request, $id)
    {
        $luotKham = LuotKham::find($id);
        if (!$luotKham) {
            return response()->json(['message' => 'Không tìm thấy lượt khám'], 404);
        }

        $hoSo = DB::table('ho_so_benh_an')->where('ma_ho_so', $luotKham->ma_ho_so)->first();
        $bacSi = DB::table('BacSi')->where('ma_bs', $luotKham->ma_bac_si)->first();
        $tenBacSi = $bacSi?->ho_ten ?? 'Bác sĩ chuyên khoa';
        $phongKham = $bacSi?->phong_kham ?? 'Phòng 102 - Lầu 1 Khu A';

        $chuyenKhoa = null;
        if ($bacSi && $bacSi->ma_chuyen_khoa) {
            $chuyenKhoa = DB::table('ChuyenKhoa')->where('ma_chuyen_khoa', $bacSi->ma_chuyen_khoa)->value('ten_chuyen_khoa');
        }

        $ngayKhamCarbon = Carbon::parse($luotKham->thoi_gian_den_kham);
        $ngayKham = $ngayKhamCarbon->toDateString();
        $today = Carbon::today();
        $isToday = $ngayKhamCarbon->isToday();
        $isFuture = $ngayKhamCarbon->isFuture() && !$isToday;
        $isPast = $ngayKhamCarbon->isPast() && !$isToday;

        // Lấy danh sách lượt khám trong ngày của bác sĩ này
        $danhSachTrongNgay = LuotKham::where('ma_bac_si', $luotKham->ma_bac_si)
            ->whereDate('thoi_gian_den_kham', $ngayKham)
            ->where('trang_thai', '!=', 'huy')
            ->orderBy('thoi_gian_den_kham', 'asc')
            ->orderBy('ma_luot_kham', 'asc')
            ->get();

        $index = $danhSachTrongNgay->search(function ($item) use ($luotKham) {
            return $item->ma_luot_kham == $luotKham->ma_luot_kham;
        });

        // 1. Số thứ tự của bạn: đọc trực tiếp cột so_thu_tu trong Database
        if ($request->has('stt')) {
            $sttCuaBan = (int)$request->input('stt');
        } elseif (!empty($luotKham->so_thu_tu)) {
            $sttCuaBan = (int)$luotKham->so_thu_tu;
        } elseif ($index !== false) {
            $sttCuaBan = $index + 1;
        } else {
            $sttCuaBan = ($luotKham->ma_luot_kham > 0) ? ($luotKham->ma_luot_kham % 30) + 1 : 18;
        }

        // Nếu là lịch khám trong tương lai (chưa đến ngày khám)
        if ($isFuture) {
            $diffDays = $today->diffInDays($ngayKhamCarbon->copy()->startOfDay());
            $thoiGianDenKhamStr = $ngayKhamCarbon->format('d/m/Y H:i');
            return response()->json([
                'status' => 'success',
                'data' => [
                    'ma_luot_kham' => $luotKham->ma_luot_kham,
                    'is_today' => false,
                    'is_future' => true,
                    'so_ngay_con_lai' => $diffDays,
                    'so_thu_tu' => $sttCuaBan,
                    'dang_phuc_vu' => 0,
                    'so_nguoi_cho' => 0,
                    'thoi_gian_cho_uoc_tinh' => "Khám ngày " . $ngayKhamCarbon->format('d/m/Y'),
                    'phong_kham' => $phongKham,
                    'ten_bac_si' => $tenBacSi,
                    'chuyen_khoa' => $chuyenKhoa ?? 'Khoa Khám Bệnh',
                    'trang_thai' => $luotKham->trang_thai,
                    'canh_bao_sap_den_luot' => false,
                    'thong_bao' => "Lịch khám vào lúc {$thoiGianDenKhamStr} (còn {$diffDays} ngày nữa). Hàng đợi trực tiếp sẽ được mở vào đúng ngày khám.",
                ]
            ], 200);
        }

        // Nếu là lịch khám trong quá khứ
        if ($isPast && !in_array($luotKham->trang_thai, ['hoan_thanh', 'dang_kham'])) {
            return response()->json([
                'status' => 'success',
                'data' => [
                    'ma_luot_kham' => $luotKham->ma_luot_kham,
                    'is_today' => false,
                    'is_future' => false,
                    'so_ngay_con_lai' => 0,
                    'so_thu_tu' => $sttCuaBan,
                    'dang_phuc_vu' => 0,
                    'so_nguoi_cho' => 0,
                    'thoi_gian_cho_uoc_tinh' => "Lịch khám đã qua",
                    'phong_kham' => $phongKham,
                    'ten_bac_si' => $tenBacSi,
                    'chuyen_khoa' => $chuyenKhoa ?? 'Khoa Khám Bệnh',
                    'trang_thai' => $luotKham->trang_thai,
                    'canh_bao_sap_den_luot' => false,
                    'thong_bao' => "Lượt khám này đã qua ngày hẹn ({$ngayKhamCarbon->format('d/m/Y')}).",
                ]
            ], 200);
        }

        // 2. Đúng ngày khám hôm nay: Xác định số đang phục vụ
        if ($request->has('dang_phuc_vu')) {
            $dangPhucVu = (int)$request->input('dang_phuc_vu');
        } else {
            // Kiểm tra lượt khám đang có trạng thái 'dang_kham' trong Database
            $dangKhamItem = $danhSachTrongNgay->firstWhere('trang_thai', 'dang_kham');
            if ($dangKhamItem && !empty($dangKhamItem->so_thu_tu)) {
                $dangPhucVu = (int)$dangKhamItem->so_thu_tu;
            } elseif ($dangKhamItem) {
                $dangPhucVu = $danhSachTrongNgay->search(fn($i) => $i->ma_luot_kham == $dangKhamItem->ma_luot_kham) + 1;
            } else {
                // Kiểm tra lượt khám gần nhất đã hoàn thành trong Database
                $maxDoneStt = $danhSachTrongNgay->where('trang_thai', 'hoan_thanh')->max('so_thu_tu');
                if ($maxDoneStt) {
                    $dangPhucVu = min((int)$maxDoneStt + 1, $sttCuaBan);
                } else {
                    $dangPhucVu = max(1, $sttCuaBan - 3);
                }
            }
        }

        // Tính toán trạng thái và thời gian chờ
        if ($luotKham->trang_thai === 'dang_kham') {
            $dangPhucVu = $sttCuaBan;
            $soNguoiCho = 0;
            $thoiGianCho = "Đang trong phòng khám";
        } elseif ($luotKham->trang_thai === 'hoan_thanh') {
            $soNguoiCho = 0;
            $thoiGianCho = "Đã hoàn thành khám";
        } else {
            $soNguoiCho = max(0, $sttCuaBan - $dangPhucVu);
            if ($soNguoiCho == 0) {
                $thoiGianCho = "Đến lượt bạn ngay bây giờ!";
            } else {
                $minMinutes = $soNguoiCho * 3 + 1;
                $maxMinutes = $soNguoiCho * 5;
                $thoiGianCho = "~{$minMinutes} - {$maxMinutes} phút";
            }
        }

        $canhBaoSapDenLuot = ($soNguoiCho > 0 && $soNguoiCho <= 3);
        $thongBao = $canhBaoSapDenLuot 
            ? "Sắp đến lượt bạn! Vui lòng có mặt trước cửa {$phongKham}." 
            : ($soNguoiCho == 0 ? "Đã đến lượt khám của bạn! Mời vào phòng khám." : "Phòng khám đang phục vụ bình thường.");

        // Tự động kích hoạt FCM Push notification khi còn 2-3 số nếu chưa gửi
        if ($canhBaoSapDenLuot && $request->input('trigger_push') == 'true') {
            $this->guiThongBaoSapDenLuot($luotKham, $phongKham, $sttCuaBan, $dangPhucVu);
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'ma_luot_kham' => $luotKham->ma_luot_kham,
                'is_today' => true,
                'is_future' => false,
                'so_ngay_con_lai' => 0,
                'so_thu_tu' => $sttCuaBan,
                'dang_phuc_vu' => $dangPhucVu,
                'so_nguoi_cho' => $soNguoiCho,
                'thoi_gian_cho_uoc_tinh' => $thoiGianCho,
                'phong_kham' => $phongKham,
                'ten_bac_si' => $tenBacSi,
                'chuyen_khoa' => $chuyenKhoa ?? 'Khoa Khám Bệnh',
                'trang_thai' => $luotKham->trang_thai,
                'canh_bao_sap_den_luot' => $canhBaoSapDenLuot,
                'thong_bao' => $thongBao,
            ]
        ], 200);
    }

    // 8. API Gửi Push Notification thông báo sắp đến lượt khám
    public function thongBaoSapDenLuot(Request $request, $id)
    {
        $luotKham = LuotKham::find($id);
        if (!$luotKham) {
            return response()->json(['message' => 'Không tìm thấy lượt khám'], 404);
        }

        $bacSi = DB::table('BacSi')->where('ma_bs', $luotKham->ma_bac_si)->first();
        $phongKham = $bacSi?->phong_kham ?? 'Phòng 102 - Lầu 1 Khu A';

        $sttCuaBan = (int)$request->input('stt', 18);
        $dangPhucVu = (int)$request->input('dang_phuc_vu', 15);

        $sent = $this->guiThongBaoSapDenLuot($luotKham, $phongKham, $sttCuaBan, $dangPhucVu);

        return response()->json([
            'status' => 'success',
            'message' => 'Đã gửi thông báo đẩy sắp đến lượt khám thành công!',
            'fcm_sent' => $sent,
            'phong_kham' => $phongKham,
            'so_thu_tu' => $sttCuaBan,
            'dang_phuc_vu' => $dangPhucVu
        ], 200);
    }

    // Hàm phụ trợ gửi FCM Push Notification
    private function guiThongBaoSapDenLuot($luotKham, $phongKham, $sttCuaBan = null, $dangPhucVu = null)
    {
        try {
            $hoSo = DB::table('ho_so_benh_an')->where('ma_ho_so', $luotKham->ma_ho_so)->first();
            if (!$hoSo) return false;

            $phone = $hoSo->so_dien_thoai;
            if (empty($phone) && !empty($hoSo->ma_benh_nhan)) {
                $bn = DB::table('benh_nhan')->where('ma_benh_nhan', $hoSo->ma_benh_nhan)->first();
                $phone = $bn?->so_dien_thoai;
            }

            if (!$phone) return false;

            $phone0 = str_starts_with($phone, '+84') ? '0' . substr($phone, 3) : $phone;
            $phone84 = str_starts_with($phone, '0') ? '+84' . substr($phone, 1) : $phone;

            $user = User::whereIn('phone_number', [$phone, $phone0, $phone84])->first();
            if ($user && !empty($user->fcm_token)) {
                $title = "🔔 Sắp đến lượt bạn!";
                $body = "Vui lòng có mặt trước cửa {$phongKham}.";
                if ($sttCuaBan && $dangPhucVu) {
                    $body = "Số của bạn: #{$sttCuaBan} (Đang gọi #{$dangPhucVu}). Vui lòng có mặt trước cửa {$phongKham}.";
                }

                FCMService::sendNotification(
                    $user->fcm_token,
                    $title,
                    $body,
                    [
                        'type' => 'queue_turn_alert',
                        'ma_luot_kham' => (string)$luotKham->ma_luot_kham,
                        'phong_kham' => $phongKham,
                        'so_thu_tu' => (string)$sttCuaBan,
                        'dang_phuc_vu' => (string)$dangPhucVu
                    ]
                );
                Log::info("Đã gửi FCM queue_turn_alert cho lượt khám #{$luotKham->ma_luot_kham} tới SĐT {$phone}");
                return true;
            } else {
                Log::info("Không tìm thấy fcm_token của user để gửi thông báo hàng đợi. SĐT: {$phone}");
                return false;
            }
        } catch (\Exception $e) {
            Log::error('Lỗi khi gửi FCM hàng đợi: ' . $e->getMessage());
            return false;
        }
    }
}
