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
                $soNguoiDaDat = LuotKham::where('ma_bac_si', $request->ma_bac_si)
                                        ->where('thoi_gian_den_kham', $request->thoi_gian_den_kham)
                                        ->lockForUpdate()
                                        ->count();

                $gioiHanLuotKham = 1;

                if ($soNguoiDaDat >= $gioiHanLuotKham) {
                    throw new Exception('Khung giờ này của bác sĩ đã có người đặt hoặc đã đầy. Vui lòng chọn giờ khác.');
                }

                // Lưu vào database với trạng thái ban đầu là "cho_thanh_toan"
                $luotKhamMoi = LuotKham::create([
                    'ma_ho_so' => $request->ma_ho_so,
                    'ma_bac_si' => $request->ma_bac_si,
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

        $khungGioMacDinh = [
            '08:00:00', '08:30:00', '09:00:00', '09:30:00',
            '10:00:00', '10:30:00', '11:00:00', '11:30:00',
            '13:00:00', '13:30:00', '14:00:00', '14:30:00',
            '15:00:00', '15:30:00', '16:00:00', '16:30:00'
        ];

        $cacLichDaDat = LuotKham::where('ma_bac_si', $maBacSi)
            ->whereDate('thoi_gian_den_kham', $ngayKham)
            ->where('trang_thai', '!=', 'huy')
            ->pluck('thoi_gian_den_kham')
            ->map(function ($datetime) {
                return Carbon::parse($datetime)->format('H:i:s');
            })
            ->toArray();

        $gioTrong = array_values(array_diff($khungGioMacDinh, $cacLichDaDat));

        return response()->json([
            'message' => 'Lấy danh sách giờ trống thành công',
            'ma_bac_si' => $maBacSi,
            'ngay_kham' => $ngayKham,
            'danh_sach_gio_trong' => $gioTrong
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
            ->leftJoin('users as bac_si', 'luot_kham.ma_bac_si', '=', 'bac_si.id')
            ->select(
                'luot_kham.ma_luot_kham',
                'luot_kham.thoi_gian_den_kham',
                'luot_kham.trang_thai as trang_thai_kham',
                'luot_kham.ma_bac_si',
                DB::raw("CONCAT(ho_so_benh_an.ho_chu_lot, ' ', ho_so_benh_an.ten) as ten_benh_nhan"),
                'bac_si.name as ten_bac_si',
                DB::raw("CASE WHEN luot_kham.trang_thai = 'cho_thanh_toan' THEN 'ChuaThanhToan' ELSE 'DaThanhToan' END as trang_thai_thanh_toan"),
                DB::raw("'DaThanhToan' as trang_thai_thanh_toan")
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
        $bacSi = DB::table('users')->where('id', $luotKham->ma_bac_si)->first();

        $isPaid = in_array($luotKham->trang_thai, ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh']);
        $isCheckedIn = in_array($luotKham->trang_thai, ['cho_kham', 'dang_kham', 'hoan_thanh']);

        return response()->json([
            'status' => 'success',
            'data' => [
                'ma_luot_kham' => $luotKham->ma_luot_kham,
                'trang_thai' => $luotKham->trang_thai,
                'thoi_gian_den_kham' => $luotKham->thoi_gian_den_kham,
                'ten_benh_nhan' => $hoSo ? ($hoSo->ho_chu_lot . ' ' . $hoSo->ten) : null,
                'ten_bac_si' => $bacSi?->name ?? 'Bác sĩ chuyên khoa',
                'is_paid' => $isPaid,
                'is_checked_in' => $isCheckedIn,
                'trang_thai_thanh_toan' => $isPaid ? 'DaThanhToan' : 'ChuaThanhToan',
            ]
        ], 200);
    }
}
