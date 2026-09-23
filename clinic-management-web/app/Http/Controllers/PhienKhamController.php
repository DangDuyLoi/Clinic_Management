<?php

namespace App\Http\Controllers;

use App\Models\PhienKham;
use App\Models\LichKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class PhienKhamController extends Controller
{
    /* ============================================================
       GET /api/phien-kham
       Query: ?ngay=2026-09-21&ma_bs=1
       ============================================================ */
    public function index(Request $request)
    {
        $query = PhienKham::with(['lichKham.benhNhan', 'lichKham.bacSi', 'chiDinh.dichVu']);

        if ($ngay = $request->query('ngay')) {
            $query->whereHas('lichKham', function ($q) use ($ngay) {
                $q->where('ngay_kham', $ngay);
            });
        }

        if ($maBs = $request->query('ma_bs')) {
            $query->whereHas('lichKham', function ($q) use ($maBs) {
                $q->where('ma_bs', $maBs);
            });
        }

        return response()->json([
            'status' => 'success',
            'data'   => $query->orderBy('ma_phien_kham', 'desc')->paginate(20),
        ]);
    }

    /* ============================================================
       GET /api/phien-kham/by-lich/{maLich}
       Lấy phiên khám theo lịch khám — nếu chưa có, tự tạo mới
       ============================================================ */
    public function getByLichKham($maLich)
    {
        $lich = LichKham::with(['benhNhan', 'bacSi.chuyenKhoa', 'khungGio'])->find($maLich);

        if (!$lich) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy lịch khám',
            ], 404);
        }

        $phienKham = PhienKham::with([
            'chiDinh.dichVu',
            'donThuoc.chiTiet.thuoc',
            'hoaDon',
        ])->where('ma_lich_dat', $maLich)->first();

        // Nếu chưa có → tạo mới + đổi trạng thái lịch thành 'DangKham'
        if (!$phienKham) {
            $phienKham = PhienKham::create([
                'ma_lich_dat' => $maLich,
                'trang_thai'  => 'ChoCanLamSang',
            ]);

            $lich->trang_thai = 'DangKham';
            $lich->save();
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'lich_kham'  => $lich,
                'phien_kham' => $phienKham->fresh()->load(['chiDinh.dichVu', 'donThuoc.chiTiet.thuoc']),
            ],
        ]);
    }

    /* ============================================================
       GET /api/phien-kham/{id}
       ============================================================ */
    public function show($id)
    {
        $pk = PhienKham::with([
            'lichKham.benhNhan',
            'lichKham.bacSi.chuyenKhoa',
            'chiDinh.dichVu',
            'donThuoc.chiTiet.thuoc',
            'hoaDon',
        ])->find($id);

        if (!$pk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $pk,
        ]);
    }

    /* ============================================================
       PUT /api/phien-kham/{id}
       Cập nhật chẩn đoán
       Body: { chan_doan_so_bo?, chan_doan_cuoi_cung?, ghi_chu_y_te? }
       ============================================================ */
    public function update(Request $request, $id)
    {
        $pk = PhienKham::find($id);

        if (!$pk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        $data = $request->validate([
            'chan_doan_so_bo'     => 'nullable|string|max:2000',
            'chan_doan_cuoi_cung' => 'nullable|string|max:2000',
            'ghi_chu_y_te'        => 'nullable|string|max:2000',
            'trang_thai'          => 'nullable|in:ChoCanLamSang,ChoKetLuan,ChoThanhToan,HoanThanh',
        ]);

        $pk->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật chẩn đoán thành công',
            'data'    => $pk->fresh(),
        ]);
    }

    /* ============================================================
       POST /api/phien-kham/{id}/finish
       Hoàn thành phiên khám — đổi trạng thái cả LichKham
       ============================================================ */
    public function finish($id)
    {
        $pk = PhienKham::with('lichKham')->find($id);

        if (!$pk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        try {
            DB::transaction(function () use ($pk) {
                $pk->trang_thai = 'HoanThanh';
                $pk->save();

                if ($pk->lichKham) {
                    $pk->lichKham->trang_thai = 'HoanThanh';
                    $pk->lichKham->save();
                }
            });

            return response()->json([
                'status'  => 'success',
                'message' => 'Đã hoàn thành phiên khám',
                'data'    => $pk->fresh(),
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Lỗi: ' . $e->getMessage(),
            ], 500);
        }
    }

    /* ============================================================
       POST /api/phien-kham/{id}/chi-dinh
       Bác sĩ chỉ định dịch vụ cận lâm sàng
       Body: { ma_dich_vu, ket_qua_chi_tiet? }
       ============================================================ */
    public function addChiDinh(Request $request, $id)
    {
        $data = $request->validate([
            'ma_dich_vu'       => 'required|integer|exists:DichVu,ma_dich_vu',
            'ket_qua_chi_tiet' => 'nullable|string',
        ]);

        $pk = PhienKham::find($id);

        if (!$pk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phiên khám',
            ], 404);
        }

        $chiDinh = \App\Models\ChiDinhDichVu::create([
            'ma_phien_kham'    => $id,
            'ma_dich_vu'       => $data['ma_dich_vu'],
            'ket_qua_chi_tiet' => $data['ket_qua_chi_tiet'] ?? null,
            'trang_thai'       => 'ChoThucHien',
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã thêm chỉ định',
            'data'    => $chiDinh->load('dichVu'),
        ], 201);
    }

    /* ============================================================
       DELETE /api/phien-kham/chi-dinh/{id}
       ============================================================ */
    public function removeChiDinh($id)
    {
        $cd = \App\Models\ChiDinhDichVu::find($id);

        if (!$cd) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy chỉ định',
            ], 404);
        }

        $cd->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa chỉ định',
        ]);
    }
}