<?php

namespace App\Http\Controllers;

use App\Models\KhungGio;
use App\Models\CaLamViec;
use Illuminate\Http\Request;

class KhungGioController extends Controller
{
    /**
     * GET /api/khung-gio
     * Query: ?ma_ca=1
     */
    public function index(Request $request)
    {
        $query = KhungGio::with('caLamViec');

        if ($maCa = $request->query('ma_ca')) {
            $query->where('ma_ca', $maCa);
        }

        $data = $query->orderBy('ma_ca')->orderBy('gio_bat_dau')->get();

        return response()->json([
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /**
     * POST /api/khung-gio
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'ma_ca'           => 'required|integer|exists:CaLamViec,ma_ca',
            'gio_bat_dau'     => 'required|date_format:H:i:s',
            'gio_ket_thuc'    => 'required|date_format:H:i:s|after:gio_bat_dau',
            'luot_kham_toi_da'=> 'nullable|integer|min:1|max:100',
        ], [
            'ma_ca.required'       => 'Vui lòng chọn ca làm việc',
            'ma_ca.exists'         => 'Ca làm việc không tồn tại',
            'gio_bat_dau.required' => 'Vui lòng chọn giờ bắt đầu',
            'gio_ket_thuc.required'=> 'Vui lòng chọn giờ kết thúc',
            'gio_ket_thuc.after'   => 'Giờ kết thúc phải sau giờ bắt đầu',
        ]);

        // Kiểm tra khung giờ nằm trong ca
        $ca = CaLamViec::find($data['ma_ca']);
        if ($data['gio_bat_dau'] < $ca->gio_bat_dau || $data['gio_ket_thuc'] > $ca->gio_ket_thuc) {
            return response()->json([
                'status'  => 'error',
                'message' => "Khung giờ phải nằm trong ca {$ca->gio_bat_dau} - {$ca->gio_ket_thuc}",
            ], 400);
        }

        $kg = KhungGio::create($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Thêm khung giờ thành công',
            'data'    => $kg->load('caLamViec'),
        ], 201);
    }

    /**
     * GET /api/khung-gio/{id}
     */
    public function show($id)
    {
        $kg = KhungGio::with('caLamViec')->find($id);

        if (!$kg) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy khung giờ',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $kg,
        ]);
    }

    /**
     * PUT /api/khung-gio/{id}
     */
    public function update(Request $request, $id)
    {
        $kg = KhungGio::find($id);

        if (!$kg) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy khung giờ',
            ], 404);
        }

        $data = $request->validate([
            'ma_ca'           => 'sometimes|integer|exists:CaLamViec,ma_ca',
            'gio_bat_dau'     => 'sometimes|date_format:H:i:s',
            'gio_ket_thuc'    => 'sometimes|date_format:H:i:s|after:gio_bat_dau',
            'luot_kham_toi_da'=> 'nullable|integer|min:1|max:100',
        ]);

        $kg->update($data);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật thành công',
            'data'    => $kg->fresh()->load('caLamViec'),
        ]);
    }

    /**
     * DELETE /api/khung-gio/{id}
     * Chặn xóa nếu đã có lịch khám
     */
    public function destroy($id)
    {
        $kg = KhungGio::find($id);

        if (!$kg) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy khung giờ',
            ], 404);
        }

        // Kiểm tra có lịch khám không
        $soLich = \App\Models\LichKham::where('ma_khung_gio', $id)
            ->whereNotIn('trang_thai', ['DaHuy'])
            ->count();

        if ($soLich > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa. Khung giờ đã có {$soLich} lịch khám.",
            ], 400);
        }

        $kg->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã xóa khung giờ',
        ]);
    }
}