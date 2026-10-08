<?php

namespace App\Http\Controllers;

use App\Models\BenhNhan;
use Illuminate\Http\Request;

class BenhNhanController extends Controller
{
    /* ============================================================
       GET /api/benh-nhan
       Query: ?q=search&gioi_tinh=Nam&per_page=20
       ============================================================ */
    public function index(Request $request)
    {
        $query = BenhNhan::with('taiKhoan');

        if ($q = $request->query('q')) {
            $query->where(function ($sub) use ($q) {
                $sub->where('ho_ten', 'like', "%{$q}%")
                    ->orWhere('so_dien_thoai', 'like', "%{$q}%")
                    ->orWhere('cccd', 'like', "%{$q}%");
            });
        }

        if ($gt = $request->query('gioi_tinh')) {
            $query->where('gioi_tinh', $gt);
        }

        $perPage = (int) $request->query('per_page', 20);
        $perPage = max(1, min($perPage, 100));

        return response()->json([
            'status' => 'success',
            'data'   => $query->orderBy('ma_bn', 'desc')->paginate($perPage),
        ]);
    }

    /* ============================================================
       POST /api/benh-nhan
       Tạo bệnh nhân (có thể là khách vãng lai — ma_tk = null)
       Body: { ho_ten, ngay_sinh?, gioi_tinh?, so_dien_thoai, ... }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ho_ten'                 => 'required|string|min:2|max:100',
            'ngay_sinh'              => 'nullable|date|before:today',
            'gioi_tinh'              => 'nullable|in:Nam,Nu,Khac',
            'so_dien_thoai'          => 'required|string|max:15|unique:BenhNhan,so_dien_thoai',
            'email'                  => 'nullable|email|max:100',
            'cccd'                   => 'nullable|string|max:20|unique:BenhNhan,cccd',
            'dia_chi'                => 'nullable|string|max:255',
            'nguoi_lien_he_khan_cap' => 'nullable|string|max:100',
            'tien_su_benh'           => 'nullable|string',
            'di_ung'                 => 'nullable|string',
            'nhom_mau'               => 'nullable|string|max:5',
            'ma_tk'                  => 'nullable|integer|exists:TaiKhoan,ma_tk',
        ], [
            'ho_ten.required'        => 'Vui lòng nhập họ tên',
            'so_dien_thoai.required' => 'Vui lòng nhập số điện thoại',
            'so_dien_thoai.unique'   => 'Số điện thoại đã tồn tại',
            'cccd.unique'            => 'CCCD đã tồn tại',
        ]);

        $bn = BenhNhan::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tạo hồ sơ bệnh nhân thành công',
            'data'    => $bn,
        ], 201);
    }

    /* ============================================================
       GET /api/benh-nhan/{id}
       ============================================================ */
    public function show($id)
    {
        $bn = BenhNhan::with(['taiKhoan', 'lichKham' => function ($q) {
            $q->orderBy('ngay_kham', 'desc')->limit(10);
        }])->find($id);

        if (!$bn) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $bn,
        ]);
    }

    /* ============================================================
       PUT /api/benh-nhan/{id}
       ============================================================ */
    public function update(Request $request, $id)
    {
        $bn = BenhNhan::find($id);

        if (!$bn) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        $data = $request->validate([
            'ho_ten'                 => 'sometimes|string|min:2|max:100',
            'ngay_sinh'              => 'nullable|date|before:today',
            'gioi_tinh'              => 'nullable|in:Nam,Nu,Khac',
            'so_dien_thoai'          => 'sometimes|string|max:15|unique:BenhNhan,so_dien_thoai,' . $id . ',ma_bn',
            'email'                  => 'nullable|email|max:100',
            'cccd'                   => 'nullable|string|max:20|unique:BenhNhan,cccd,' . $id . ',ma_bn',
            'dia_chi'                => 'nullable|string|max:255',
            'nguoi_lien_he_khan_cap' => 'nullable|string|max:100',
            'tien_su_benh'           => 'nullable|string',
            'di_ung'                 => 'nullable|string',
            'nhom_mau'               => 'nullable|string|max:5',
        ], [
            'so_dien_thoai.unique' => 'Số điện thoại đã tồn tại',
            'cccd.unique'          => 'CCCD đã tồn tại',
        ]);

        $bn->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $bn->fresh(),
        ]);
    }

    /* ============================================================
       DELETE /api/benh-nhan/{id}
       ============================================================ */
    public function destroy($id)
    {
        $bn = BenhNhan::find($id);

        if (!$bn) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        // Chặn xóa nếu còn lịch khám chưa hoàn thành
        $soLichChuaXong = $bn->lichKham()
            ->whereNotIn('trang_thai', ['HoanThanh', 'DaHuy'])
            ->count();

        if ($soLichChuaXong > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa. Bệnh nhân còn {$soLichChuaXong} lịch khám chưa hoàn thành.",
            ], 400);
        }

        $bn->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa bệnh nhân',
        ]);
    }
        /**
     * GET /api/benh-nhan/{id}/lich-su-kham
     * Lịch sử khám của bệnh nhân (tất cả phiên khám đã hoàn thành)
     */
    public function lichSuKham($id)
    {
        $benhNhan = BenhNhan::find($id);
        if (!$benhNhan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        // Lấy tất cả phiên khám của bệnh nhân
        $lichSu = \App\Models\PhienKham::with([
                'lichKham.bacSi.chuyenKhoa',
                'chiDinh.dichVu',
                'donThuoc.chiTiet.thuoc',
                'hoaDon',
            ])
            ->whereHas('lichKham', function ($q) use ($id) {
                $q->where('ma_bn', $id);
            })
            ->orderBy('ma_phien_kham', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => [
                'benh_nhan' => [
                    'ma_bn'         => $benhNhan->ma_bn,
                    'ho_ten'        => $benhNhan->ho_ten,
                    'ngay_sinh'     => $benhNhan->ngay_sinh,
                    'gioi_tinh'     => $benhNhan->gioi_tinh,
                    'so_dien_thoai' => $benhNhan->so_dien_thoai,
                    'cccd'          => $benhNhan->cccd,
                    'dia_chi'       => $benhNhan->dia_chi,
                    'nhom_mau'      => $benhNhan->nhom_mau,
                    'di_ung'        => $benhNhan->di_ung,
                    'tien_su_benh'  => $benhNhan->tien_su_benh,
                ],
                'tong_lan_kham' => $lichSu->count(),
                'lich_su'       => $lichSu,
            ],
        ]);
    }

    /**
     * GET /api/benh-nhan/{id}/thong-ke
     * Thống kê nhanh về bệnh nhân
     */
    public function thongKe($id)
    {
        $benhNhan = BenhNhan::find($id);
        if (!$benhNhan) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy bệnh nhân',
            ], 404);
        }

        $lichKham = \App\Models\LichKham::where('ma_bn', $id);

        $tongLanKham      = (clone $lichKham)->where('trang_thai', 'HoanThanh')->count();
        $tongLanHuy       = (clone $lichKham)->where('trang_thai', 'DaHuy')->count();
        $lanKhamGanNhat   = (clone $lichKham)->where('trang_thai', 'HoanThanh')
                                ->orderBy('ngay_kham', 'desc')->first();
        $lanKhamSapToi    = (clone $lichKham)->whereIn('trang_thai', ['ChoXacNhan', 'ChoKham'])
                                ->where('ngay_kham', '>=', now()->toDateString())
                                ->orderBy('ngay_kham')->first();

        // Tổng tiền đã thanh toán
        $tongTien = \App\Models\HoaDon::whereHas('phienKham.lichKham', function ($q) use ($id) {
                $q->where('ma_bn', $id);
            })
            ->where('trang_thai', 'DaThanhToan')
            ->sum('tong_cong');

        return response()->json([
            'status' => 'success',
            'data'   => [
                'tong_lan_kham'    => $tongLanKham,
                'tong_lan_huy'     => $tongLanHuy,
                'tong_tien'        => (float) $tongTien,
                'lan_kham_gan_nhat'=> $lanKhamGanNhat ? [
                    'ngay_kham' => $lanKhamGanNhat->ngay_kham,
                    'chan_doan' => $lanKhamGanNhat->phienKham?->chan_doan_cuoi_cung,
                ] : null,
                'lan_kham_sap_toi' => $lanKhamSapToi ? [
                    'ma_lich_dat' => $lanKhamSapToi->ma_lich_dat,
                    'ngay_kham'   => $lanKhamSapToi->ngay_kham,
                    'trang_thai'  => $lanKhamSapToi->trang_thai,
                ] : null,
            ],
        ]);
    }
}   