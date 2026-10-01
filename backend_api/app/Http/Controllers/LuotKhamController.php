<?php

namespace App\Http\Controllers;

use App\Models\LuotKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Exception;

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

    // 3. API Bệnh nhân: Đặt lịch khám (Có xử lý Race Condition)
    public function datLich(Request $request)
    {
        // 1. Kiểm tra dữ liệu đầu vào
        $validator = Validator::make($request->all(), [
            'ma_ho_so' => 'required|integer',
            'ma_bac_si' => 'required|integer',
            'thoi_gian_den_kham' => 'required|date_format:Y-m-d H:i:s',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Dữ liệu không hợp lệ', 
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // 2. Sử dụng Database Transaction để đảm bảo tính toàn vẹn dữ liệu
            $result = DB::transaction(function () use ($request) {
                
                // 3. XỬ LÝ RACE CONDITION (Pessimistic Locking)
                // lockForUpdate() sẽ "khóa" dữ liệu trong khung giờ này lại. 
                // Nếu có 2 người bấm đặt cùng 1 mili-giây, người thứ 2 phải chờ người thứ 1 xử lý xong.
                $soNguoiDaDat = LuotKham::where('ma_bac_si', $request->ma_bac_si)
                                        ->where('thoi_gian_den_kham', $request->thoi_gian_den_kham)
                                        ->lockForUpdate()
                                        ->count();

                // Giả sử mỗi khung giờ bác sĩ chỉ nhận 1 bệnh nhân
                $gioiHanLuotKham = 1; 

                if ($soNguoiDaDat >= $gioiHanLuotKham) {
                    throw new Exception('Khung giờ này của bác sĩ đã có người đặt hoặc đã đầy. Vui lòng chọn giờ khác.');
                }

                // 4. Khung giờ trống -> Tiến hành lưu vào database
                $luotKhamMoi = LuotKham::create([
                    'ma_ho_so' => $request->ma_ho_so,
                    'ma_bac_si' => $request->ma_bac_si,
                    'thoi_gian_den_kham' => $request->thoi_gian_den_kham,
                    'trang_thai' => 'cho_xac_nhan', 
                    'chan_doan' => null
                ]);

                return $luotKhamMoi;
            });

            // Thành công
            return response()->json([
                'message' => 'Đặt lịch thành công!', 
                'data' => $result
            ], 201);

        } catch (Exception $e) {
            // Bắt lỗi khi khung giờ đã đầy hoặc lỗi DB
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }
}
