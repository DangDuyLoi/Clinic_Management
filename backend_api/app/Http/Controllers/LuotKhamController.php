<?php

namespace App\Http\Controllers;

use App\Models\LuotKham;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Exception;
use Carbon\Carbon;
use App\Jobs\SendBookingEmailJob; // Thư viện để chạy Queue gửi Email (Bước 4)

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

    // 3. API Bệnh nhân: Đặt lịch khám (Có xử lý Race Condition & Validation nâng cao)
    public function datLich(Request $request)
    {
        // BƯỚC 1: Validation nâng cao - Chặn đặt lịch trong quá khứ
        $validator = Validator::make($request->all(), [
            'ma_ho_so' => 'required|integer',
            'ma_bac_si' => 'required|integer',
            'thoi_gian_den_kham' => 'required|date_format:Y-m-d H:i:s|after:now', // after:now chặn giờ quá khứ
        ], [
            'thoi_gian_den_kham.after' => 'Thời gian khám phải lớn hơn thời gian hiện tại.',
            'thoi_gian_den_kham.date_format' => 'Định dạng thời gian không hợp lệ (Chuẩn: YYYY-MM-DD HH:MM:SS).'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Dữ liệu không hợp lệ', 
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $result = DB::transaction(function () use ($request) {
                
                // XỬ LÝ RACE CONDITION
                $soNguoiDaDat = LuotKham::where('ma_bac_si', $request->ma_bac_si)
                                        ->where('thoi_gian_den_kham', $request->thoi_gian_den_kham)
                                        ->lockForUpdate()
                                        ->count();

                $gioiHanLuotKham = 1; 

                if ($soNguoiDaDat >= $gioiHanLuotKham) {
                    throw new Exception('Khung giờ này của bác sĩ đã có người đặt hoặc đã đầy. Vui lòng chọn giờ khác.');
                }

                // Lưu vào database
                $luotKhamMoi = LuotKham::create([
                    'ma_ho_so' => $request->ma_ho_so,
                    'ma_bac_si' => $request->ma_bac_si,
                    'thoi_gian_den_kham' => $request->thoi_gian_den_kham,
                    'trang_thai' => 'cho_xac_nhan', 
                    'chan_doan' => null
                ]);

                // BƯỚC 4: Đẩy tác vụ gửi Email vào Queue để chạy ngầm, không làm lag API
                SendBookingEmailJob::dispatch($luotKhamMoi);

                return $luotKhamMoi;
            });

            return response()->json([
                'message' => 'Đặt lịch thành công!', 
                'data' => $result
            ], 201);

        } catch (Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ], 400);
        }
    }

    // 4. API Bệnh nhân: Lấy danh sách khung giờ trống của Bác sĩ trong 1 ngày
    public function layGioTrong(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ma_bac_si' => 'required|integer',
            'ngay_kham' => 'required|date_format:Y-m-d'
        ]);

        if ($validator->fails()) {
            return response()->json(['message' => 'Dữ liệu không hợp lệ', 'errors' => $validator->errors()], 422);
        }

        $maBacSi = $request->ma_bac_si;
        $ngayKham = $request->ngay_kham;

        $khungGioMacDinh = [
            '08:00:00', '08:30:00', '09:00:00', '09:30:00',
            '10:00:00', '10:30:00', '11:00:00', '11:30:00',
            '13:00:00', '13:30:00', '14:00:00', '14:30:00',
            '15:00:00', '15:30:00', '16:00:00', '16:30:00'
        ];

        $cacLichDaDat = LuotKham::where('ma_bac_si', $maBacSi)
            ->whereDate('thoi_gian_den_kham', $ngayKham)
            ->where('trang_thai', '!=', 'da_huy')
            ->pluck('thoi_gian_den_kham')
            ->map(function ($datetime) {
                return Carbon::parse($datetime)->format('H:i:s');
            })
            ->toArray();

        $gioTrong = array_values(array_diff($khungGioMacDinh, $cacLichDaDat));

        return response()->json([
            'message' => 'Lấy danh sách giờ trống thành công',
            'ma_bac_si' => $maBacSi,
            'ngay_kham' => $ngayKham,
            'danh_sach_gio_trong' => $gioTrong
        ], 200);
    }
}
