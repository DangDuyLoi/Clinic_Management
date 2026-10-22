<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Thêm cột giá khám vào bảng ChuyenKhoa.
     * Mỗi chuyên khoa có giá khám riêng biệt (thay vì hardcode 150.000đ cho tất cả).
     */
    public function up(): void
    {
        Schema::table('ChuyenKhoa', function (Blueprint $table) {
            $table->decimal('gia_kham', 12, 2)->default(150000)->after('mo_ta')
                  ->comment('Giá khám theo chuyên khoa (VND)');
        });

        // Cập nhật giá khám mẫu cho các chuyên khoa đã có sẵn
        DB::table('ChuyenKhoa')->where('ten_chuyen_khoa', 'Nội tổng hợp')->update(['gia_kham' => 150000]);
        DB::table('ChuyenKhoa')->where('ten_chuyen_khoa', 'Tim mạch')->update(['gia_kham' => 200000]);
        DB::table('ChuyenKhoa')->where('ten_chuyen_khoa', 'Da liễu')->update(['gia_kham' => 120000]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('ChuyenKhoa', function (Blueprint $table) {
            $table->dropColumn('gia_kham');
        });
    }
};
