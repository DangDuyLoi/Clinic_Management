<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\LuotKham;
use Carbon\Carbon;

class BacSiController extends Controller
{
    /**
     * Lấy danh sách bác sĩ từ MySQL (có thể lọc theo ma_chuyen_khoa)
     */
    public function index(Request $request)
    {
        $query = DB::table('bacsi')
            ->leftJoin('chuyenkhoa', 'bacsi.ma_chuyen_khoa', '=', 'chuyenkhoa.ma_chuyen_khoa')
            ->select(
                'bacsi.ma_bs',
                'bacsi.ho_ten',
                'bacsi.phong_kham',
                'bacsi.trinh_do',
                'bacsi.ma_chuyen_khoa',
                'bacsi.luot_kham_toi_da_moi_ca',
                'chuyenkhoa.ten_chuyen_khoa'
            );

        if ($request->has('ma_chuyen_khoa') && !empty($request->ma_chuyen_khoa)) {
            $query->where('bacsi.ma_chuyen_khoa', $request->ma_chuyen_khoa);
        }

        $doctors = $query->orderBy('bacsi.ma_chuyen_khoa')->orderBy('bacsi.ma_bs')->get();

        $formatted = $doctors->map(function ($d) {
            $avatarId = ($d->ma_bs % 70) + 1;
            return [
                'id' => (string)$d->ma_bs,
                'ma_bs' => $d->ma_bs,
                'name' => $d->ho_ten,
                'ho_ten' => $d->ho_ten,
                'room' => $d->phong_kham ?: 'Phòng Khám Đa Khoa',
                'phong_kham' => $d->phong_kham ?: 'Phòng Khám Đa Khoa',
                'trinh_do' => $d->trinh_do,
                'ma_chuyen_khoa' => $d->ma_chuyen_khoa,
                'chuyen_khoa' => $d->ten_chuyen_khoa,
                'ten_chuyen_khoa' => $d->ten_chuyen_khoa,
                'avatarUrl' => "https://i.pravatar.cc/150?img={$avatarId}",
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Lấy danh sách bác sĩ thành công!',
            'data' => $formatted,
        ], 200);
    }

    /**
     * Lấy danh sách khung giờ từ bảng khunggio trong MySQL
     */
    public function khungGio(Request $request)
    {
        $slots = DB::table('khunggio')
            ->orderBy('gio_bat_dau')
            ->get();

        $formatted = $slots->map(function ($s) {
            $start = substr($s->gio_bat_dau, 0, 5);
            $end = substr($s->gio_ket_thuc, 0, 5);
            return [
                'ma_khung_gio' => $s->ma_khung_gio,
                'ma_ca' => $s->ma_ca,
                'gio_bat_dau' => $s->gio_bat_dau,
                'gio_ket_thuc' => $s->gio_ket_thuc,
                'time_range' => "{$start} - {$end}",
                'label' => "{$start} - {$end}",
                'luot_kham_toi_da' => $s->luot_kham_toi_da,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $formatted,
        ], 200);
    }
}
