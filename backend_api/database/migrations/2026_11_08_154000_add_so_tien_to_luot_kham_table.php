<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('luot_kham', 'so_tien')) {
            Schema::table('luot_kham', function (Blueprint $table) {
                $table->decimal('so_tien', 12, 2)
                    ->nullable()
                    ->after('trang_thai')
                    ->comment('Số tiền khám được ghi nhận khi đặt lịch');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('luot_kham', 'so_tien')) {
            Schema::table('luot_kham', function (Blueprint $table) {
                $table->dropColumn('so_tien');
            });
        }
    }
};
