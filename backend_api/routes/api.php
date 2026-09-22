<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\ChuyenKhoaController;

Route::prefix('chuyen-khoa')->group(function () {
    Route::get('/', [ChuyenKhoaController::class, 'index']);
    Route::post('/', [ChuyenKhoaController::class, 'store']);
    Route::put('/{id}', [ChuyenKhoaController::class, 'update']);
    Route::delete('/{id}', [ChuyenKhoaController::class, 'destroy']);
});
use App\Http\Controllers\DichVuController;

// Quản lý Dịch vụ khám bệnh
Route::get('dich-vu', [DichVuController::class, 'index']);
Route::post('dich-vu', [DichVuController::class, 'store']);
Route::put('dich-vu/{id}', [DichVuController::class, 'update']);
Route::delete('dich-vu/{id}', [DichVuController::class, 'destroy']);

use App\Http\Controllers\Api\AuthController;

Route::post('/send-otp', [AuthController::class, 'sendOtp']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/set-password', [AuthController::class, 'setPassword']);
Route::post('/login', [AuthController::class, 'login']);

use App\Http\Controllers\LuotKhamController;

// Phân hệ Lễ tân
Route::put('luot-kham/{id}/tiep-nhan', [LuotKhamController::class, 'tiepNhan']);

// Phân hệ Bác sĩ
Route::put('luot-kham/{id}/ket-qua', [LuotKhamController::class, 'capNhatKetQua']);
