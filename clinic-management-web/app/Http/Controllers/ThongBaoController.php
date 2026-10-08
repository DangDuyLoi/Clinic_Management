<?php

namespace App\Http\Controllers;

use App\Models\ThongBao;
use Illuminate\Http\Request;

class ThongBaoController extends Controller
{
    /**
     * GET /api/thong-bao
     * Lấy 20 thông báo gần nhất của user hiện tại
     */
    public function index(Request $request)
    {
        $maTk = auth('api')->id();

        $data = ThongBao::where('ma_tk', $maTk)
            ->orderBy('thoi_gian', 'desc')
            ->limit(20)
            ->get();

        $chuaDoc = ThongBao::where('ma_tk', $maTk)
            ->where('da_doc', false)
            ->count();

        return response()->json([
            'status' => 'success',
            'data' => [
                'danh_sach' => $data,
                'chua_doc' => $chuaDoc,
            ],
        ]);
    }

    /**
     * GET /api/thong-bao/count
     * Chỉ đếm số chưa đọc (nhẹ hơn index)
     */
    public function count()
    {
        $maTk = auth('api')->id();

        $chuaDoc = ThongBao::where('ma_tk', $maTk)
            ->where('da_doc', false)
            ->count();

        return response()->json([
            'status' => 'success',
            'data' => ['chua_doc' => $chuaDoc],
        ]);
    }

    /**
     * PUT /api/thong-bao/{id}/read
     * Đánh dấu 1 thông báo đã đọc
     */
    public function markAsRead($id)
    {
        $maTk = auth('api')->id();

        $tb = ThongBao::where('ma_tk', $maTk)->find($id);
        if (!$tb) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy thông báo',
            ], 404);
        }

        $tb->da_doc = true;
        $tb->save();

        return response()->json(['status' => 'success']);
    }

    /**
     * PUT /api/thong-bao/read-all
     * Đánh dấu TẤT CẢ đã đọc
     */
    public function markAllAsRead()
    {
        $maTk = auth('api')->id();

        ThongBao::where('ma_tk', $maTk)
            ->where('da_doc', false)
            ->update(['da_doc' => true]);

        return response()->json([
            'status' => 'success',
            'message' => 'Đã đánh dấu tất cả đã đọc',
        ]);
    }

    /**
     * DELETE /api/thong-bao/{id}
     */
    public function destroy($id)
    {
        $maTk = auth('api')->id();

        $tb = ThongBao::where('ma_tk', $maTk)->find($id);
        if (!$tb) {
            return response()->json([
                'status' => 'error',
                'message' => 'Không tìm thấy',
            ], 404);
        }

        $tb->delete();
        return response()->json(['status' => 'success']);
    }
}