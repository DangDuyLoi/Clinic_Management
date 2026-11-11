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
    public function admin(Request $request)
    {
        $today = now()->toDateString();

        $totalUsers    = TaiKhoan::count();
        $totalDoctors  = BacSi::count();
        $totalPatients = BenhNhan::count();
        $totalSpecs    = ChuyenKhoa::count();

        $appointmentsToday = LichKham::whereDate('thoi_gian_den_kham', $today)->count();
        $appointmentsPending = LichKham::whereDate('thoi_gian_den_kham', $today)
            ->whereIn('trang_thai', ['cho_thanh_toan', 'cho_kham'])
            ->count();
        $appointmentsDone = LichKham::whereDate('thoi_gian_den_kham', $today)
            ->where('trang_thai', 'hoan_thanh')
            ->count();

        $revenueToday = HoaDon::whereDate('ngay_thanh_toan', $today)
            ->where('trang_thai', 'DaThanhToan')
            ->sum('tong_cong');

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

        $topDoctors = BacSi::withCount(['lichKham' => function ($q) {
            $q->where('trang_thai', '!=', 'huy');
        }])
        ->orderBy('lich_kham_count', 'desc')
        ->limit(5)
        ->get(['ma_bs', 'ho_ten', 'ma_chuyen_khoa']);

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

    public function revenue(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());
        $groupBy = $request->query('group_by', 'day');

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

        public function doctorPerformance(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());
        $limit = (int) $request->query('limit', 10);

        $data = \App\Models\BacSi::with('chuyenKhoa')
            ->select(
                'BacSi.*',
                DB::raw('(SELECT COUNT(*) FROM LuotKham
                          WHERE LuotKham.ma_bac_si = BacSi.ma_bs
                          AND LuotKham.trang_thai = "hoan_thanh"
                          AND DATE(LuotKham.thoi_gian_den_kham) BETWEEN "' . $from . '" AND "' . $to . '") as so_lich_hoan_thanh'),
                DB::raw('(SELECT COUNT(DISTINCT LuotKham.ma_ho_so) FROM LuotKham
                          WHERE LuotKham.ma_bac_si = BacSi.ma_bs
                          AND DATE(LuotKham.thoi_gian_den_kham) BETWEEN "' . $from . '" AND "' . $to . '") as so_benh_nhan'),
                DB::raw('(SELECT COALESCE(SUM(HoaDon.tong_cong), 0) FROM HoaDon
                          JOIN PhienKham ON HoaDon.ma_phien_kham = PhienKham.ma_phien_kham
                          JOIN LuotKham ON PhienKham.ma_lich_dat = LuotKham.ma_luot_kham
                          WHERE LuotKham.ma_bac_si = BacSi.ma_bs
                          AND HoaDon.trang_thai = "DaThanhToan"
                          AND DATE(HoaDon.ngay_thanh_toan) BETWEEN "' . $from . '" AND "' . $to . '") as doanh_thu')
            )
            ->orderBy('so_lich_hoan_thanh', 'desc')
            ->limit($limit)
            ->get();

        return response()->json(['status' => 'success', 'data' => $data]);
    }

        public function specialtyStats(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());

        $data = \App\Models\ChuyenKhoa::select(
                'ChuyenKhoa.*',
                DB::raw('(SELECT COUNT(*) FROM LuotKham
                          JOIN BacSi ON LuotKham.ma_bac_si = BacSi.ma_bs
                          WHERE BacSi.ma_chuyen_khoa = ChuyenKhoa.ma_chuyen_khoa
                          AND DATE(LuotKham.thoi_gian_den_kham) BETWEEN "' . $from . '" AND "' . $to . '") as so_lich'),
                DB::raw('(SELECT COALESCE(SUM(HoaDon.tong_cong), 0) FROM HoaDon
                          JOIN PhienKham ON HoaDon.ma_phien_kham = PhienKham.ma_phien_kham
                          JOIN LuotKham ON PhienKham.ma_lich_dat = LuotKham.ma_luot_kham
                          JOIN BacSi ON LuotKham.ma_bac_si = BacSi.ma_bs
                          WHERE BacSi.ma_chuyen_khoa = ChuyenKhoa.ma_chuyen_khoa
                          AND HoaDon.trang_thai = "DaThanhToan"
                          AND DATE(HoaDon.ngay_thanh_toan) BETWEEN "' . $from . '" AND "' . $to . '") as doanh_thu')
            )
            ->orderBy('doanh_thu', 'desc')
            ->get();

        return response()->json(['status' => 'success', 'data' => $data]);
    }

    public function overview(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());

        $lichByStatus = LichKham::whereDate('thoi_gian_den_kham', '>=', $from)
            ->whereDate('thoi_gian_den_kham', '<=', $to)
            ->select('trang_thai', DB::raw('COUNT(*) as so_luong'))
            ->groupBy('trang_thai')
            ->pluck('so_luong', 'trang_thai');

        $benhNhanMoi = BenhNhan::count();
        $tongLich = $lichByStatus->sum();
        $hoanThanh = $lichByStatus->get('hoan_thanh', 0); 
        $tyLeHoanThanh = $tongLich > 0 ? round(($hoanThanh / $tongLich) * 100, 1) : 0;
        $daHuy = $lichByStatus->get('huy', 0); 
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

    public function exportExcel(Request $request)
    {
        $from = $request->query('from', now()->subDays(29)->toDateString());
        $to   = $request->query('to', now()->toDateString());
        $filename = "bao-cao-doanh-thu-{$from}-den-{$to}.xlsx";
        return Excel::download(new RevenueExport($from, $to), $filename);
    }
}