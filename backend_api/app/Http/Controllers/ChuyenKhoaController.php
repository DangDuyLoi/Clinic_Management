<?php

namespace App\Http\Controllers;

use App\Models\ChuyenKhoa;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChuyenKhoaController extends Controller
{
    // Lấy danh sách chuyên khoa
    public function index()
    {
        $chuyenKhoas = ChuyenKhoa::where('trang_thai', true)->get();

        // Dùng cấu trúc mới thay vì return response()->json($chuyenKhoas);
        return $this->successResponse($chuyenKhoas, 'Lấy danh sách chuyên khoa thành công!');
    }

    // Thêm mới chuyên khoa
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ten_chuyen_khoa' => 'required|string|max:255',
            'mo_ta' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Dữ liệu đầu vào không hợp lệ', 422, $validator->errors());
        }

        $chuyenKhoa = ChuyenKhoa::create([
            'ten_chuyen_khoa' => $request->ten_chuyen_khoa,
            'mo_ta' => $request->mo_ta,
            'trang_thai' => true
        ]);

        return $this->successResponse($chuyenKhoa, 'Thêm chuyên khoa thành công!', 201);
    }

    // Cập nhật chuyên khoa
    public function update(Request $request, $id)
    {
        $chuyenKhoa = ChuyenKhoa::find($id);
        if (!$chuyenKhoa) {
            return $this->errorResponse('Không tìm thấy chuyên khoa này', 404);
        }

        $validator = Validator::make($request->all(), [
            'ten_chuyen_khoa' => 'string|max:255',
            'mo_ta' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Dữ liệu cập nhật không hợp lệ', 422, $validator->errors());
        }

        $chuyenKhoa->update($request->all());

        return $this->successResponse($chuyenKhoa, 'Cập nhật chuyên khoa thành công!');
    }

    // Xóa (Ẩn) chuyên khoa
    public function destroy($id)
    {
        $chuyenKhoa = ChuyenKhoa::find($id);
        if (!$chuyenKhoa) {
            return $this->errorResponse('Không tìm thấy chuyên khoa', 404);
        }

        $chuyenKhoa->update(['trang_thai' => false]);

        return $this->successResponse(null, 'Đã ngừng hoạt động chuyên khoa này!');
    }
}
