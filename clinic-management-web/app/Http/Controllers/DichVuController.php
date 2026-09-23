<?php

namespace App\Http\Controllers;

use App\Models\DichVu;
use Illuminate\Http\Request;

class DichVuController extends Controller
{
    /* ============================================================
       GET /api/dich-vu
       Query: ?q=search&min_gia=100000&max_gia=500000
       ============================================================ */
    public function index(Request $request)
    {
        $query = DichVu::query();

        // Tìm kiếm theo tên
        if ($q = $request->query('q')) {
            $query->where('ten_dich_vu', 'like', "%{$q}%");
        }

        // Lọc theo khoảng giá
        if ($minGia = $request->query('min_gia')) {
            $query->where('don_gia', '>=', (float) $minGia);
        }
        if ($maxGia = $request->query('max_gia')) {
            $query->where('don_gia', '<=', (float) $maxGia);
        }

        // Sắp xếp
        $sortBy = $request->query('sort_by', 'ten_dich_vu');
        $sortDir = $request->query('sort_dir', 'asc');
        $allowedSort = ['ten_dich_vu', 'don_gia'];
        if (in_array($sortBy, $allowedSort, true)) {
            $query->orderBy($sortBy, $sortDir === 'desc' ? 'desc' : 'asc');
        }

        return response()->json([
            'status' => 'success',
            'data'   => $query->get(),
        ]);
    }

    /* ============================================================
       POST /api/dich-vu
       Body: { ten_dich_vu, don_gia, mo_ta? }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ten_dich_vu' => 'required|string|min:2|max:150|unique:DichVu,ten_dich_vu',
            'don_gia'     => 'required|numeric|min:0|max:999999999',
            'mo_ta'       => 'nullable|string|max:1000',
        ], [
            'ten_dich_vu.required' => 'Vui lòng nhập tên dịch vụ',
            'ten_dich_vu.unique'   => 'Tên dịch vụ đã tồn tại',
            'ten_dich_vu.min'      => 'Tên dịch vụ phải có ít nhất 2 ký tự',
            'don_gia.required'     => 'Vui lòng nhập đơn giá',
            'don_gia.numeric'      => 'Đơn giá phải là số',
            'don_gia.min'          => 'Đơn giá phải >= 0',
        ]);

        $dv = DichVu::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Thêm dịch vụ thành công',
            'data'    => $dv,
        ], 201);
    }

    /* ============================================================
       GET /api/dich-vu/{id}
       ============================================================ */
    public function show($id)
    {
        $dv = DichVu::find($id);

        if (!$dv) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy dịch vụ',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $dv,
        ]);
    }

    /* ============================================================
       PUT /api/dich-vu/{id}
       Body: { ten_dich_vu?, don_gia?, mo_ta? }
       ============================================================ */
    public function update(Request $request, $id)
    {
        $dv = DichVu::find($id);

        if (!$dv) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy dịch vụ',
            ], 404);
        }

        $data = $request->validate([
            'ten_dich_vu' => 'sometimes|string|min:2|max:150|unique:DichVu,ten_dich_vu,' . $id . ',ma_dich_vu',
            'don_gia'     => 'sometimes|numeric|min:0|max:999999999',
            'mo_ta'       => 'nullable|string|max:1000',
        ], [
            'ten_dich_vu.unique' => 'Tên dịch vụ đã tồn tại',
            'don_gia.numeric'    => 'Đơn giá phải là số',
        ]);

        $dv->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $dv->fresh(),
        ]);
    }

    /* ============================================================
       DELETE /api/dich-vu/{id}
       Chặn xóa nếu dịch vụ đã được chỉ định cho phiên khám
       ============================================================ */
    public function destroy($id)
    {
        $dv = DichVu::find($id);

        if (!$dv) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy dịch vụ',
            ], 404);
        }

        // Kiểm tra xem dịch vụ có đang được sử dụng không
        $soLanSuDung = \App\Models\ChiDinhDichVu::where('ma_dich_vu', $id)->count();
        if ($soLanSuDung > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa. Dịch vụ đã được chỉ định {$soLanSuDung} lần.",
            ], 400);
        }

        $dv->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa dịch vụ',
        ]);
    }
}