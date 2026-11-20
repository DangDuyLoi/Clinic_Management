<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Kiểm tra an toàn — không thêm nếu cột đã có
        if (! Schema::hasColumn('chuyenkhoa', 'gia_kham')) {
            Schema::table('chuyenkhoa', function (Blueprint $table) {
                $table->decimal('gia_kham', 12, 2)
                    ->default(150000)
                    ->after('mo_ta')
                    ->comment('Giá khám theo chuyên khoa (VND)');
            });
        }

        // Cập nhật giá mẫu cho 8 chuyên khoa hiện có
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Nội tổng hợp')->update(['gia_kham' => 150000]);
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Tim mạch')->update(['gia_kham' => 200000]);
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Da liễu')->update(['gia_kham' => 120000]);
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Nhi khoa')->update(['gia_kham' => 150000]);
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Tai Mũi Họng')->update(['gia_kham' => 150000]);
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Xương khớp')->update(['gia_kham' => 150000]);
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Sản phụ khoa')->update(['gia_kham' => 200000]);
        DB::table('chuyenkhoa')->where('ten_chuyen_khoa', 'Mắt')->update(['gia_kham' => 150000]);
    }

    public function down(): void
    {
        if (Schema::hasColumn('chuyenkhoa', 'gia_kham')) {
            Schema::table('chuyenkhoa', function (Blueprint $table) {
                $table->dropColumn('gia_kham');
            });
        }
    }
};
