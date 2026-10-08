<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

use Illuminate\Support\Facades\Schedule;

// Chạy job gửi thông báo nhắc lịch khám lúc 8:00 sáng mỗi ngày
Schedule::command('app:send-reminders')->dailyAt('08:00');
