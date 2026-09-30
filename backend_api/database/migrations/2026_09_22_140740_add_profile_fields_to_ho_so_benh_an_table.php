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
        Schema::table('ho_so_benh_an', function (Blueprint $table) {
            $table->string('ho_chu_lot')->nullable();
            $table->string('ten')->nullable();
            $table->date('ngay_sinh')->nullable();
            $table->string('dan_toc')->nullable();
            $table->tinyInteger('gioi_tinh')->nullable()->comment('1: Nam, 0: Nữ');
            $table->string('nghe_nghiep')->nullable();
            $table->string('quan_he')->nullable();
            $table->string('so_dien_thoai', 15)->nullable();
            $table->string('email')->nullable();
            $table->string('cccd', 20)->nullable();
            $table->string('ho_chieu', 20)->nullable();
            $table->string('so_dinh_danh', 20)->nullable();
            $table->string('quoc_gia')->nullable();
            $table->string('tinh_thanh')->nullable();
            $table->string('phuong_xa')->nullable();
            $table->string('so_nha')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('ho_so_benh_an', function (Blueprint $table) {
            $table->dropColumn([
                'ho_chu_lot', 'ten', 'ngay_sinh', 'dan_toc', 'gioi_tinh', 'nghe_nghiep', 'quan_he',
                'so_dien_thoai', 'email', 'cccd', 'ho_chieu', 'so_dinh_danh', 'quoc_gia', 'tinh_thanh', 'phuong_xa', 'so_nha'
            ]);
        });
    }
};
