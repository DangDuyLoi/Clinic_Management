<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\BacSiController;
use App\Http\Controllers\BenhNhanController;
use App\Http\Controllers\CaLamViecController;
use App\Http\Controllers\ChuyenKhoaController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\DichVuController;
use App\Http\Controllers\DonThuocController;
use App\Http\Controllers\HoaDonController;
use App\Http\Controllers\KhungGioController;
use App\Http\Controllers\LichKhamController;
use App\Http\Controllers\MobileController;
use App\Http\Controllers\NhatKyHeThongController;
use App\Http\Controllers\PhienKhamController;
use App\Http\Controllers\TaiKhoanController;
use App\Http\Controllers\ThongBaoController;
use App\Http\Controllers\ThuocController;
use App\Http\Controllers\VNPayController;
use Illuminate\Support\Facades\Route;

/* ============================================================
   PUBLIC ROUTES — Không cần đăng nhập
   ============================================================ */
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
});
Route::get('vnpay/ipn', [VNPayController::class, 'ipn']);
Route::match(['get', 'post'], 'vnpay/return', [VNPayController::class, 'vnpayReturn']);
/* ============================================================
   MOBILE APP ROUTES — Dành cho Flutter (Bệnh nhân)
   Prefix: /api/mobile
   ============================================================ */
Route::prefix('mobile')->group(function () {

    // ============ AUTH (PUBLIC) ============
    Route::post('login', [MobileController::class, 'login']);
    Route::post('send-otp', [MobileController::class, 'sendOtp']);
    Route::post('verify-otp', [MobileController::class, 'verifyOtp']);
    Route::post('set-password', [MobileController::class, 'setPassword']);
    Route::post('update-fcm-token', [MobileController::class, 'updateFcmToken']);
    Route::post('logout', [MobileController::class, 'logout'])->middleware('auth:api');

    // ============ MASTER DATA + DANH MỤC (PUBLIC) ============
    Route::get('patient-profiles/metadata', [MobileController::class, 'metadata']);
    Route::get('chuyen-khoa', [ChuyenKhoaController::class, 'index']);
    Route::get('bac-si', [BacSiController::class, 'index']);
    Route::get('khung-gio', [KhungGioController::class, 'index']);

    // ============ HỒ SƠ BỆNH NHÂN (PUBLIC theo phone) ============
    // App hiện chưa gửi token cho các API này (theo PatientProfileService)
    // → Để public để App chạy được, khuyến nghị bổ sung token sau

    Route::get('patient-profiles/search-by-code', [MobileController::class, 'findProfileByCode']);
    Route::get('patient-profiles/search-by-info', [MobileController::class, 'findProfileByInfo']);

    // ============ ĐẶT LỊCH (PUBLIC) ============
    Route::post('luot-kham/dat-lich', [MobileController::class, 'datLich']);
    Route::get('luot-kham/gio-trong', [MobileController::class, 'gioTrong']);
    Route::get('bac-si', [MobileController::class, 'bacSi']);

    // ============ EMR (PUBLIC theo phone) ============
    Route::get('emr/lich-su-kham', [MobileController::class, 'lichSuKham']);
    Route::get('emr/ket-qua-cls', [MobileController::class, 'ketQuaCls']);

    // ============ BHYT (PUBLIC) ============
    Route::get('bhxh/tra-cuu-the', [MobileController::class, 'traCuuBhyt']);

    // ============ VNPAY (PUBLIC — app mở browser) ============
    Route::get('vnpay/payment-url', [MobileController::class, 'vnpayPaymentUrl']);
    Route::get('vnpay/return', [MobileController::class, 'vnpayReturn']);

    // ============ PROTECTED — Yêu cầu JWT ============
    Route::middleware('auth:api')->group(function () {
        Route::get('payment/bills', [MobileController::class, 'paymentBills']);

        // Lịch khám của tôi
        Route::post('luot-kham/danh-sach', [MobileController::class, 'danhSach']);
        Route::get('luot-kham/{id}/check-status', [MobileController::class, 'checkStatus']);
        Route::get('luot-kham/{id}/qr', [LichKhamController::class, 'getQR'])
            ->middleware('role:BenhNhan');

        // Hàng đợi khám
        Route::get('luot-kham/{id}/hang-doi', [MobileController::class, 'hangDoi']);

        // Hủy / tiếp nhận
        Route::put('luot-kham/{id}/tiep-nhan', [MobileController::class, 'tiepNhan']);
        Route::post('luot-kham/{id}/huy', [MobileController::class, 'huy']);

        // Thông báo đẩy
        Route::post('luot-kham/{id}/thong-bao-sap-den-luot', [MobileController::class, 'thongBaoSapDenLuot']);

        Route::get('patient-profiles/by-phone', [MobileController::class, 'getProfilesByPhone']);
        Route::post('patient-profiles', [MobileController::class, 'createProfile']);
        Route::put('patient-profiles/{id}', [MobileController::class, 'updateProfile']);
        Route::delete('patient-profiles/{id}', [MobileController::class, 'deleteProfile']);
    });
});
/* ============================================================
   PROTECTED ROUTES — Yêu cầu JWT
   ============================================================ */
Route::middleware('auth:api')->group(function () {
    /* ============================================================
       NHẬT KÝ HỆ THỐNG (chỉ Admin)
       ============================================================ */
    Route::middleware('role:QuanTri')->group(function () {
        Route::get('nhat-ky', [NhatKyHeThongController::class, 'index']);
        Route::get('nhat-ky/{id}', [NhatKyHeThongController::class, 'show']);
    });

    /* ============================================================
       QUẢN LÝ TÀI KHOẢN
       ============================================================ */
    Route::middleware('role:QuanTri')->prefix('admin')->group(function () {
        Route::get('users', [TaiKhoanController::class, 'index']);
        Route::post('users', [TaiKhoanController::class, 'store']);
        Route::get('users/{id}', [TaiKhoanController::class, 'show']);
        Route::put('users/{id}', [TaiKhoanController::class, 'update']);
        Route::delete('users/{id}', [TaiKhoanController::class, 'destroy']);
        Route::put('users/{id}/lock', [TaiKhoanController::class, 'toggleLock']);
    });

    /* ============================================================
       CHUYÊN KHOA
       ============================================================ */
    Route::get('chuyen-khoa', [ChuyenKhoaController::class, 'index']);
    Route::get('chuyen-khoa/{id}', [ChuyenKhoaController::class, 'show']);

    Route::middleware('role:QuanTri')->group(function () {
        Route::post('chuyen-khoa', [ChuyenKhoaController::class, 'store']);
        Route::put('chuyen-khoa/{id}', [ChuyenKhoaController::class, 'update']);
        Route::delete('chuyen-khoa/{id}', [ChuyenKhoaController::class, 'destroy']);
    });

    /* ============================================================
       DỊCH VỤ
       ============================================================ */
    Route::get('dich-vu', [DichVuController::class, 'index']);
    Route::get('dich-vu/{id}', [DichVuController::class, 'show']);

    Route::middleware('role:QuanTri')->group(function () {
        Route::post('dich-vu', [DichVuController::class, 'store']);
        Route::put('dich-vu/{id}', [DichVuController::class, 'update']);
        Route::delete('dich-vu/{id}', [DichVuController::class, 'destroy']);
    });

    /* ============================================================
       BÁC SĨ
       ============================================================ */
    Route::get('bac-si', [BacSiController::class, 'index']);
    Route::get('bac-si/{id}', [BacSiController::class, 'show']);

    Route::middleware('role:QuanTri')->group(function () {
        Route::post('bac-si', [BacSiController::class, 'store']);
        Route::put('bac-si/{id}', [BacSiController::class, 'update']);
        Route::delete('bac-si/{id}', [BacSiController::class, 'destroy']);
    });

    /* ============================================================
       LỊCH KHÁM
       ============================================================ */
    Route::get('lich-kham/khung-gio-trong', [LichKhamController::class, 'availableSlots']);
    Route::get('lich-kham', [LichKhamController::class, 'index']);
    Route::get('lich-kham/{id}', [LichKhamController::class, 'show']);
    Route::post('lich-kham', [LichKhamController::class, 'store']);

    Route::middleware('role:LeTan,QuanTri')->group(function () {
        Route::put('lich-kham/{id}/checkin', [LichKhamController::class, 'checkIn']);
        Route::put('lich-kham/{id}/cancel', [LichKhamController::class, 'cancel']);
        Route::put('lich-kham/{id}/pay', [LichKhamController::class, 'pay']);
    });

    /* ============================================================
       QR CODE CHECK-IN
       ============================================================ */
    Route::post('lich-kham/scan-qr', [LichKhamController::class, 'scanQR']);
    Route::get('lich-kham/{id}/qr', [LichKhamController::class, 'getQR']);
    Route::match(['put', 'post'], 'lich-kham/{id}/checkin-by-qr', [LichKhamController::class, 'checkInByQR'])
        ->middleware('role:LeTan,QuanTri');

    /* ============================================================
       BỆNH NHÂN
       ============================================================ */
    Route::get('benh-nhan/{id}/lich-su-kham', [BenhNhanController::class, 'lichSuKham']);
    Route::get('benh-nhan/{id}/thong-ke', [BenhNhanController::class, 'thongKe']);
    Route::get('benh-nhan', [BenhNhanController::class, 'index']);
    Route::get('benh-nhan/{id}', [BenhNhanController::class, 'show']);
    Route::get('tinh-thanh', [BenhNhanController::class, 'getTinhThanh']);

    Route::middleware('role:LeTan,QuanTri')->group(function () {
        Route::post('benh-nhan', [BenhNhanController::class, 'store']);
        Route::put('benh-nhan/{id}', [BenhNhanController::class, 'update']);
        Route::delete('benh-nhan/{id}', [BenhNhanController::class, 'destroy']);
    });

    /* ============================================================
       HÓA ĐƠN / THANH TOÁN
       ============================================================ */
    Route::middleware('role:LeTan,QuanTri')->group(function () {
        Route::get('hoa-don', [HoaDonController::class, 'index']);
        Route::get('hoa-don/{id}', [HoaDonController::class, 'show']);
        Route::post('hoa-don', [HoaDonController::class, 'store']);
        Route::put('hoa-don/{id}/pay', [HoaDonController::class, 'pay']);
        Route::put('hoa-don/{id}/cancel', [HoaDonController::class, 'cancel']);
    });

    /* ============================================================
       PHIÊN KHÁM
       ============================================================ */
    Route::get('phien-kham', [PhienKhamController::class, 'index']);
    Route::get('phien-kham/by-lich/{maLich}', [PhienKhamController::class, 'getByLichKham']);
    Route::get('phien-kham/{id}', [PhienKhamController::class, 'show']);

    Route::middleware('role:BacSi,QuanTri')->group(function () {
        Route::put('phien-kham/{id}', [PhienKhamController::class, 'update']);
        Route::post('phien-kham/{id}/finish', [PhienKhamController::class, 'finish']);
        Route::post('phien-kham/{id}/chi-dinh', [PhienKhamController::class, 'addChiDinh']);
        Route::delete('phien-kham/chi-dinh/{id}', [PhienKhamController::class, 'removeChiDinh']);
    });

    /* ============================================================
       THUỐC & ĐƠN THUỐC
       ============================================================ */
    Route::get('thuoc', [ThuocController::class, 'index']);
    Route::get('thuoc/{id}', [ThuocController::class, 'show']);
    Route::middleware('role:QuanTri')->group(function () {
        Route::post('thuoc', [ThuocController::class, 'store']);
        Route::put('thuoc/{id}', [ThuocController::class, 'update']);
        Route::delete('thuoc/{id}', [ThuocController::class, 'destroy']);
    });

    Route::get('don-thuoc/phien-kham/{maPhien}', [DonThuocController::class, 'getByPhienKham']);
    Route::get('don-thuoc/{id}', [DonThuocController::class, 'show']);
    Route::middleware('role:BacSi,QuanTri')->group(function () {
        Route::post('don-thuoc', [DonThuocController::class, 'store']);
    });

    /* ============================================================
       CẤU HÌNH LỊCH KHÁM
       ============================================================ */
    Route::middleware('role:QuanTri')->group(function () {
        Route::get('ca-lam-viec', [CaLamViecController::class, 'index']);
        Route::post('ca-lam-viec', [CaLamViecController::class, 'store']);
        Route::get('ca-lam-viec/{id}', [CaLamViecController::class, 'show']);
        Route::put('ca-lam-viec/{id}', [CaLamViecController::class, 'update']);
        Route::delete('ca-lam-viec/{id}', [CaLamViecController::class, 'destroy']);

        Route::get('khung-gio', [KhungGioController::class, 'index']);
        Route::post('khung-gio', [KhungGioController::class, 'store']);
        Route::get('khung-gio/{id}', [KhungGioController::class, 'show']);
        Route::put('khung-gio/{id}', [KhungGioController::class, 'update']);
        Route::delete('khung-gio/{id}', [KhungGioController::class, 'destroy']);
    });

    /* ============================================================
       DASHBOARD (Admin)
       ============================================================ */
    Route::middleware('role:QuanTri')->prefix('dashboard')->group(function () {
        Route::get('admin', [DashboardController::class, 'admin']);
        Route::get('revenue', [DashboardController::class, 'revenue']);
        Route::get('doctor-performance', [DashboardController::class, 'doctorPerformance']);
        Route::get('specialty-stats', [DashboardController::class, 'specialtyStats']);
        Route::get('overview', [DashboardController::class, 'overview']);
        Route::get('export-excel', [DashboardController::class, 'exportExcel']);
    });

    /* ============================================================
       THÔNG BÁO
       ============================================================ */
    Route::get('thong-bao', [ThongBaoController::class, 'index']);
    Route::get('thong-bao/count', [ThongBaoController::class, 'count']);
    Route::put('thong-bao/read-all', [ThongBaoController::class, 'markAllAsRead']);
    Route::put('thong-bao/{id}/read', [ThongBaoController::class, 'markAsRead']);
    Route::delete('thong-bao/{id}', [ThongBaoController::class, 'destroy']);

    /* ============================================================
       AUTH ACTIONS
       ============================================================ */
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
        Route::post('/change-password', [AuthController::class, 'changePassword']);
    });

    /* ============================================================
       VNPAY
       ============================================================ */
    Route::post('vnpay/create-payment/{hoaDonId}', [VNPayController::class, 'createPayment']);
    Route::post('vnpay/mock-payment/{hoaDonId}', [VNPayController::class, 'createMockPayment']);
    Route::post('vnpay/simulate-callback', [VNPayController::class, 'simulateCallback']);
});
