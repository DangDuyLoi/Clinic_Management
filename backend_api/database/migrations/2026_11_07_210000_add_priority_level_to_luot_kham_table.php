<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Thêm cột priority_level vào bảng luot_kham
     * 1: Cấp cứu
     * 2: Trẻ em / Người già (≥60 tuổi)
     * 3: Thai phụ / Người khuyết tật
     * 4: Bệnh nhân thường (mặc định)
     */
    public function up(): void
    {
        if (!Schema::hasColumn('luot_kham', 'priority_level')) {
            Schema::table('luot_kham', function (Blueprint $table) {
                $table->tinyInteger('priority_level')
                    ->default(4)
                    ->after('so_thu_tu')
                    ->comment('1=Cấp cứu, 2=Trẻ em/Người già, 3=Thai phụ/Khuyết tật, 4=Thường');
            });
        }

        // Gán mặc định cho các bản ghi cũ (nếu chưa có giá trị)
        DB::table('luot_kham')
            ->whereNull('priority_level')
            ->update(['priority_level' => 4]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('luot_kham', 'priority_level')) {
            Schema::table('luot_kham', function (Blueprint $table) {
                $table->dropColumn('priority_level');
            });
        }
    }
};

