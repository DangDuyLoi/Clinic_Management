<?php

namespace App\Http\Controllers;

use App\Models\HoaDon;
use App\Models\PhienKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class HoaDonController extends Controller
{
    /* ============================================================
       GET /api/hoa-don
       Query: ?trang_thai=ChuaThanhToan&ngay=2026-09-21&per_page=20
       ============================================================ */
    public function index(Request $request)
    {
        $query = HoaDon::with(['phienKham.lichKham.benhNhan', 'phienKham.lichKham.bacSi']);

        if ($tt = $request->query('trang_thai')) {
            $query->where('trang_thai', $tt);
        }

        if ($ngay = $request->query('ngay')) {
            $query->whereDate('ngay_tao', $ngay);
        }

        $perPage = (int) $request->query('per_page', 20);
        $perPage = max(1, min($perPage, 100));

        return response()->json([
            'status' => 'success',
            'data'   => $query->orderBy('ma_hoa_don', 'desc')->paginate($perPage),
        ]);
    }

    /* ============================================================
       GET /api/hoa-don/{id}
       ============================================================ */
    public function show($id)
    {
        $hd = HoaDon::with([
            'phienKham.lichKham.benhNhan',
            'phienKham.lichKham.bacSi.chuyenKhoa',
            'phienKham.chiDinh.dichVu',
            'phienKham.donThuoc.chiTiet.thuoc',
        ])->find($id);

        if (!$hd) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy hóa đơn',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $hd,
        ]);
    }

    /* ============================================================
       POST /api/hoa-don
       Tạo hóa đơn cho phiên khám
       Body: {
         ma_phien_kham, tien_kham_benh?, tien_dich_vu?, tien_thuoc?
       }
       Hệ thống tự tính tổng cộng
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ma_phien_kham'  => 'required|integer|exists:PhienKham,ma_phien_kham|unique:HoaDon,ma_phien_kham',
            'tien_kham_benh' => 'nullable|numeric|min:0',
            'tien_dich_vu'   => 'nullable|numeric|min:0',
            'tien_thuoc'     => 'nullable|numeric|min:0',
        ], [
            'ma_phien_kham.required' => 'Vui lòng chọn phiên khám',
            'ma_phien_kham.unique'   => 'Phiên khám này đã có hóa đơn',
            'ma_phien_kham.exists'   => 'Phiên khám không tồn tại',
        ]);

        $tienKham  = (float) ($data['tien_kham_benh'] ?? 0);
        $tienDv    = (float) ($data['tien_dich_vu'] ?? 0);
        $tienThuoc = (float) ($data['tien_thuoc'] ?? 0);
        $tongCong  = $tienKham + $tienDv + $tienThuoc;

        $hd = HoaDon::create([
            'ma_phien_kham'  => $data['ma_phien_kham'],
            'tien_kham_benh' => $tienKham,
            'tien_dich_vu'   => $tienDv,
            'tien_thuoc'     => $tienThuoc,
            'tong_cong'      => $tongCong,
            'trang_thai'     => 'ChuaThanhToan',
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Tạo hóa đơn thành công',
            'data'    => $hd->load('phienKham.lichKham.benhNhan'),
        ], 201);
    }

    /* ============================================================
       PUT /api/hoa-don/{id}/pay
       Xác nhận thanh toán
       Body: { phuong_thuc: TienMat|Momo|VNPay|ChuyenKhoan }
       ============================================================ */
    public function pay(Request $request, $id)
    {
        $request->validate([
            'phuong_thuc' => 'required|in:TienMat,Momo,VNPay,ChuyenKhoan',
        ], [
            'phuong_thuc.required' => 'Vui lòng chọn phương thức thanh toán',
            'phuong_thuc.in'       => 'Phương thức không hợp lệ',
        ]);

        $hd = HoaDon::find($id);

        if (!$hd) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy hóa đơn',
            ], 404);
        }

        if ($hd->trang_thai === 'DaThanhToan') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Hóa đơn đã được thanh toán',
            ], 400);
        }

        if ($hd->trang_thai === 'DaHuy') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Hóa đơn đã bị hủy',
            ], 400);
        }

        $hd->trang_thai      = 'DaThanhToan';
        $hd->phuong_thuc     = $request->phuong_thuc;
        $hd->ngay_thanh_toan = now();
        $hd->save();

        return response()->json([
            'status'  => 'success',
            'message' => 'Xác nhận thanh toán thành công',
            'data'    => $hd,
        ]);
    }

    /* ============================================================
       PUT /api/hoa-don/{id}/cancel
       Hủy hóa đơn
       ============================================================ */
    public function cancel($id)
    {
        $hd = HoaDon::find($id);

        if (!$hd) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy hóa đơn',
            ], 404);
        }

        if ($hd->trang_thai === 'DaThanhToan') {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể hủy hóa đơn đã thanh toán',
            ], 400);
        }

        $hd->trang_thai = 'DaHuy';
        $hd->save();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã hủy hóa đơn',
            'data'    => $hd,
        ]);
    }
}