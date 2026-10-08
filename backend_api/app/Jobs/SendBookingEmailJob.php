<?php

namespace App\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use App\Services\FCMService;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

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
            $luotKham = $this->luotKham;
            
            Log::info('Đang xử lý gửi thông báo xác nhận cho lịch khám ID: ' . $luotKham->ma_luot_kham);

            // Tìm FCM Token qua chuỗi: luot_kham -> ho_so_benh_an -> benh_nhan -> users (theo số điện thoại)
            $hoSo = DB::table('ho_so_benh_an')->where('ma_ho_so', $luotKham->ma_ho_so)->first();
            
            if (!$hoSo) {
                Log::warning("Không tìm thấy hồ sơ bệnh án với ma_ho_so: {$luotKham->ma_ho_so}");
                return;
            }

            $benhNhan = DB::table('benh_nhan')->where('ma_benh_nhan', $hoSo->ma_benh_nhan)->first();
            
            if (!$benhNhan) {
                Log::warning("Không tìm thấy bệnh nhân với ma_benh_nhan: {$hoSo->ma_benh_nhan}");
                return;
            }

            // Tìm user theo số điện thoại bệnh nhân (Xử lý trường hợp 0xxx và +84xxx)
            $phone = $benhNhan->so_dien_thoai;
            $phone0 = str_starts_with($phone, '+84') ? '0' . substr($phone, 3) : $phone;
            $phone84 = str_starts_with($phone, '0') ? '+84' . substr($phone, 1) : $phone;

            $user = User::whereIn('phone_number', [$phone, $phone0, $phone84])->first();

            if (!$user || empty($user->fcm_token)) {
                Log::info("User không có FCM token, bỏ qua push notification cho lịch khám ID: {$luotKham->ma_luot_kham}");
                return;
            }

            // Format thời gian đẹp
            $thoiGian = Carbon::parse($luotKham->thoi_gian_den_kham)->format('H:i d/m/Y');

            // Gửi Push Notification qua FCM
            $success = FCMService::sendNotification(
                $user->fcm_token,
                '✅ Đặt khám thành công!',
                "Lịch hẹn của bạn vào lúc {$thoiGian} đã được xác nhận. Mã lượt khám: #{$luotKham->ma_luot_kham}",
                [
                    'type' => 'booking_confirmed',
                    'ma_luot_kham' => (string)$luotKham->ma_luot_kham,
                ]
            );

            if ($success) {
                Log::info("Push notification đã gửi thành công cho lịch khám ID: {$luotKham->ma_luot_kham}");
            }

        } catch (\Exception $e) {
            Log::error('Lỗi khi xử lý hàng đợi gửi thông báo: ' . $e->getMessage());
        }
    }
}
