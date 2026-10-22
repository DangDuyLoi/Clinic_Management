<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('luot_kham', 'so_thu_tu')) {
            Schema::table('luot_kham', function (Blueprint $table) {
                $table->integer('so_thu_tu')->nullable()->after('ma_bac_si')->comment('Số thứ tự khám trong ngày của bác sĩ');
            });
        }

        // Tự động gán số thứ tự cho các lượt khám đã có trong database theo từng ngày và từng bác sĩ
        $luotKhams = DB::table('luot_kham')
            ->orderBy('ma_bac_si')
            ->orderBy('thoi_gian_den_kham')
            ->orderBy('ma_luot_kham')
            ->get();

        $sttCounter = [];
        foreach ($luotKhams as $lk) {
            $key = ($lk->ma_bac_si ?? 0) . '_' . substr($lk->thoi_gian_den_kham, 0, 10);
            if (!isset($sttCounter[$key])) {
                $sttCounter[$key] = 1;
            } else {
                $sttCounter[$key]++;
            }

            DB::table('luot_kham')
                ->where('ma_luot_kham', $lk->ma_luot_kham)
                ->update(['so_thu_tu' => $sttCounter[$key]]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('luot_kham', 'so_thu_tu')) {
            Schema::table('luot_kham', function (Blueprint $table) {
                $table->dropColumn('so_thu_tu');
            });
        }
    }
};
