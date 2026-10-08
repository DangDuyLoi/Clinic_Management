<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;
use App\Models\User;
use App\Services\FCMService;

class SendAppointmentReminders extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-reminders';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Gửi thông báo nhắc nhở lịch khám trước 1 ngày cho bệnh nhân';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // Lấy ngày mai
        $tomorrow = Carbon::tomorrow();
        
        $this->info("Bắt đầu quét lịch khám cho ngày: " . $tomorrow->format('Y-m-d'));
        Log::info("Bắt đầu quét lịch khám để nhắc nhở cho ngày: " . $tomorrow->format('Y-m-d'));

        // Lấy tất cả lượt khám có trạng thái 'cho_kham' và diễn ra vào ngày mai
        $luotKhams = DB::table('luot_kham')
            ->where('trang_thai', 'cho_kham')
            ->whereDate('thoi_gian_den_kham', $tomorrow)
            ->get();

        if ($luotKhams->isEmpty()) {
            $this->info("Không có lịch khám nào vào ngày mai cần nhắc nhở.");
            return;
        }

        $count = 0;

        foreach ($luotKhams as $luotKham) {
            // Tìm hồ sơ
            $hoSo = DB::table('ho_so_benh_an')->where('ma_ho_so', $luotKham->ma_ho_so)->first();
            if (!$hoSo) continue;

            // Tìm bệnh nhân
            $benhNhan = DB::table('benh_nhan')->where('ma_benh_nhan', $hoSo->ma_benh_nhan)->first();
            if (!$benhNhan) continue;

            // Tìm user
            $user = User::where('phone_number', $benhNhan->so_dien_thoai)->first();
            if (!$user || empty($user->fcm_token)) continue;

            // Format giờ khám
            $thoiGian = Carbon::parse($luotKham->thoi_gian_den_kham)->format('H:i');

            // Gửi FCM
            $success = FCMService::sendNotification(
                $user->fcm_token,
                '⏰ Nhắc nhở lịch khám ngày mai',
                "Chào bạn, bạn có một lịch hẹn khám vào lúc {$thoiGian} ngày mai. Vui lòng đến sớm 15 phút để làm thủ tục nhé!",
                [
                    'type' => 'booking_reminder',
                    'ma_luot_kham' => (string)$luotKham->ma_luot_kham,
                ]
            );

            if ($success) {
                $count++;
            }
        }

        $this->info("Đã gửi thành công $count thông báo nhắc nhở.");
        Log::info("Hoàn tất gửi $count thông báo nhắc nhở lịch khám cho ngày mai.");
    }
}
