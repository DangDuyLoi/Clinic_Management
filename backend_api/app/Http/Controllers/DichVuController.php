<?php

namespace App\Http\Controllers;

use App\Models\DichVu;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class DichVuController extends Controller
{
    // 1. Lấy danh sách dịch vụ đang hoạt động
    public function index()
    {
        $dichVus = DichVu::where('trang_thai', true)->get();
        return $this->successResponse($dichVus, 'Lấy danh sách dịch vụ thành công!');
    }

    // 2. Thêm mới dịch vụ
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ten_dich_vu' => 'required|string|max:255',
            'don_gia' => 'required|numeric|min:0',
            'thoi_gian_thuc_hien' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Dữ liệu đầu vào không hợp lệ', 422, $validator->errors());
        }

        $dichVu = DichVu::create([
            'ten_dich_vu' => $request->ten_dich_vu,
            'don_gia' => $request->don_gia,
            'thoi_gian_thuc_hien' => $request->thoi_gian_thuc_hien,
            'trang_thai' => true
        ]);

        return $this->successResponse($dichVu, 'Thêm dịch vụ mới thành công!', 201);
    }

    // 3. Cập nhật thông tin dịch vụ
    public function update(Request $request, $id)
    {
        $dichVu = DichVu::find($id);
        if (!$dichVu) {
            return $this->errorResponse('Không tìm thấy dịch vụ', 404);
        }

        $validator = Validator::make($request->all(), [
            'ten_dich_vu' => 'string|max:255',
            'don_gia' => 'numeric|min:0',
            'thoi_gian_thuc_hien' => 'integer|min:1',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Dữ liệu cập nhật không hợp lệ', 422, $validator->errors());
        }

        $dichVu->update($request->all());

        return $this->successResponse($dichVu, 'Cập nhật dịch vụ thành công!');
    }

    // 4. Ngừng cung cấp dịch vụ (Xóa mềm)
    public function destroy($id)
    {
        $dichVu = DichVu::find($id);
        if (!$dichVu) {
            return $this->errorResponse('Không tìm thấy dịch vụ', 404);
        }

        $dichVu->update(['trang_thai' => false]);

        return $this->successResponse(null, 'Đã ngừng cung cấp dịch vụ này!');
    }
}
