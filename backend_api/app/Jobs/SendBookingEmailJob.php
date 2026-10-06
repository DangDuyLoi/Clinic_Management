<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class SendBookingEmailJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected $luotKham;

    // Nhận dữ liệu truyền vào khi API gọi Job
    public function __construct($luotKham)
    {
        $this->luotKham = $luotKham;
    }

    // Logic thực thi khi Job chạy ngầm
    public function handle(): void
    {
        try {
            // Tạm thời ghi Log để test Queue. Khi cấu hình xong Mail, ta sẽ thay bằng lệnh gửi Mail thực tế.
            Log::info('Đang xử lý gửi email/thông báo xác nhận cho lịch khám ID: ' . $this->luotKham->ma_luot_kham);
        } catch (\Exception $e) {
            Log::error('Lỗi khi xử lý hàng đợi: ' . $e->getMessage());
        }
    }
}
