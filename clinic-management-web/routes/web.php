<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\VNPayController;
Route::get('/', function () {
    return view('welcome');
});
Route::get('/vnpay/return', [VNPayController::class, 'return'])->name('vnpay.return');