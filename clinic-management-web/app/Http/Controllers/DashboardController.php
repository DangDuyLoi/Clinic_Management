<?php

namespace App\Http\Controllers;

use App\Models\TaiKhoan;
use App\Models\BacSi;
use App\Models\BenhNhan;
use App\Models\ChuyenKhoa;
use App\Models\LichKham;
use App\Models\HoaDon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * GET /api/dashboard/admin
     * Thống kê tổng quan cho Admin
     */
    public function admin(Request $request)
    {
        $today = now()->toDateString();

        // Đếm các entity
        $totalUsers    = TaiKhoan::count();
        $totalDoctors  = BacSi::count();
        $totalPatients = BenhNhan::count();
        $totalSpecs    = ChuyenKhoa::count();

        // Lịch khám hôm nay
        $appointmentsToday = LichKham::where('ngay_kham', $today)->count();
        $appointmentsPending = LichKham::where('ngay_kham', $today)
            ->whereIn('trang_thai', ['ChoXacNhan', 'ChoKham'])
            ->count();
        $appointmentsDone = LichKham::where('ngay_kham', $today)
            ->where('trang_thai', 'HoanThanh')
            ->count();

        // Doanh thu hôm nay (hóa đơn đã thanh toán)
        $revenueToday = HoaDon::whereDate('ngay_thanh_toan', $today)
            ->where('trang_thai', 'DaThanhToan')
            ->sum('tong_cong');

        // Doanh thu 7 ngày gần đây
        $revenue7Days = HoaDon::where('trang_thai', 'DaThanhToan')
            ->where('ngay_thanh_toan', '>=', now()->subDays(6)->startOfDay())
            ->select(
                DB::raw('DATE(ngay_thanh_toan) as ngay'),
                DB::raw('SUM(tong_cong) as doanh_thu'),
                DB::raw('COUNT(*) as so_hoa_don')
            )
            ->groupBy('ngay')
            ->orderBy('ngay')
            ->get();

        // Top 5 bác sĩ có nhiều lịch khám nhất
        $topDoctors = BacSi::withCount(['lichKham' => function ($q) {
            $q->where('trang_thai', '!=', 'DaHuy');
        }])
        ->orderBy('lich_kham_count', 'desc')
        ->limit(5)
        ->get(['ma_bs', 'ho_ten', 'ma_chuyen_khoa']);

        // Top chuyên khoa có nhiều lịch khám
        $topSpecialties = ChuyenKhoa::withCount(['bacSi'])
            ->orderBy('bac_si_count', 'desc')
            ->get(['ma_chuyen_khoa', 'ten_chuyen_khoa']);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'total' => [
                    'users'       => $totalUsers,
                    'doctors'     => $totalDoctors,
                    'patients'    => $totalPatients,
                    'specialties' => $totalSpecs,
                ],
                'today' => [
                    'appointments' => $appointmentsToday,
                    'pending'      => $appointmentsPending,
                    'done'         => $appointmentsDone,
                    'revenue'      => (float) $revenueToday,
                ],
                'revenue_7_days' => $revenue7Days,
                'top_doctors'    => $topDoctors,
                'top_specialties'=> $topSpecialties,
            ],
        ]);
    }
}