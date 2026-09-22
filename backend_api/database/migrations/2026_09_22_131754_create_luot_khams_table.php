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
       Schema::create('luot_kham', function (Blueprint $table) {
        $table->id('ma_luot_kham');
        $table->foreignId('ma_ho_so')->constrained('ho_so_benh_an', 'ma_ho_so');
        $table->unsignedBigInteger('ma_bac_si')->nullable(); // Null khi chưa phân bổ
        $table->dateTime('thoi_gian_den_kham');
        $table->enum('trang_thai', ['cho_kham', 'dang_kham', 'hoan_thanh', 'huy'])->default('cho_kham');
        $table->text('chan_doan')->nullable();
        $table->timestamps();
});
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('luot_khams');
    }
};
