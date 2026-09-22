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
    Schema::create('benh_nhan', function (Blueprint $table) {
        $table->id('ma_benh_nhan');
        $table->string('ho_ten');
        $table->date('ngay_sinh');
        $table->boolean('gioi_tinh'); // 1: Nam, 0: Nữ
        $table->string('so_dien_thoai', 15)->unique();
        $table->string('dia_chi')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('benh_nhans');
    }
};
