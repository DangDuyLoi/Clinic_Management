<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CancelUnpaidAppointments extends Command
{
    // Tên lệnh để hệ thống gọi ngầm
    protected $signature = 'appointments:cancel-unpaid';

    // Mô tả lệnh
    protected $description = 'Tự động hủy lịch khám và hóa đơn chưa thanh toán sau 15 phút';

    public function handle()
    {
        // Lấy mốc thời gian 15 phút trước
        $timeLimit = Carbon::now()->subMinutes(15);

        // Tìm các hóa đơn chưa thanh toán quá 15 phút
        $hoaDons = DB::table('hoa_don')
            ->where('trang_thai', 'ChuaThanhToan')
            ->where('created_at', '<=', $timeLimit)
            ->get();

        if ($hoaDons->isEmpty()) {
            $this->info('Không có lịch hẹn nào quá hạn.');
            return;
        }

        foreach ($hoaDons as $hd) {
            // 1. Chuyển trạng thái Hóa đơn thành 'DaHuy'
            DB::table('hoa_don')->where('ma_hoa_don', $hd->ma_hoa_don)->update([
                'trang_thai' => 'DaHuy',
                'updated_at' => Carbon::now()
            ]);

            // 2. Chuyển trạng thái Lượt khám thành 'DaHuy' để giải phóng khung giờ
            // (Lưu ý: Nếu bảng hoa_don của bạn dùng tên cột khác thay vì luot_kham_id để liên kết, hãy đổi lại cho khớp)
            if (isset($hd->luot_kham_id)) {
                DB::table('luot_kham')->where('id', $hd->luot_kham_id)->update([
                    'trang_thai' => 'DaHuy',
                    'updated_at' => Carbon::now()
                ]);
            }
        }

        $this->info('Đã hủy tự động ' . $hoaDons->count() . ' lịch chưa thanh toán.');
    }
}
