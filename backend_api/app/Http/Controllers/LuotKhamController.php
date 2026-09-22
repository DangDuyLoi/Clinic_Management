<?php

namespace App\Http\Controllers;

use App\Models\LuotKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LuotKhamController extends Controller
{
    // 1. API Lễ tân: Tiếp nhận bệnh nhân (Chuyển trạng thái sang "Chờ khám")
    public function tiepNhan(Request $request, $id)
    {
        $luotKham = LuotKham::find($id);
        if (!$luotKham) {
            return $this->errorResponse('Không tìm thấy lượt khám', 404);
        }

        $luotKham->update(['trang_thai' => 'cho_kham']);

        return $this->successResponse($luotKham, 'Đã tiếp nhận bệnh nhân, chuyển vào hàng đợi chờ khám.');
    }

    // 2. API Bác sĩ: Cập nhật chẩn đoán và hoàn thành khám
    public function capNhatKetQua(Request $request, $id)
    {
        $luotKham = LuotKham::find($id);
        if (!$luotKham) {
            return $this->errorResponse('Không tìm thấy lượt khám', 404);
        }

        $validator = Validator::make($request->all(), [
            'chan_doan' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->errorResponse('Dữ liệu không hợp lệ', 422, $validator->errors());
        }

        $luotKham->update([
            'chan_doan' => $request->chan_doan,
            'trang_thai' => 'hoan_thanh'
        ]);

        return $this->successResponse($luotKham, 'Cập nhật kết quả khám thành công!');
    }
}
