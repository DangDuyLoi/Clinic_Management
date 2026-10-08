<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Services\FCMService;

class SendTestNotification extends Command
{
    protected $signature = 'app:send-test';
    protected $description = 'Gửi thử 1 Push Notification đến tất cả thiết bị đã đăng nhập';

    public function handle()
    {
        $users = User::whereNotNull('fcm_token')->get();

        if ($users->isEmpty()) {
            $this->warn("Chưa có User nào trong Database có fcm_token. Bạn cần mở App trên điện thoại và Đăng Nhập lại để app gửi token lên!");
            return;
        }

        $count = 0;
        foreach ($users as $user) {
            $success = FCMService::sendNotification(
                $user->fcm_token,
                '🚀 Test Thông báo FCM',
                "Tuyệt vời! Nếu bạn đọc được dòng này thì luồng Push Notification End-to-End đã hoạt động hoàn hảo!",
                ['type' => 'test_message']
            );
            if ($success) $count++;
        }

        $this->info("Đã gửi thành công $count thông báo test.");
    }
}
