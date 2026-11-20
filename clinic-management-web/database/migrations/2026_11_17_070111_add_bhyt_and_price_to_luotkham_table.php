<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('luotkham', function (Blueprint $table) {
            if (! Schema::hasColumn('luotkham', 'is_bhyt')) {
                $table->boolean('is_bhyt')->default(false)->after('trang_thai')->comment('Có sử dụng BHYT hay không');
            }
            if (! Schema::hasColumn('luotkham', 'ma_the_bhyt')) {
                $table->string('ma_the_bhyt', 25)->nullable()->after('is_bhyt')->comment('Mã thẻ BHYT');
            }
            if (! Schema::hasColumn('luotkham', 'so_tien')) {
                $table->decimal('so_tien', 12, 2)->nullable()->after('ma_the_bhyt')->comment('Số tiền khám');
            }
        });
    }

    public function down(): void
    {
        Schema::table('luotkham', function (Blueprint $table) {
            $table->dropColumn(['is_bhyt', 'ma_the_bhyt', 'so_tien']);
        });
    }
};
