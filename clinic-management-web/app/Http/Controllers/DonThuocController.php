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
            'ma_phien_kham'      => 'required|integer|exists:PhienKham,ma_phien_kham',
            'chi_tiet'           => 'required|array|min:1',
            'chi_tiet.*.ma_thuoc'    => 'required|integer|exists:Thuoc,ma_thuoc',
            'chi_tiet.*.so_luong'    => 'required|integer|min:1',
            'chi_tiet.*.lieu_luong'  => 'required|string|max:255',
        ], [
            'chi_tiet.required' => 'Vui lòng thêm ít nhất 1 loại thuốc',
        ]);

        try {
            $donThuoc = DB::transaction(function () use ($data) {
                // 1. Xóa đơn cũ nếu có
                $old = DonThuoc::where('ma_phien_kham', $data['ma_phien_kham'])->first();
                if ($old) {
                    ChiTietDonThuoc::where('ma_don_thuoc', $old->ma_don_thuoc)->delete();
                    $old->delete();
                }

                // 2. Tạo đơn mới
                $dt = DonThuoc::create([
                    'ma_phien_kham' => $data['ma_phien_kham'],
                    'tong_tien'     => 0,
                ]);

                // 3. Thêm chi tiết
                $tongTien = 0;
                foreach ($data['chi_tiet'] as $ct) {
                    $thuoc = Thuoc::find($ct['ma_thuoc']);
                    if (!$thuoc) continue;

                    $thanhTien = $thuoc->don_gia * $ct['so_luong'];
                    $tongTien += $thanhTien;

                    ChiTietDonThuoc::create([
                        'ma_don_thuoc' => $dt->ma_don_thuoc,
                        'ma_thuoc'     => $ct['ma_thuoc'],
                        'so_luong'     => $ct['so_luong'],
                        'lieu_luong'   => $ct['lieu_luong'],
                        'thanh_tien'   => $thanhTien,
                    ]);
                }

                // 4. Update tổng tiền
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
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
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
}