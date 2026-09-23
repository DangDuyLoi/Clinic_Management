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
}   