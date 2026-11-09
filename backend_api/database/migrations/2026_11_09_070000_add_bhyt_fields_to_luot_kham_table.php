<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('luot_kham', function (Blueprint $table) {
            if (!Schema::hasColumn('luot_kham', 'is_bhyt')) {
                $table->boolean('is_bhyt')->default(false)->after('trang_thai')->comment('Có sử dụng BHYT hay không');
            }
            if (!Schema::hasColumn('luot_kham', 'ma_the_bhyt')) {
                $table->string('ma_the_bhyt', 25)->nullable()->after('is_bhyt')->comment('Mã thẻ BHYT 15 ký tự');
            }
        });
    }

    public function down(): void
    {
        Schema::table('luot_kham', function (Blueprint $table) {
            if (Schema::hasColumn('luot_kham', 'ma_the_bhyt')) {
                $table->dropColumn('ma_the_bhyt');
            }
            if (Schema::hasColumn('luot_kham', 'is_bhyt')) {
                $table->dropColumn('is_bhyt');
            }
        });
    }
};
