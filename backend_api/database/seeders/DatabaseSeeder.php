<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Đường dẫn tới file SQL bạn vừa tạo
        $sqlPath = database_path('data_mau.sql');

        // Yêu cầu Laravel tự động đọc và chạy file SQL đó
        if (File::exists($sqlPath)) {
            DB::unprepared(file_get_contents($sqlPath));
            $this->command->info('Thành công: Đã đồng bộ toàn bộ Dữ liệu mẫu từ file SQL!');
        } else {
            $this->command->error('Lỗi: Không tìm thấy file data_mau.sql');
        }
    }
}
