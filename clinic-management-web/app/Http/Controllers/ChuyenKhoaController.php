<?php

namespace App\Http\Controllers;

use App\Models\ChuyenKhoa;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ChuyenKhoaController extends Controller
{
    /* ============================================================
       GET /api/chuyen-khoa
       Query: ?q=search
       ============================================================ */
    public function index(Request $request)
    {
        $query = ChuyenKhoa::withCount('bacSi');

        // Tìm kiếm theo tên
        if ($q = $request->query('q')) {
            $query->where('ten_chuyen_khoa', 'like', "%{$q}%");
        }

        $data = $query->orderBy('ten_chuyen_khoa')->get();

        return response()->json([
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /* ============================================================
       POST /api/chuyen-khoa
       Body: { ten_chuyen_khoa, mo_ta? }
       ============================================================ */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ten_chuyen_khoa' => 'required|string|min:2|max:100|unique:ChuyenKhoa,ten_chuyen_khoa',
            'mo_ta'           => 'nullable|string|max:1000',
        ], [
            'ten_chuyen_khoa.required' => 'Vui lòng nhập tên chuyên khoa',
            'ten_chuyen_khoa.unique'   => 'Tên chuyên khoa đã tồn tại',
            'ten_chuyen_khoa.min'      => 'Tên chuyên khoa phải có ít nhất 2 ký tự',
            'ten_chuyen_khoa.max'      => 'Tên chuyên khoa không quá 100 ký tự',
        ]);

        $ck = ChuyenKhoa::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Thêm chuyên khoa thành công',
            'data'    => $ck,
        ], 201);
    }

    /* ============================================================
       GET /api/chuyen-khoa/{id}
       ============================================================ */
    public function show($id)
    {
        $ck = ChuyenKhoa::with(['bacSi.chuyenKhoa'])->find($id);

        if (!$ck) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy chuyên khoa',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $ck,
        ]);
    }

    /* ============================================================
       PUT /api/chuyen-khoa/{id}
       Body: { ten_chuyen_khoa?, mo_ta? }
       ============================================================ */
    public function update(Request $request, $id)
    {
        $ck = ChuyenKhoa::find($id);

        if (!$ck) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy chuyên khoa',
            ], 404);
        }

        $data = $request->validate([
            'ten_chuyen_khoa' => [
                'sometimes', 'string', 'min:2', 'max:100',
                Rule::unique('ChuyenKhoa', 'ten_chuyen_khoa')->ignore($id, 'ma_chuyen_khoa'),
            ],
            'mo_ta' => 'nullable|string|max:1000',
        ], [
            'ten_chuyen_khoa.unique' => 'Tên chuyên khoa đã tồn tại',
        ]);

        $ck->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $ck->fresh(),
        ]);
    }

    /* ============================================================
       DELETE /api/chuyen-khoa/{id}
       Chặn xóa nếu còn bác sĩ thuộc chuyên khoa
       ============================================================ */
    public function destroy($id)
    {
        $ck = ChuyenKhoa::find($id);

        if (!$ck) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy chuyên khoa',
            ], 404);
        }

        // Kiểm tra còn bác sĩ không
        $soBacSi = $ck->bacSi()->count();
        if ($soBacSi > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa. Còn {$soBacSi} bác sĩ thuộc chuyên khoa này.",
            ], 400);
        }

        $ck->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa chuyên khoa',
        ]);
    }
}