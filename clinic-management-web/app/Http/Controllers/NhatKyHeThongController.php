<?php

namespace App\Http\Controllers;

use App\Models\NhatKyHeThong;
use Illuminate\Http\Request;

class NhatKyHeThongController extends Controller
{
    /**
     * GET /api/nhat-ky
     * Query: ?ma_tk=1&bang_tac_dong=LichKham&hanh_dong=CREATE&from=...&to=...&per_page=30
     */
    public function index(Request $request)
    {
        $query = NhatKyHeThong::with('taiKhoan');

        if ($maTk = $request->query('ma_tk')) {
            $query->where('ma_tk', $maTk);
        }
        if ($bang = $request->query('bang_tac_dong')) {
            $query->where('bang_tac_dong', $bang);
        }
        if ($hanhDong = $request->query('hanh_dong')) {
            $query->where('hanh_dong', $hanhDong);
        }
        if ($from = $request->query('from')) {
            $query->where('thoi_gian', '>=', $from);
        }
        if ($to = $request->query('to')) {
            $query->where('thoi_gian', '<=', $to);
        }

        $perPage = (int) $request->query('per_page', 30);
        $perPage = max(1, min($perPage, 100));

        return response()->json([
            'status' => 'success',
            'data'   => $query->orderBy('ma_nhat_ky', 'desc')->paginate($perPage),
        ]);
    }

    /**
     * GET /api/nhat-ky/{id}
     */
    public function show($id)
    {
        $nk = NhatKyHeThong::with('taiKhoan')->find($id);

        if (!$nk) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy nhật ký',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $nk,
        ]);
    }

    /**
     * Helper static — Ghi log (dùng từ controller khác)
     */
    public static function ghiLog($maTk, $hanhDong, $bang, $duLieuCu = null, $duLieuMoi = null)
    {
        return NhatKyHeThong::create([
            'ma_tk'         => $maTk,
            'hanh_dong'     => $hanhDong,
            'bang_tac_dong' => $bang,
            'du_lieu_cu'    => $duLieuCu,
            'du_lieu_moi'   => $duLieuMoi,
        ]);
    }
}