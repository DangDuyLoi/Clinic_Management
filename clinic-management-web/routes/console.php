<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule; // Thêm dòng import này

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Thêm dòng này để lên lịch chạy job tự động mỗi phút
Schedule::command('appointments:cancel-unpaid')->everyMinute();
