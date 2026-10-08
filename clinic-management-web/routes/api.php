<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TaiKhoanController;
use App\Http\Controllers\ChuyenKhoaController;
use App\Http\Controllers\DichVuController;
use App\Http\Controllers\BacSiController;
use App\Http\Controllers\LichKhamController;
use App\Http\Controllers\BenhNhanController;
use App\Http\Controllers\HoaDonController;
use App\Http\Controllers\PhienKhamController;
use App\Http\Controllers\ThuocController;
use App\Http\Controllers\DonThuocController;
use App\Http\Controllers\NhatKyHeThongController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\CaLamViecController;
use App\Http\Controllers\KhungGioController;
use App\Http\Controllers\ThongBaoController;
use App\Http\Controllers\VNPayController;
/* ============================================================
   PUBLIC ROUTES — Không cần đăng nhập
   ============================================================ */
Route::prefix('auth')->group(function () {
    Route::post('/login',    [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
});
Route::post('vnpay/ipn', [VNPayController::class, 'ipn']);
/* ============================================================
   PROTECTED ROUTES — Yêu cầu JWT
   ============================================================ */
Route::middleware('auth:api')->group(function () {
    /* ============================================================
       NHẬT KÝ HỆ THỐNG (chỉ Admin)
       ============================================================ */
    Route::middleware('role:QuanTri')->group(function () {
        Route::get('nhat-ky',      [NhatKyHeThongController::class, 'index']);
        Route::get('nhat-ky/{id}', [NhatKyHeThongController::class, 'show']);
    });
    /* ============================================================
       ============================================================ */
    Route::middleware('role:QuanTri')->prefix('admin')->group(function () {
            Route::get('users',           [TaiKhoanController::class, 'index']);
            Route::post('users',          [TaiKhoanController::class, 'store']);
            Route::get('users/{id}',      [TaiKhoanController::class, 'show']);
            Route::put('users/{id}',      [TaiKhoanController::class, 'update']);
            Route::delete('users/{id}',   [TaiKhoanController::class, 'destroy']);
            Route::put('users/{id}/lock', [TaiKhoanController::class, 'toggleLock']);
        });
            /* ============================================================
       CHUYÊN KHOA
       - Ai cũng xem được (Admin, Lễ tân, Bác sĩ)
       - Chỉ Admin mới thêm/sửa/xóa
       ============================================================ */
    Route::get('chuyen-khoa',      [ChuyenKhoaController::class, 'index']);
    Route::get('chuyen-khoa/{id}', [ChuyenKhoaController::class, 'show']);

    Route::middleware('role:QuanTri')->group(function () {
        Route::post('chuyen-khoa',        [ChuyenKhoaController::class, 'store']);
        Route::put('chuyen-khoa/{id}',    [ChuyenKhoaController::class, 'update']);
        Route::delete('chuyen-khoa/{id}', [ChuyenKhoaController::class, 'destroy']);
    });
        /* ============================================================
       DỊCH VỤ
       - Ai cũng xem được
       - Chỉ Admin mới thêm/sửa/xóa
       ============================================================ */
    Route::get('dich-vu',      [DichVuController::class, 'index']);
    Route::get('dich-vu/{id}', [DichVuController::class, 'show']);

    Route::middleware('role:QuanTri')->group(function () {
        Route::post('dich-vu',        [DichVuController::class, 'store']);
        Route::put('dich-vu/{id}',    [DichVuController::class, 'update']);
        Route::delete('dich-vu/{id}', [DichVuController::class, 'destroy']);
    });
        /* ============================================================
       BÁC SĨ
       - Ai cũng xem được (Admin, Lễ tân, Bác sĩ)
       - Chỉ Admin mới thêm/sửa/xóa
       ============================================================ */
    Route::get('bac-si',      [BacSiController::class, 'index']);
    Route::get('bac-si/{id}', [BacSiController::class, 'show']);

    Route::middleware('role:QuanTri')->group(function () {
        Route::post('bac-si',        [BacSiController::class, 'store']);
        Route::put('bac-si/{id}',    [BacSiController::class, 'update']);
        Route::delete('bac-si/{id}', [BacSiController::class, 'destroy']);
    });
        /* ============================================================
       LỊCH KHÁM
       - Ai cũng xem được
       - Lễ tân/Admin/Bệnh nhân đặt lịch
       - Lễ tân/Admin check-in, hủy
       ============================================================ */
    Route::get('lich-kham/khung-gio-trong', [LichKhamController::class, 'availableSlots']);
    Route::get('lich-kham',                  [LichKhamController::class, 'index']);
    Route::get('lich-kham/{id}',             [LichKhamController::class, 'show']);
    Route::post('lich-kham',                 [LichKhamController::class, 'store']);

    Route::middleware('role:LeTan,QuanTri')->group(function () {
        Route::put('lich-kham/{id}/checkin', [LichKhamController::class, 'checkIn']);
        Route::put('lich-kham/{id}/cancel',  [LichKhamController::class, 'cancel']);
    });
        /* ============================================================
       BỆNH NHÂN
       - Lễ tân/Admin: full CRUD
       - Bác sĩ: chỉ xem
       ============================================================ */
    Route::get('benh-nhan/{id}/lich-su-kham', [BenhNhanController::class, 'lichSuKham']);
    Route::get('benh-nhan/{id}/thong-ke',     [BenhNhanController::class, 'thongKe']);       
    Route::get('benh-nhan',      [BenhNhanController::class, 'index']);
    Route::get('benh-nhan/{id}', [BenhNhanController::class, 'show']);
    

    Route::middleware('role:LeTan,QuanTri')->group(function () {
        Route::post('benh-nhan',        [BenhNhanController::class, 'store']);
        Route::put('benh-nhan/{id}',    [BenhNhanController::class, 'update']);
        Route::delete('benh-nhan/{id}', [BenhNhanController::class, 'destroy']);
    });
        /* ============================================================
       HÓA ĐƠN / THANH TOÁN
       - Lễ tân + Admin: full quyền
       - Bệnh nhân: xem hóa đơn của mình (chưa cần)
       ============================================================ */
    Route::middleware('role:LeTan,QuanTri')->group(function () {
        Route::get('hoa-don',            [HoaDonController::class, 'index']);
        Route::get('hoa-don/{id}',       [HoaDonController::class, 'show']);
        Route::post('hoa-don',           [HoaDonController::class, 'store']);
        Route::put('hoa-don/{id}/pay',   [HoaDonController::class, 'pay']);
        Route::put('hoa-don/{id}/cancel',[HoaDonController::class, 'cancel']);
    });
        /* ============================================================
       PHIÊN KHÁM (Bác sĩ + Lễ tân)
       ============================================================ */
    Route::get('phien-kham',                        [PhienKhamController::class, 'index']);
    Route::get('phien-kham/by-lich/{maLich}',       [PhienKhamController::class, 'getByLichKham']);
    Route::get('phien-kham/{id}',                   [PhienKhamController::class, 'show']);

    Route::middleware('role:BacSi,QuanTri')->group(function () {
        Route::put('phien-kham/{id}',               [PhienKhamController::class, 'update']);
        Route::post('phien-kham/{id}/finish',       [PhienKhamController::class, 'finish']);
        Route::post('phien-kham/{id}/chi-dinh',     [PhienKhamController::class, 'addChiDinh']);
        Route::delete('phien-kham/chi-dinh/{id}',   [PhienKhamController::class, 'removeChiDinh']);
    });

    /* ============================================================
       THUỐC (danh mục)
       ============================================================ */
    Route::get('thuoc',      [ThuocController::class, 'index']);
    Route::get('thuoc/{id}', [ThuocController::class, 'show']);

    Route::middleware('role:QuanTri')->group(function () {
        Route::post('thuoc',        [ThuocController::class, 'store']);
        Route::put('thuoc/{id}',    [ThuocController::class, 'update']);
        Route::delete('thuoc/{id}', [ThuocController::class, 'destroy']);
    });

    /* ============================================================
       ĐƠN THUỐC (Bác sĩ kê đơn)
       ============================================================ */
    Route::get('don-thuoc/phien-kham/{maPhien}', [DonThuocController::class, 'getByPhienKham']);
    Route::get('don-thuoc/{id}',                 [DonThuocController::class, 'show']);

    Route::middleware('role:BacSi,QuanTri')->group(function () {
        Route::post('don-thuoc', [DonThuocController::class, 'store']);
    });
        /* ============================================================
       CẤU HÌNH LỊCH KHÁM — CA + KHUNG GIỜ (chỉ Admin)
       ============================================================ */
    Route::middleware('role:QuanTri')->group(function () {
        // Ca làm việc
        Route::get('ca-lam-viec',      [CaLamViecController::class, 'index']);
        Route::post('ca-lam-viec',     [CaLamViecController::class, 'store']);
        Route::get('ca-lam-viec/{id}', [CaLamViecController::class, 'show']);
        Route::put('ca-lam-viec/{id}', [CaLamViecController::class, 'update']);
        Route::delete('ca-lam-viec/{id}', [CaLamViecController::class, 'destroy']);

        // Khung giờ
        Route::get('khung-gio',      [KhungGioController::class, 'index']);
        Route::post('khung-gio',     [KhungGioController::class, 'store']);
        Route::get('khung-gio/{id}', [KhungGioController::class, 'show']);
        Route::put('khung-gio/{id}', [KhungGioController::class, 'update']);
        Route::delete('khung-gio/{id}', [KhungGioController::class, 'destroy']);
    });
        /* ---------- QR CODE CHECK-IN ---------- */
    Route::post('lich-kham/scan-qr', [LichKhamController::class, 'scanQR']);
    Route::get('lich-kham/{id}/qr',  [LichKhamController::class, 'getQR']);
    Route::post('lich-kham/{id}/checkin-by-qr', [LichKhamController::class, 'checkInByQR'])
        ->middleware('role:LeTan,QuanTri');
            /* ============================================================
       DASHBOARD (Admin)
       ============================================================ */
    Route::middleware('role:QuanTri')->prefix('dashboard')->group(function () {
        Route::get('admin',              [DashboardController::class, 'admin']);
        Route::get('revenue',            [DashboardController::class, 'revenue']);
        Route::get('doctor-performance', [DashboardController::class, 'doctorPerformance']);
        Route::get('specialty-stats',    [DashboardController::class, 'specialtyStats']);
        Route::get('overview',           [DashboardController::class, 'overview']);
        Route::get('export-excel',       [DashboardController::class, 'exportExcel']);
    });
        /* ============================================================
       THÔNG BÁO
       ============================================================ */
    Route::get('thong-bao',              [ThongBaoController::class, 'index']);
    Route::get('thong-bao/count',        [ThongBaoController::class, 'count']);
    Route::put('thong-bao/read-all',     [ThongBaoController::class, 'markAllAsRead']);
    Route::put('thong-bao/{id}/read',    [ThongBaoController::class, 'markAsRead']);
    Route::delete('thong-bao/{id}',      [ThongBaoController::class, 'destroy']);
    /* ============================================================
       ============================================================ */
    Route::prefix('auth')->group(function () {
        Route::post('/logout',          [AuthController::class, 'logout']);
        Route::get('/me',               [AuthController::class, 'me']);
        Route::post('/refresh',         [AuthController::class, 'refresh']);
        Route::post('/change-password', [AuthController::class, 'changePassword']);
    });
Route::post('vnpay/create-payment/{hoaDonId}', [VNPayController::class, 'createPayment']);
Route::post('vnpay/mock-payment/{hoaDonId}', [VNPayController::class, 'createMockPayment']);
Route::post('vnpay/simulate-callback',        [VNPayController::class, 'simulateCallback']);
});