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
    public function getByPhienKham($maPhien)
    {
        $dt = DonThuoc::with('chiTiet.thuoc')->where('ma_phien_kham', $maPhien)->first();
        return response()->json(['status' => 'success', 'data' => $dt]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'ma_phien_kham'         => 'required|integer|exists:PhienKham,ma_phien_kham',
            'chi_tiet'              => 'required|array|min:1',
            'chi_tiet.*.ma_thuoc'   => 'required|integer|exists:Thuoc,ma_thuoc',
            'chi_tiet.*.so_luong'   => 'required|integer|min:1',
            'chi_tiet.*.lieu_luong' => 'required|string|max:255',
        ]);

        try {
            $donThuoc = DB::transaction(function () use ($data) {
                $oldDonThuoc = DonThuoc::where('ma_phien_kham', $data['ma_phien_kham'])->first();
                if ($oldDonThuoc) {
                    $oldChiTiet = ChiTietDonThuoc::where('ma_don_thuoc', $oldDonThuoc->ma_don_thuoc)->get();
                    foreach ($oldChiTiet as $ct) Thuoc::where('ma_thuoc', $ct->ma_thuoc)->increment('so_luong_ton', $ct->so_luong);
                    ChiTietDonThuoc::where('ma_don_thuoc', $oldDonThuoc->ma_don_thuoc)->delete();
                    $oldDonThuoc->delete();
                }

                foreach ($data['chi_tiet'] as $ct) {
                    $thuoc = Thuoc::find($ct['ma_thuoc']);
                    if ($thuoc->so_luong_ton < $ct['so_luong']) throw new \Exception("Thuốc '{$thuoc->ten_thuoc}' không đủ tồn kho.");
                }

                $dt = DonThuoc::create(['ma_phien_kham' => $data['ma_phien_kham'], 'tong_tien' => 0]);
                $tongTien = 0;

                foreach ($data['chi_tiet'] as $ct) {
                    $thuoc = Thuoc::find($ct['ma_thuoc']);
                    $thanhTien = $thuoc->don_gia * $ct['so_luong'];
                    $tongTien += $thanhTien;

                    ChiTietDonThuoc::create([
                        'ma_don_thuoc' => $dt->ma_don_thuoc,
                        'ma_thuoc'     => $ct['ma_thuoc'],
                        'so_luong'     => $ct['so_luong'],
                        'lieu_luong'   => $ct['lieu_luong'],
                        'thanh_tien'   => $thanhTien,
                    ]);
                    $thuoc->decrement('so_luong_ton', $ct['so_luong']);
                }
                $dt->tong_tien = $tongTien;
                $dt->save();
                return $dt;
            });

            return response()->json(['status' => 'success', 'message' => 'Lưu đơn thuốc thành công', 'data' => $donThuoc->fresh()->load('chiTiet.thuoc')], 201);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 400);
        }
    }

    public function show($id)
    {
        $dt = DonThuoc::with('chiTiet.thuoc', 'phienKham.lichKham.hoSo.benhNhan')->find($id);
        if (!$dt) return response()->json(['status' => 'error', 'message' => 'Không tìm thấy đơn thuốc'], 404);
        return response()->json(['status' => 'success', 'data' => $dt]);
    }
}