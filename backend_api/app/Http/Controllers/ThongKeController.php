<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ThongKeController extends Controller
{
    // API Thống kê tổng quan cho Dashboard (Admin/Quản lý)
    public function tongQuan(Request $request)
    {
        // Mặc định lấy thống kê trong tháng hiện tại nếu Frontend không truyền ngày
        $tuNgay = $request->input('tu_ngay', Carbon::now()->startOfMonth()->toDateString());
        $denNgay = $request->input('den_ngay', Carbon::now()->endOfMonth()->toDateString());

        // 1. Tính tổng doanh thu (chỉ tính các hóa đơn đã thanh toán)
        $doanhThu = DB::table('hoa_don')
            ->where('trang_thai', 'DaThanhToan')
            ->whereBetween('updated_at', [$tuNgay . ' 00:00:00', $denNgay . ' 23:59:59'])
            ->sum('tong_cong');

        // 2. Tính số lượng bệnh nhân (số lượt khám đã hoàn thành)
        $soBenhNhan = DB::table('luot_kham')
            ->whereIn('trang_thai', ['hoan_thanh', 'DaKham']) // Tùy theo trạng thái bạn đặt ở DB
            ->whereBetween('thoi_gian_den_kham', [$tuNgay . ' 00:00:00', $denNgay . ' 23:59:59'])
            ->count();

        // 3. Thống kê hiệu suất của từng Bác sĩ (Khám được bao nhiêu ca)
        // Giả định thông tin bác sĩ nằm ở bảng 'users'
        $hieuSuatBacSi = DB::table('luot_kham')
            ->join('users', 'luot_kham.ma_bac_si', '=', 'users.id')
            ->whereIn('luot_kham.trang_thai', ['hoan_thanh', 'DaKham'])
            ->whereBetween('luot_kham.thoi_gian_den_kham', [$tuNgay . ' 00:00:00', $denNgay . ' 23:59:59'])
            ->select('users.name as ten_bac_si', DB::raw('COUNT(luot_kham.id) as so_ca_kham'))
            ->groupBy('users.id', 'users.name')
            ->orderByDesc('so_ca_kham')
            ->get();

        return response()->json([
            'message' => 'Lấy dữ liệu thống kê thành công',
            'thoi_gian' => [
                'tu_ngay' => $tuNgay,
                'den_ngay' => $denNgay
            ],
            'data' => [
                'tong_doanh_thu' => (float) $doanhThu,
                'tong_so_benh_nhan' => $soBenhNhan,
                'hieu_suat_bac_si' => $hieuSuatBacSi
            ]
        ], 200);
    }
}
