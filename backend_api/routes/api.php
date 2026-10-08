<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Gom tất cả các khai báo Controller lên đầu file
use App\Http\Controllers\ChuyenKhoaController;
use App\Http\Controllers\DichVuController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\LuotKhamController;
use App\Http\Controllers\Api\PatientProfileController;
use App\Http\Controllers\PaymentController; 
use App\Http\Controllers\ThongKeController; // Đã thêm ThongKeController

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

// Phân hệ Lượt Khám (Lễ tân, Bác sĩ, Bệnh nhân)
Route::put('luot-kham/{id}/tiep-nhan', [LuotKhamController::class, 'tiepNhan']); // Lễ tân
Route::put('luot-kham/{id}/ket-qua', [LuotKhamController::class, 'capNhatKetQua']); // Bác sĩ
Route::post('luot-kham/dat-lich', [LuotKhamController::class, 'datLich']); // Bệnh nhân đặt lịch
Route::get('luot-kham/gio-trong', [LuotKhamController::class, 'layGioTrong']); // API lấy giờ trống của Bác sĩ

// Quản lý hồ sơ bệnh nhân
Route::prefix('patient-profiles')->group(function () {
    Route::post('/', [PatientProfileController::class, 'store']);
    Route::get('/search-by-code', [PatientProfileController::class, 'findByCode']);
    Route::get('/search-by-info', [PatientProfileController::class, 'findByInfo']);
});

// Phân hệ Thanh toán VNPay
Route::get('/thanh-toan/vnpay/{id}', [PaymentController::class, 'taoLinkVNPay']);
Route::get('/thanh-toan/vnpay-return', [PaymentController::class, 'vnpayReturn']); 

// Phân hệ Thanh toán MoMo
Route::get('/thanh-toan/momo/{id}', [PaymentController::class, 'taoLinkMoMo']);
Route::post('/thanh-toan/momo-notify', [PaymentController::class, 'momoNotify']); 

// Phân hệ Thống kê & Báo cáo
Route::get('/thong-ke/tong-quan', [ThongKeController::class, 'tongQuan']); // Đã thêm Route thống kê
