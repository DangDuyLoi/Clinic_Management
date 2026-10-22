<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('ho_so_benh_an', 'quan_huyen')) {
            Schema::table('ho_so_benh_an', function (Blueprint $table) {
                $table->string('quan_huyen', 100)->nullable()->after('tinh_thanh')->comment('Quận/Huyện');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('ho_so_benh_an', 'quan_huyen')) {
            Schema::table('ho_so_benh_an', function (Blueprint $table) {
                $table->dropColumn('quan_huyen');
            });
        }
    }
};
