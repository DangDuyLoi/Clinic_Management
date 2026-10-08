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
use App\Exports\RevenueExport;
use Maatwebsite\Excel\Facades\Excel;

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
        /* ============================================================
       GET /api/dashboard/revenue
       Query: ?from=2026-09-01&to=2026-09-30&group_by=day|month
       Thống kê doanh thu theo khoảng thời gian
       ============================================================ */
    public function revenue(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());
        $groupBy = $request->query('group_by', 'day'); // day | month

        $query = HoaDon::where('trang_thai', 'DaThanhToan')
            ->whereBetween('ngay_thanh_toan', [$from . ' 00:00:00', $to . ' 23:59:59']);

        if ($groupBy === 'month') {
            $data = $query
                ->select(
                    DB::raw('DATE_FORMAT(ngay_thanh_toan, "%Y-%m") as thoi_gian'),
                    DB::raw('SUM(tong_cong) as doanh_thu'),
                    DB::raw('COUNT(*) as so_hoa_don'),
                    DB::raw('SUM(tien_kham_benh) as tien_kham'),
                    DB::raw('SUM(tien_dich_vu) as tien_dich_vu'),
                    DB::raw('SUM(tien_thuoc) as tien_thuoc')
                )
                ->groupBy('thoi_gian')
                ->orderBy('thoi_gian')
                ->get();
        } else {
            $data = $query
                ->select(
                    DB::raw('DATE(ngay_thanh_toan) as thoi_gian'),
                    DB::raw('SUM(tong_cong) as doanh_thu'),
                    DB::raw('COUNT(*) as so_hoa_don'),
                    DB::raw('SUM(tien_kham_benh) as tien_kham'),
                    DB::raw('SUM(tien_dich_vu) as tien_dich_vu'),
                    DB::raw('SUM(tien_thuoc) as tien_thuoc')
                )
                ->groupBy('thoi_gian')
                ->orderBy('thoi_gian')
                ->get();
        }

        $tongDoanhThu = $data->sum('doanh_thu');
        $tongHoaDon   = $data->sum('so_hoa_don');

        return response()->json([
            'status' => 'success',
            'data'   => [
                'from'           => $from,
                'to'             => $to,
                'group_by'       => $groupBy,
                'tong_doanh_thu' => (float) $tongDoanhThu,
                'tong_hoa_don'   => $tongHoaDon,
                'chi_tiet'       => $data,
            ],
        ]);
    }

    /* ============================================================
       GET /api/dashboard/doctor-performance
       Hiệu suất bác sĩ: số lịch, số bệnh nhân, doanh thu
       Query: ?from=2026-09-01&to=2026-09-30&limit=10
       ============================================================ */
    public function doctorPerformance(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());
        $limit = (int) $request->query('limit', 10);

        $data = BacSi::with('chuyenKhoa')
            ->select(
                'BacSi.*',
                DB::raw('(SELECT COUNT(*) FROM LichKham
                          WHERE LichKham.ma_bs = BacSi.ma_bs
                          AND LichKham.trang_thai = "HoanThanh"
                          AND LichKham.ngay_kham BETWEEN "' . $from . '" AND "' . $to . '") as so_lich_hoan_thanh'),
                DB::raw('(SELECT COUNT(DISTINCT LichKham.ma_bn) FROM LichKham
                          WHERE LichKham.ma_bs = BacSi.ma_bs
                          AND LichKham.ngay_kham BETWEEN "' . $from . '" AND "' . $to . '") as so_benh_nhan'),
                DB::raw('(SELECT COALESCE(SUM(HoaDon.tong_cong), 0) FROM HoaDon
                          JOIN PhienKham ON HoaDon.ma_phien_kham = PhienKham.ma_phien_kham
                          JOIN LichKham ON PhienKham.ma_lich_dat = LichKham.ma_lich_dat
                          WHERE LichKham.ma_bs = BacSi.ma_bs
                          AND HoaDon.trang_thai = "DaThanhToan"
                          AND DATE(HoaDon.ngay_thanh_toan) BETWEEN "' . $from . '" AND "' . $to . '") as doanh_thu')
            )
            ->orderBy('so_lich_hoan_thanh', 'desc')
            ->limit($limit)
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /* ============================================================
       GET /api/dashboard/specialty-stats
       Thống kê theo chuyên khoa: số lịch, doanh thu
       ============================================================ */
    public function specialtyStats(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());

        $data = ChuyenKhoa::select(
                'ChuyenKhoa.*',
                DB::raw('(SELECT COUNT(*) FROM LichKham
                          JOIN BacSi ON LichKham.ma_bs = BacSi.ma_bs
                          WHERE BacSi.ma_chuyen_khoa = ChuyenKhoa.ma_chuyen_khoa
                          AND LichKham.ngay_kham BETWEEN "' . $from . '" AND "' . $to . '") as so_lich'),
                DB::raw('(SELECT COALESCE(SUM(HoaDon.tong_cong), 0) FROM HoaDon
                          JOIN PhienKham ON HoaDon.ma_phien_kham = PhienKham.ma_phien_kham
                          JOIN LichKham ON PhienKham.ma_lich_dat = LichKham.ma_lich_dat
                          JOIN BacSi ON LichKham.ma_bs = BacSi.ma_bs
                          WHERE BacSi.ma_chuyen_khoa = ChuyenKhoa.ma_chuyen_khoa
                          AND HoaDon.trang_thai = "DaThanhToan"
                          AND DATE(HoaDon.ngay_thanh_toan) BETWEEN "' . $from . '" AND "' . $to . '") as doanh_thu')
            )
            ->orderBy('doanh_thu', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $data,
        ]);
    }

    /* ============================================================
       GET /api/dashboard/overview
       Thống kê tổng quan: bệnh nhân mới, tỷ lệ hoàn thành, v.v.
       ============================================================ */
    public function overview(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());

        // Tổng số lịch theo trạng thái
        $lichByStatus = LichKham::whereBetween('ngay_kham', [$from, $to])
            ->select('trang_thai', DB::raw('COUNT(*) as so_luong'))
            ->groupBy('trang_thai')
            ->pluck('so_luong', 'trang_thai');

        // Bệnh nhân mới trong khoảng thời gian
        $benhNhanMoi = BenhNhan::whereBetween('created_at', [$from . ' 00:00:00', $to . ' 23:59:59'])
            ->count();

        // Nếu cột created_at không tồn tại, dùng ma_bn tăng dần
        if ($benhNhanMoi === 0) {
            $benhNhanMoi = BenhNhan::count(); // Fallback
        }

        // Tỷ lệ hoàn thành
        $tongLich = $lichByStatus->sum();
        $hoanThanh = $lichByStatus->get('HoanThanh', 0);
        $tyLeHoanThanh = $tongLich > 0 ? round(($hoanThanh / $tongLich) * 100, 1) : 0;

        // Tỷ lệ hủy
        $daHuy = $lichByStatus->get('DaHuy', 0);
        $tyLeHuy = $tongLich > 0 ? round(($daHuy / $tongLich) * 100, 1) : 0;

        return response()->json([
            'status' => 'success',
            'data'   => [
                'lich_by_status'    => $lichByStatus,
                'tong_lich'         => $tongLich,
                'benh_nhan_moi'     => $benhNhanMoi,
                'ty_le_hoan_thanh'  => $tyLeHoanThanh,
                'ty_le_huy'         => $tyLeHuy,
                'from'              => $from,
                'to'                => $to,
            ],
        ]);
    }
        /**
     * GET /api/dashboard/export-excel?from=...&to=...&token=...
     */
    public function exportExcel(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());

        $filename = "bao-cao-doanh-thu-{$from}-den-{$to}.xlsx";

        return Excel::download(new RevenueExport($from, $to), $filename);
    }
}