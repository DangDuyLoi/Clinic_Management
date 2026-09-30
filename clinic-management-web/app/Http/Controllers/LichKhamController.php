<?php

namespace App\Http\Controllers;

use App\Models\LichKham;
use App\Models\BacSi;
use App\Models\KhungGio;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LichKhamController extends Controller
{
    /* ============================================================
       GET /api/lich-kham
       Query: ?ngay=2026-09-21&ma_bs=1&trang_thai=ChoKham&ma_bn=1
       ============================================================ */
    public function index(Request $request)
    {
        $query = LichKham::with(['benhNhan', 'bacSi.chuyenKhoa', 'khungGio']);

        if ($ngay = $request->query('ngay')) {
            $query->where('ngay_kham', $ngay);
        }
        if ($maBs = $request->query('ma_bs')) {
            $query->where('ma_bs', $maBs);
        }
        if ($maBn = $request->query('ma_bn')) {
            $query->where('ma_bn', $maBn);
        }
        if ($trangThai = $request->query('trang_thai')) {
            $query->where('trang_thai', $trangThai);
        }

        $perPage = (int) $request->query('per_page', 20);
        $perPage = max(1, min($perPage, 100));

        $data = $query->orderBy('ngay_kham', 'desc')
                      ->orderBy('ma_khung_gio')
                      ->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /* ============================================================
       POST /api/lich-kham
       ĐẶT LỊCH KHÁM + THUẬT TOÁN XẾP LỊCH
       Body: {
         ma_bn,                  (bắt buộc)
         ma_chuyen_khoa,         (bắt buộc)
         ngay_kham,              (bắt buộc, >= hôm nay)
         ma_khung_gio?,          (tùy chọn — nếu null sẽ tự tìm)
         diem_uu_tien?           (0-10)
       }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ma_bn'          => 'required|integer|exists:BenhNhan,ma_bn',
            'ma_chuyen_khoa' => 'required|integer|exists:ChuyenKhoa,ma_chuyen_khoa',
            'ngay_kham'      => 'required|date|after_or_equal:today',
            'ma_khung_gio'   => 'nullable|integer|exists:KhungGio,ma_khung_gio',
            'diem_uu_tien'   => 'nullable|integer|min:0|max:10',
        ], [
            'ma_bn.required'          => 'Vui lòng chọn bệnh nhân',
            'ma_bn.exists'            => 'Bệnh nhân không tồn tại',
            'ma_chuyen_khoa.required' => 'Vui lòng chọn chuyên khoa',
            'ma_chuyen_khoa.exists'   => 'Chuyên khoa không tồn tại',
            'ngay_kham.required'      => 'Vui lòng chọn ngày khám',
            'ngay_kham.after_or_equal'=> 'Ngày khám không được trong quá khứ',
        ]);

        try {
            $result = DB::transaction(function () use ($data) {
                // B1. Xác định khung giờ
                if (!empty($data['ma_khung_gio'])) {
                    $khungGio = KhungGio::findOrFail($data['ma_khung_gio']);
                } else {
                    $khungGio = $this->findFirstAvailableKhungGio(
                        $data['ngay_kham'],
                        $data['ma_chuyen_khoa']
                    );
                }

                if (!$khungGio) {
                    throw new \Exception('Không còn khung giờ trống trong ngày này');
                }

                // B2. Áp dụng thuật toán chọn bác sĩ
                $bacSi = $this->pickBacSi(
                    $data['ma_chuyen_khoa'],
                    $data['ngay_kham'],
                    $khungGio->ma_khung_gio
                );

                if (!$bacSi) {
                    throw new \Exception('Không có bác sĩ trống cho khung giờ này. Vui lòng chọn giờ khác.');
                }

                // B3. Tạo lịch khám
                return LichKham::create([
                    'ma_bn'          => $data['ma_bn'],
                    'ma_bs'          => $bacSi->ma_bs,
                    'ngay_kham'      => $data['ngay_kham'],
                    'ma_khung_gio'   => $khungGio->ma_khung_gio,
                    'diem_uu_tien'   => $data['diem_uu_tien'] ?? 0,
                    'trang_thai'     => 'ChoXacNhan',
                    'khach_vang_lai' => false,
                ]);
            });

            return response()->json([
                'status'  => 'success',
                'message' => 'Đặt lịch thành công',
                'data'    => $result->load(['benhNhan', 'bacSi.chuyenKhoa', 'khungGio']),
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 400);
        }
    }

    /* ============================================================
       GET /api/lich-kham/{id}
       ============================================================ */
    public function show($id)
    {
        $lich = LichKham::with([
            'benhNhan', 'bacSi.chuyenKhoa', 'khungGio', 'phienKham'
        ])->find($id);

        if (!$lich) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy lịch khám',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $lich,
        ]);
    }

    /* ============================================================
       PUT /api/lich-kham/{id}/checkin
       Lễ tân xác nhận bệnh nhân đã đến quầy
       ============================================================ */
    public function checkIn($id)
    {
        $lich = LichKham::find($id);

        if (!$lich) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy lịch khám',
            ], 404);
        }

        if (!in_array($lich->trang_thai, ['ChoXacNhan', 'ChoDenKham'], true)) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể check-in ở trạng thái {$lich->trang_thai}",
            ], 400);
        }

        $lich->trang_thai = 'ChoKham';
        $lich->thoi_gian_den_quay = now()->format('H:i:s');
        $lich->save();

        return response()->json([
            'status'  => 'success',
            'message' => 'Check-in thành công',
            'data'    => $lich,
        ]);
    }

    /* ============================================================
       PUT /api/lich-kham/{id}/cancel
       Hủy lịch khám — giải phóng slot
       ============================================================ */
    public function cancel(Request $request, $id)
    {
        $request->validate([
            'ly_do' => 'nullable|string|max:500',
        ]);

        $lich = LichKham::find($id);

        if (!$lich) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy lịch khám',
            ], 404);
        }

        if ($lich->trang_thai === 'HoanThanh') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể hủy lịch đã hoàn thành',
            ], 400);
        }

        if ($lich->trang_thai === 'DaHuy') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Lịch đã bị hủy trước đó',
            ], 400);
        }

        $lich->trang_thai = 'DaHuy';
        $lich->ghi_chu = $request->ly_do;
        $lich->save();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã hủy lịch khám',
            'data'    => $lich,
        ]);
    }

    /* ============================================================
       GET /api/lich-kham/khung-gio-trong
       Xem khung giờ còn trống theo ngày + chuyên khoa
       Query: ?ngay=2026-09-21&ma_chuyen_khoa=2
       ============================================================ */
    public function availableSlots(Request $request)
    {
        $request->validate([
            'ngay'           => 'required|date|after_or_equal:today',
            'ma_chuyen_khoa' => 'required|integer|exists:ChuyenKhoa,ma_chuyen_khoa',
        ]);

        $ngay = $request->query('ngay');
        $maChuyenKhoa = $request->query('ma_chuyen_khoa');

        // Lấy danh sách bác sĩ thuộc chuyên khoa
        $dsBacSi = BacSi::where('ma_chuyen_khoa', $maChuyenKhoa)->get();

        if ($dsBacSi->isEmpty()) {
            return response()->json([
                'status'  => 'success',
                'data'    => [],
                'message' => 'Chưa có bác sĩ nào thuộc chuyên khoa này',
            ]);
        }

        // Lấy tất cả khung giờ
        $dsKhungGio = KhungGio::with('caLamViec')->orderBy('gio_bat_dau')->get();
        $ketQua = [];

        foreach ($dsKhungGio as $kg) {
            // Đếm số bác sĩ còn trống trong khung giờ này
            $soBacSiConTrong = 0;

            foreach ($dsBacSi as $bs) {
                $demKhungGio = LichKham::where('ma_bs', $bs->ma_bs)
                    ->where('ngay_kham', $ngay)
                    ->where('ma_khung_gio', $kg->ma_khung_gio)
                    ->where('trang_thai', '!=', 'DaHuy')
                    ->count();

                if ($demKhungGio < $kg->luot_kham_toi_da) {
                    $soBacSiConTrong++;
                }
            }

            if ($soBacSiConTrong > 0) {
                $ketQua[] = [
                    'ma_khung_gio'   => $kg->ma_khung_gio,
                    'gio_bat_dau'    => $kg->gio_bat_dau,
                    'gio_ket_thuc'   => $kg->gio_ket_thuc,
                    'ten_ca'         => $kg->caLamViec->ten_ca ?? null,
                    'luot_toi_da'    => $kg->luot_kham_toi_da,
                    'so_bac_si_trong' => $soBacSiConTrong,
                ];
            }
        }

        return response()->json([
            'status' => 'success',
            'data'   => $ketQua,
        ]);
    }

    /* ============================================================
       THUẬT TOÁN XẾP LỊCH — CORE LOGIC
       ============================================================ */

    /**
     * Chọn bác sĩ tối ưu theo:
     *   R1. Đúng chuyên khoa
     *   R2. Khung giờ còn trống (R4: ≤ KhungGio.luot_kham_toi_da)
     *   R3. Ca chưa đầy (R3: ≤ BacSi.luot_kham_toi_da_moi_ca)
     *   Ưu tiên: bác sĩ có tải ca thấp nhất (cân bằng tải)
     */
    private function pickBacSi(int $maChuyenKhoa, string $ngay, int $maKhungGio): ?BacSi
    {
        $khungGio = KhungGio::findOrFail($maKhungGio);
        $maCa = $khungGio->ma_ca;

        $dsBacSi = BacSi::where('ma_chuyen_khoa', $maChuyenKhoa)->get();
        $ungVien = [];

        foreach ($dsBacSi as $bs) {
            // R4 — kiểm tra khung giờ còn chỗ không
            $demKhungGio = LichKham::where('ma_bs', $bs->ma_bs)
                ->where('ngay_kham', $ngay)
                ->where('ma_khung_gio', $maKhungGio)
                ->where('trang_thai', '!=', 'DaHuy')
                ->count();

            if ($demKhungGio >= $khungGio->luot_kham_toi_da) {
                continue;
            }

            // R3 — kiểm tra ca còn chỗ không
            $demCa = LichKham::where('ma_bs', $bs->ma_bs)
                ->where('ngay_kham', $ngay)
                ->whereHas('khungGio', function ($q) use ($maCa) {
                    $q->where('ma_ca', $maCa);
                })
                ->where('trang_thai', '!=', 'DaHuy')
                ->count();

            if ($demCa >= $bs->luot_kham_toi_da_moi_ca) {
                continue;
            }

            $ungVien[] = [
                'bs'    => $bs,
                'demCa' => $demCa,
                'demKg' => $demKhungGio,
            ];
        }

        if (empty($ungVien)) {
            return null;
        }

        // Sắp xếp: ưu tiên bác sĩ có tải ca thấp nhất (cân bằng tải)
        // Nếu bằng nhau → ưu tiên bác sĩ có tải khung giờ thấp hơn
        usort($ungVien, function ($a, $b) {
            if ($a['demCa'] !== $b['demCa']) {
                return $a['demCa'] <=> $b['demCa'];
            }
            return $a['demKg'] <=> $b['demKg'];
        });

        return $ungVien[0]['bs'];
    }

    /**
     * Tìm khung giờ trống đầu tiên trong ngày
     * Áp dụng khi bệnh nhân không chỉ định giờ cụ thể
     */
        private function findFirstAvailableKhungGio(string $ngay, int $maChuyenKhoa): ?KhungGio
    {
        // Lấy bác sĩ thuộc chuyên khoa
        $dsBacSi = BacSi::where('ma_chuyen_khoa', $maChuyenKhoa)->get();

        if ($dsBacSi->isEmpty()) {
            return null;
        }

        $dsKhungGio = KhungGio::orderBy('gio_bat_dau')->get();

        foreach ($dsKhungGio as $kg) {
            // Kiểm tra từng bác sĩ — nếu có ít nhất 1 BS còn chỗ → OK
            foreach ($dsBacSi as $bs) {
                $demTheoBs = LichKham::where('ma_bs', $bs->ma_bs)
                    ->where('ngay_kham', $ngay)
                    ->where('ma_khung_gio', $kg->ma_khung_gio)
                    ->where('trang_thai', '!=', 'DaHuy')
                    ->count();

                if ($demTheoBs < $kg->luot_kham_toi_da) {
                    return $kg;
                }
            }
        }

        return null;
    }
}