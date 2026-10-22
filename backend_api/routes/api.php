<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Gom tất cả các khai báo Controller lên đầu file
use App\Http\Controllers\ChuyenKhoaController;
use App\Http\Controllers\DichVuController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\LuotKhamController;
use App\Http\Controllers\Api\PatientProfileController;
use App\Http\Controllers\VNPayController;
use App\Http\Controllers\PaymentController; // Thêm dòng này để gọi PaymentController
use App\Http\Controllers\BacSiController;
use App\Http\Controllers\EmrController;

// Phân hệ Hồ sơ bệnh án & Cận lâm sàng (EMR từ MySQL)
Route::prefix('emr')->group(function () {
    Route::get('lich-su-kham', [EmrController::class, 'getVisitHistory']);
    Route::get('ket-qua-cls', [EmrController::class, 'getTestResults']);
});

// Quản lý Bác sĩ & Khung giờ khám (Từ MySQL)
Route::get('bac-si', [BacSiController::class, 'index']);
Route::get('khung-gio', [BacSiController::class, 'khungGio']);

// Quản lý Chuyên Khoa
Route::prefix('chuyen-khoa')->group(function () {
    Route::get('/', [ChuyenKhoaController::class, 'index']);
    Route::post('/', [ChuyenKhoaController::class, 'store']);
    Route::put('/{id}', [ChuyenKhoaController::class, 'update']);
    Route::delete('/{id}', [ChuyenKhoaController::class, 'destroy']);
});

// Quản lý Dịch vụ khám bệnh
Route::get('dich-vu', [DichVuController::class, 'index']);
Route::post('dich-vu', [DichVuController::class, 'store']);
Route::put('dich-vu/{id}', [DichVuController::class, 'update']);
Route::delete('dich-vu/{id}', [DichVuController::class, 'destroy']);

// Auth
Route::post('/send-otp', [AuthController::class, 'sendOtp']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/set-password', [AuthController::class, 'setPassword']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/update-fcm-token', [AuthController::class, 'updateFcmToken']);
Route::post('/change-password', [AuthController::class, 'changePassword']);
Route::get('/user-info', [AuthController::class, 'getUserInfo']);
Route::post('/update-user-info', [AuthController::class, 'updateUserInfo']);

// Phân hệ Lượt Khám (Lễ tân, Bác sĩ, Bệnh nhân)
Route::match(['put', 'post', 'get'], 'luot-kham/{id}/tiep-nhan', [LuotKhamController::class, 'tiepNhan']); // Lễ tân (hỗ trợ PUT, POST, GET để scan QR dễ dàng)
Route::put('luot-kham/{id}/ket-qua', [LuotKhamController::class, 'capNhatKetQua']); // Bác sĩ
Route::post('luot-kham/dat-lich', [LuotKhamController::class, 'datLich']); // Bệnh nhân đặt lịch
Route::get('luot-kham/gio-trong', [LuotKhamController::class, 'layGioTrong']); // API lấy giờ trống của Bác sĩ
Route::post('luot-kham/danh-sach', [LuotKhamController::class, 'danhSachTheoHoSo']); // Lấy danh sách khám theo hồ sơ
Route::get('luot-kham/{id}/check-status', [LuotKhamController::class, 'checkStatus']); // Kiểm tra trạng thái lượt khám & thanh toán
Route::get('luot-kham/{id}/hang-doi', [LuotKhamController::class, 'layTienTrinhHangDoi']); // Tiến trình hàng đợi thời gian thực (Live Queue Tracker)
Route::post('luot-kham/{id}/thong-bao-sap-den-luot', [LuotKhamController::class, 'thongBaoSapDenLuot']); // Kích hoạt push notification sắp đến lượt khám

// Quản lý hồ sơ bệnh nhân
Route::prefix('patient-profiles')->group(function () {
    Route::post('/', [PatientProfileController::class, 'store']);
    Route::get('/search-by-code', [PatientProfileController::class, 'findByCode']);
    Route::get('/search-by-info', [PatientProfileController::class, 'findByInfo']);
});

// Phân hệ Thanh toán VNPay (Cho ứng dụng di động)
Route::get('/payment/bills', [PaymentController::class, 'getBills']);
Route::get('/vnpay/payment-url', [VNPayController::class, 'createPaymentUrl']);
Route::get('/vnpay/create-payment/{ma_luot_kham?}', [VNPayController::class, 'createPaymentUrl']);
Route::match(['get', 'post'], '/vnpay/return', [VNPayController::class, 'vnpayReturn']); // Callback VNPay

// Phân hệ Thanh toán VNPay (Hóa đơn web cũ)
Route::get('/thanh-toan/vnpay/{id}', [PaymentController::class, 'taoLinkVNPay']);
Route::get('/thanh-toan/vnpay-return', [PaymentController::class, 'vnpayReturn']); // API Webhook VNPay (đã bổ sung lại)

// Phân hệ Thanh toán MoMo
Route::get('/thanh-toan/momo/{id}', [PaymentController::class, 'taoLinkMoMo']);
Route::post('/thanh-toan/momo-notify', [PaymentController::class, 'momoNotify']); // MoMo dùng POST cho Webhook
