<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('chuyenkhoa', 'phong_kham')) {
            Schema::table('chuyenkhoa', function (Blueprint $table): void {
                $table->string('phong_kham', 100)->nullable()->after('mo_ta');
            });
        }

        if (! Schema::hasColumn('phienkham', 'phong_kham')) {
            Schema::table('phienkham', function (Blueprint $table): void {
                $table->string('phong_kham', 100)->nullable()->after('ma_lich_dat');
            });
        }

        $roomsBySpecialty = [
            'Nội tổng hợp' => 'Phòng 101 - Tầng 1',
            'Tim mạch' => 'Phòng 102 - Tầng 1',
            'Da liễu' => 'Phòng 103 - Tầng 1',
            'Nhi khoa' => 'Phòng 104 - Tầng 1',
            'Tai Mũi Họng' => 'Phòng 105 - Tầng 1',
            'Xương khớp' => 'Phòng 106 - Tầng 1',
            'Sản phụ khoa' => 'Phòng 107 - Tầng 1',
            'Mắt' => 'Phòng 108 - Tầng 1',
        ];

        foreach ($roomsBySpecialty as $specialty => $room) {
            DB::table('chuyenkhoa')
                ->where('ten_chuyen_khoa', $specialty)
                ->update(['phong_kham' => $room]);
        }

        DB::table('phienkham')
            ->join('luotkham', 'luotkham.ma_luot_kham', '=', 'phienkham.ma_lich_dat')
            ->join('bacsi', 'bacsi.ma_bs', '=', 'luotkham.ma_bac_si')
            ->join('chuyenkhoa', 'chuyenkhoa.ma_chuyen_khoa', '=', 'bacsi.ma_chuyen_khoa')
            ->whereNull('phienkham.phong_kham')
            ->whereNotNull('chuyenkhoa.phong_kham')
            ->update(['phienkham.phong_kham' => DB::raw('chuyenkhoa.phong_kham')]);
    }

    public function down(): void
    {
        if (Schema::hasColumn('phienkham', 'phong_kham')) {
            Schema::table('phienkham', function (Blueprint $table): void {
                $table->dropColumn('phong_kham');
            });
        }

        if (Schema::hasColumn('chuyenkhoa', 'phong_kham')) {
            Schema::table('chuyenkhoa', function (Blueprint $table): void {
                $table->dropColumn('phong_kham');
            });
        }
    }
};
