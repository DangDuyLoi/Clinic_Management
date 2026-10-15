<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        $initPath = database_path('database_init.sql');
        $sqlPath = database_path('data_mau.sql');

        // 1. Đảm bảo cấu trúc bảng đã được tạo
        if (File::exists($initPath)) {
            DB::statement('SET FOREIGN_KEY_CHECKS = 0;');
            DB::unprepared(File::get($initPath));
            DB::statement('SET FOREIGN_KEY_CHECKS = 1;');
            $this->command->info('Đã kiểm tra và đồng bộ cấu trúc bảng (schema)!');
        }

        // 2. Nạp dữ liệu mẫu từ data_mau.sql
        if (File::exists($sqlPath)) {
            DB::statement('SET FOREIGN_KEY_CHECKS = 0;');
            DB::unprepared(File::get($sqlPath));
            DB::statement('SET FOREIGN_KEY_CHECKS = 1;');
            $this->command->info('Thành công: Đã đồng bộ toàn bộ Dữ liệu mẫu từ file SQL!');
        } else {
            $this->command->error('Lỗi: Không tìm thấy file data_mau.sql');
        }

        // 3. Đồng bộ dữ liệu phân hệ Patient Mobile
        $this->call(MobilePatientSeeder::class);
    }
}
