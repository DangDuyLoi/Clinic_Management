<?php

namespace App\Http\Controllers;

use App\Models\BacSi;
use App\Models\BenhNhan;
use App\Models\HoSoBenhAn;
use App\Models\KhungGio;
use App\Models\LichKham;
use App\Rules\ValidBhyt;
use Illuminate\Http\Request;

class LichKhamController extends Controller
{
    public function index(Request $request)
    {
        $query = LichKham::with(['hoSo.benhNhan', 'bacSi.chuyenKhoa']);

        if ($ngay = $request->query('ngay')) {
            $query->whereDate('thoi_gian_den_kham', $ngay);
        }
        if ($maBs = $request->query('ma_bac_si')) {
            $query->where('ma_bac_si', $maBs);
        }
        if ($trangThai = $request->query('trang_thai')) {
            $query->where('trang_thai', $trangThai);
        }

        $perPage = (int) $request->query('per_page', 20);
        $data = $query->orderBy('thoi_gian_den_kham', 'desc')->paginate($perPage);

        return response()->json(['status' => 'success', 'data' => $data]);
    }

    public function store(Request $request)
    {
        $benhNhan = BenhNhan::find($request->input('ma_benh_nhan'));

        if (! $benhNhan) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy bệnh nhân'], 404);
        }

        $data = $request->validate([
            'ma_benh_nhan' => 'required|integer',
            'ma_chuyen_khoa' => 'required|integer',
            'ngay_kham' => 'required|date|after_or_equal:today',
            'ma_khung_gio' => 'nullable|integer',
            'hinh_thuc_kham' => 'required|in:DichVu,BHYT',
            'ma_bhyt' => ['nullable', 'string', new ValidBhyt($benhNhan->ngay_sinh)],
        ]);

        // Logic đặt lịch thật
        $maBn = $data['ma_benh_nhan'];
        $maCk = $data['ma_chuyen_khoa'];
        $ngayKham = $data['ngay_kham'];
        $maKg = $data['ma_khung_gio'] ?? null;

        // Tìm hồ sơ bệnh án
        $hoSo = HoSoBenhAn::where('ma_benh_nhan', $maBn)->first();
        if (! $hoSo) {
            return response()->json(['status' => 'error', 'message' => 'Bệnh nhân chưa có hồ sơ'], 400);
        }
        // Nếu là BHYT và có nhập mã thẻ, lưu lại vào hồ sơ để lúc thanh toán sử dụng
        if ($data['hinh_thuc_kham'] === 'BHYT' && ! empty($data['ma_bhyt'])) {

            // 1. Kiểm tra xem thẻ BHYT này đã bị gán cho bệnh nhân NÀO KHÁC chưa
            $isDuplicate = BenhNhan::where('ma_bhyt', $data['ma_bhyt'])
                ->where('ma_benh_nhan', '!=', $maBn) // Loại trừ chính bệnh nhân đang đặt lịch
                ->exists();

            if ($isDuplicate) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Mã thẻ BHYT này đã được sử dụng bởi một bệnh nhân khác trong hệ thống.',
                ], 400);
            }

            // 2. Nếu hợp lệ, lưu lại vào hồ sơ để lần sau tự động điền
            $benhNhan->update(['ma_bhyt' => $data['ma_bhyt']]);
            $hoSo->update(['ma_bhyt' => $data['ma_bhyt']]);
        }

        $dsBacSi = BacSi::where('ma_chuyen_khoa', $maCk)->get();
        if ($dsBacSi->isEmpty()) {
            return response()->json(['status' => 'error', 'message' => 'Khoa này hiện chưa có bác sĩ'], 400);
        }

        $bestDoctor = null;
        $selectedKhungGio = null;

        if ($maKg) {
            // TRƯỜNG HỢP 1: Lễ tân chọn khung giờ cụ thể
            $selectedKhungGio = KhungGio::find($maKg);
            if (! $selectedKhungGio) {
                return response()->json(['status' => 'error', 'message' => 'Khung giờ không tồn tại'], 400);
            }

            $gioBatDau = $selectedKhungGio->gio_bat_dau;
            $gioKetThuc = $selectedKhungGio->gio_ket_thuc;
            $gioiHanKhungGio = $selectedKhungGio->luot_kham_toi_da;

            $minCount = 9999;
            foreach ($dsBacSi as $bs) {
                $count = LichKham::where('ma_bac_si', $bs->ma_bs)
                    ->whereDate('thoi_gian_den_kham', $ngayKham)
                    ->whereTime('thoi_gian_den_kham', '>=', $gioBatDau)
                    ->whereTime('thoi_gian_den_kham', '<', $gioKetThuc)
                    ->where('trang_thai', '!=', 'huy')
                    ->count();

                if ($count < $gioiHanKhungGio && $count < $minCount) {
                    $minCount = $count;
                    $bestDoctor = $bs;
                }
            }

            if (! $bestDoctor) {
                return response()->json(['status' => 'error', 'message' => 'Khung giờ này đã kín lịch. Vui lòng chọn giờ khác.'], 400);
            }

        } else {
            // TRƯỜNG HỢP 2: Tự động xếp lịch (Tìm giờ sớm nhất còn trống)
            $allKhungGio = KhungGio::orderBy('gio_bat_dau')->get();

            foreach ($allKhungGio as $kg) {
                $gioBatDau = $kg->gio_bat_dau;
                $gioKetThuc = $kg->gio_ket_thuc;
                $gioiHanKhungGio = $kg->luot_kham_toi_da;

                $minCount = 9999;
                $tempBestDoctor = null;

                foreach ($dsBacSi as $bs) {
                    $count = LichKham::where('ma_bac_si', $bs->ma_bs)
                        ->whereDate('thoi_gian_den_kham', $ngayKham)
                        ->whereTime('thoi_gian_den_kham', '>=', $gioBatDau)
                        ->whereTime('thoi_gian_den_kham', '<', $gioKetThuc)
                        ->where('trang_thai', '!=', 'huy')
                        ->count();

                    if ($count < $gioiHanKhungGio && $count < $minCount) {
                        $minCount = $count;
                        $tempBestDoctor = $bs;
                    }
                }

                // Nếu tìm được bác sĩ cho khung giờ này, chốt luôn và dừng vòng lặp
                if ($tempBestDoctor) {
                    $bestDoctor = $tempBestDoctor;
                    $selectedKhungGio = $kg;
                    break;
                }
            }

            if (! $bestDoctor) {
                return response()->json(['status' => 'error', 'message' => 'Đã hết khung giờ trống cho ngày này. Vui lòng chọn ngày khác.'], 400);
            }
        }

        // Thời gian khám lấy theo khung giờ đã chốt
        $thoiGianDenKham = $ngayKham.' '.$selectedKhungGio->gio_bat_dau;

        $lich = LichKham::create([
            'ma_ho_so' => $hoSo->ma_ho_so ?? 1,
            'ma_bac_si' => $bestDoctor->ma_bs,
            'thoi_gian_den_kham' => $thoiGianDenKham,
            'trang_thai' => 'cho_thanh_toan',
            'hinh_thuc_kham' => $data['hinh_thuc_kham'],
        ]);

        return response()->json(['status' => 'success', 'message' => 'Đặt lịch thành công', 'data' => $lich], 201);
    }

    public function show($id)
    {
        $lich = LichKham::with(['hoSo.benhNhan', 'bacSi.chuyenKhoa', 'phienKham'])->find($id);
        if (! $lich) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy'], 404);
        }

        return response()->json(['status' => 'success', 'data' => $lich]);
    }

    public function checkIn($id)
    {
        $lich = LichKham::find($id);
        if (! $lich) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy'], 404);
        }

        if (! in_array($lich->trang_thai, ['da_thanh_toan', 'cho_kham', 'ChoXacNhan', 'ChoDenKham'])) {
            return response()->json(['status' => 'error', 'message' => "Không thể check-in ở trạng thái {$lich->trang_thai}"], 400);
        }

        $lich->trang_thai = 'cho_kham';
        $lich->save();

        return response()->json(['status' => 'success', 'message' => 'Check-in thành công', 'data' => $lich]);
    }

    public function cancel(Request $request, $id)
    {
        $lich = LichKham::find($id);
        if (! $lich) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy'], 404);
        }

        $lich->trang_thai = 'huy';
        $lich->save();

        return response()->json(['status' => 'success', 'message' => 'Đã hủy lịch khám', 'data' => $lich]);
    }

    public function availableSlots(Request $request)
    {
        $ngay = $request->query('ngay');
        $maChuyenKhoa = $request->query('ma_chuyen_khoa');
        $dsBacSi = BacSi::where('ma_chuyen_khoa', $maChuyenKhoa)->get();
        $dsKhungGio = KhungGio::with('caLamViec')->orderBy('gio_bat_dau')->get();
        $ketQua = [];

        foreach ($dsKhungGio as $kg) {
            $soBacSiConTrong = 0;
            foreach ($dsBacSi as $bs) {
                $dem = LichKham::where('ma_bac_si', $bs->ma_bs)
                    ->whereDate('thoi_gian_den_kham', $ngay)
                    ->whereTime('thoi_gian_den_kham', '>=', $kg->gio_bat_dau)
                    ->whereTime('thoi_gian_den_kham', '<', $kg->gio_ket_thuc)
                    ->where('trang_thai', '!=', 'huy')
                    ->count();
                if ($dem < $kg->luot_kham_toi_da) {
                    $soBacSiConTrong++;
                }
            }
            if ($soBacSiConTrong > 0) {
                $ketQua[] = [
                    'ma_khung_gio' => $kg->ma_khung_gio,
                    'gio_bat_dau' => $kg->gio_bat_dau,
                    'gio_ket_thuc' => $kg->gio_ket_thuc,
                    'ten_ca' => $kg->caLamViec->ten_ca ?? null,
                    'so_bac_si_trong' => $soBacSiConTrong,
                ];
            }
        }

        return response()->json(['status' => 'success', 'data' => $ketQua]);
    }

    public function getQR($id)
    {
        $lich = LichKham::find($id);
        if (! $lich) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy'], 404);
        }

        if (! $lich->qr_token) {
            $lich->qr_token = 'LK'.strtoupper(bin2hex(random_bytes(16)));
            $lich->save();
        }
        $qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=LICHKHAM:'.$lich->qr_token;

        return response()->json([
            'status' => 'success',
            'data' => ['qr_token' => $lich->qr_token, 'qr_url' => $qrUrl],
        ]);
    }

        public function scanQR(Request $request)
    {
        // Lấy dữ liệu thô
        $qrContent = $request->qr_content ?? '';
        $qrToken = $request->qr_token ?? '';

        // Nếu client gửi chuỗi dài (có chứa LICHKHAM:), ta cắt lấy token và làm sạch
        if (str_contains($qrContent, 'LICHKHAM:')) {
            $token = str_replace('LICHKHAM:', '', $qrContent);
            // Loại bỏ mọi ký tự không phải chữ cái hoặc số (xóa dấu ", khoảng trắng...)
            $token = preg_replace('/[^a-zA-Z0-9]/', '', $token);
        } else {
            $token = preg_replace('/[^a-zA-Z0-9]/', '', $qrToken);
        }

        // Tìm lịch khám với token đã làm sạch
        $lich = LichKham::with(['hoSo.benhNhan', 'bacSi'])->where('qr_token', $token)->first();
        
        if (! $lich) {
            return response()->json(['status' => 'error', 'message' => 'Mã QR không hợp lệ hoặc lịch khám đã bị hủy/xóa.'], 404);
        }

        return response()->json(['status' => 'success', 'data' => $lich]);
    }

    public function checkInByQR($id)
    {
        $lich = LichKham::find($id);
        if (! $lich) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy'], 404);
        }

        $lich->trang_thai = 'cho_kham';
        $lich->save();

        return response()->json(['status' => 'success', 'message' => 'Check-in thành công']);
    }

    /* ============================================================
       PUT /api/lich-kham/{id}/pay
       Thanh toán cho Lượt khám (Khi chưa có Hóa đơn)
       ============================================================ */
    public function pay(Request $request, $id)
    {
        $lich = LichKham::find($id);
        if (! $lich) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy lượt khám'], 404);
        }

        if ($lich->trang_thai !== 'cho_thanh_toan') {
            return response()->json(['status' => 'error', 'message' => 'Lượt khám này không ở trạng thái chờ thanh toán'], 400);
        }

        // Cập nhật trạng thái thành Đã thanh toán (Chờ khám)
        $lich->trang_thai = 'da_thanh_toan';
        $lich->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Đã xác nhận thanh toán lượt khám thành công',
            'data' => $lich,
        ]);
    }
}
