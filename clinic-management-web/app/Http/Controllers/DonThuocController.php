<?php

namespace App\Http\Controllers;

use App\Models\DonThuoc;
use App\Models\ChiTietDonThuoc;
use App\Models\Thuoc;
use App\Models\PhienKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DonThuocController extends Controller
{
    /* ============================================================
       GET /api/don-thuoc/phien-kham/{maPhien}
       Lấy đơn thuốc theo phiên khám
       ============================================================ */
    public function getByPhienKham($maPhien)
    {
        $dt = DonThuoc::with('chiTiet.thuoc')
            ->where('ma_phien_kham', $maPhien)
            ->first();

        return response()->json([
            'status' => 'success',
            'data'   => $dt,
        ]);
    }

    /* ============================================================
       POST /api/don-thuoc
       Tạo hoặc cập nhật đơn thuốc cho phiên khám
       Body: {
         ma_phien_kham,
         chi_tiet: [
           { ma_thuoc, so_luong, lieu_luong }
         ]
       }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ma_phien_kham'         => 'required|integer|exists:PhienKham,ma_phien_kham',
            'chi_tiet'              => 'required|array|min:1',
            'chi_tiet.*.ma_thuoc'   => 'required|integer|exists:Thuoc,ma_thuoc',
            'chi_tiet.*.so_luong'   => 'required|integer|min:1',
            'chi_tiet.*.lieu_luong' => 'required|string|max:255',
        ], [
            'chi_tiet.required' => 'Vui lòng thêm ít nhất 1 loại thuốc',
        ]);

        try {
            $donThuoc = DB::transaction(function () use ($data) {

                // ============================================
                // 1. XỬ LÝ ĐƠN CŨ (nếu có) — HOÀN KHO
                // ============================================
                $oldDonThuoc = DonThuoc::where('ma_phien_kham', $data['ma_phien_kham'])->first();

                if ($oldDonThuoc) {
                    $oldChiTiet = ChiTietDonThuoc::where('ma_don_thuoc', $oldDonThuoc->ma_don_thuoc)->get();

                    // Hoàn kho các thuốc đã trừ trước đó
                    foreach ($oldChiTiet as $ct) {
                        Thuoc::where('ma_thuoc', $ct->ma_thuoc)
                            ->increment('so_luong_ton', $ct->so_luong);
                    }

                    // Xóa chi tiết cũ
                    ChiTietDonThuoc::where('ma_don_thuoc', $oldDonThuoc->ma_don_thuoc)->delete();
                    $oldDonThuoc->delete();
                }

                // ============================================
                // 2. VALIDATE TỒN KHO (sau khi hoàn kho đơn cũ)
                // ============================================
                foreach ($data['chi_tiet'] as $ct) {
                    $thuoc = Thuoc::find($ct['ma_thuoc']);
                    if (!$thuoc) {
                        throw new \Exception("Thuốc mã #{$ct['ma_thuoc']} không tồn tại");
                    }

                    if ($thuoc->so_luong_ton < $ct['so_luong']) {
                        throw new \Exception(
                            "Thuốc '{$thuoc->ten_thuoc}' không đủ tồn kho. " .
                            "Còn lại: {$thuoc->so_luong_ton}, cần: {$ct['so_luong']}"
                        );
                    }
                }

                // ============================================
                // 3. TẠO ĐƠN MỚI + TRỪ KHO
                // ============================================
                $dt = DonThuoc::create([
                    'ma_phien_kham' => $data['ma_phien_kham'],
                    'tong_tien'     => 0,
                ]);

                $tongTien = 0;

                foreach ($data['chi_tiet'] as $ct) {
                    $thuoc = Thuoc::find($ct['ma_thuoc']);
                    $thanhTien = $thuoc->don_gia * $ct['so_luong'];
                    $tongTien += $thanhTien;

                    // Tạo chi tiết
                    ChiTietDonThuoc::create([
                        'ma_don_thuoc' => $dt->ma_don_thuoc,
                        'ma_thuoc'     => $ct['ma_thuoc'],
                        'so_luong'     => $ct['so_luong'],
                        'lieu_luong'   => $ct['lieu_luong'],
                        'thanh_tien'   => $thanhTien,
                    ]);

                    // ⭐ TRỪ TỒN KHO
                    $thuoc->decrement('so_luong_ton', $ct['so_luong']);
                }

                // Update tổng tiền
                $dt->tong_tien = $tongTien;
                $dt->save();

                return $dt;
            });

            return response()->json([
                'status'  => 'success',
                'message' => 'Lưu đơn thuốc thành công',
                'data'    => $donThuoc->fresh()->load('chiTiet.thuoc'),
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => $e->getMessage(),
            ], 400);
        }
    }
    public function show($id)
    {
        $dt = DonThuoc::with('chiTiet.thuoc', 'phienKham.lichKham.benhNhan')->find($id);
        if (!$dt) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy đơn thuốc'], 404);
        }
        return response()->json(['status' => 'success', 'data' => $dt]);
    }
        public function destroy($id)
    {
        $dt = DonThuoc::with('chiTiet')->find($id);

        if (!$dt) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy đơn thuốc',
            ], 404);
        }

        try {
            DB::transaction(function () use ($dt) {
                // Hoàn kho
                foreach ($dt->chiTiet as $ct) {
                    Thuoc::where('ma_thuoc', $ct->ma_thuoc)
                        ->increment('so_luong_ton', $ct->so_luong);
                }

                // Xóa chi tiết + đơn
                ChiTietDonThuoc::where('ma_don_thuoc', $dt->ma_don_thuoc)->delete();
                $dt->delete();
            });

            return response()->json([
                'status'  => 'success',
                'message' => 'Đã hủy đơn thuốc và hoàn kho',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }
}