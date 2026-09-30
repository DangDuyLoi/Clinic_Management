<?php

namespace App\Http\Controllers;

use App\Models\CaLamViec;
use App\Models\KhungGio;
use Illuminate\Http\Request;

class CaLamViecController extends Controller
{
    /**
     * GET /api/ca-lam-viec
     */
    public function index()
    {
        $data = CaLamViec::withCount('khungGio')
            ->orderBy('gio_bat_dau')
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /**
     * POST /api/ca-lam-viec
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ten_ca'          => 'required|string|max:50',
            'gio_bat_dau'     => 'required|date_format:H:i:s',
            'gio_ket_thuc'    => 'required|date_format:H:i:s|after:gio_bat_dau',
            'luot_kham_toi_da'=> 'nullable|integer|min:1|max:500',
        ], [
            'ten_ca.required'       => 'Vui lòng nhập tên ca',
            'gio_bat_dau.required'  => 'Vui lòng chọn giờ bắt đầu',
            'gio_ket_thuc.required' => 'Vui lòng chọn giờ kết thúc',
            'gio_ket_thuc.after'    => 'Giờ kết thúc phải sau giờ bắt đầu',
        ]);

        $ca = CaLamViec::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Thêm ca làm việc thành công',
            'data'    => $ca,
        ], 201);
    }

    /**
     * GET /api/ca-lam-viec/{id}
     */
    public function show($id)
    {
        $ca = CaLamViec::with('khungGio')->find($id);

        if (!$ca) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy ca làm việc',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $ca,
        ]);
    }

    /**
     * PUT /api/ca-lam-viec/{id}
     */
    public function update(Request $request, $id)
    {
        $ca = CaLamViec::find($id);

        if (!$ca) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy ca làm việc',
            ], 404);
        }

        $data = $request->validate([
            'ten_ca'          => 'sometimes|string|max:50',
            'gio_bat_dau'     => 'sometimes|date_format:H:i:s',
            'gio_ket_thuc'    => 'sometimes|date_format:H:i:s|after:gio_bat_dau',
            'luot_kham_toi_da'=> 'nullable|integer|min:1|max:500',
        ]);

        $ca->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $ca->fresh(),
        ]);
    }

    /**
     * DELETE /api/ca-lam-viec/{id}
     * Chặn xóa nếu còn khung giờ
     */
    public function destroy($id)
    {
        $ca = CaLamViec::find($id);

        if (!$ca) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy ca làm việc',
            ], 404);
        }

        $soKhungGio = KhungGio::where('ma_ca', $id)->count();
        if ($soKhungGio > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa. Còn {$soKhungGio} khung giờ thuộc ca này.",
            ], 400);
        }

        $ca->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa ca làm việc',
        ]);
    }
}