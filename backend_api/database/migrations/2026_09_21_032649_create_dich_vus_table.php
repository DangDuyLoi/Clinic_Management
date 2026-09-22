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
    Schema::create('dich_vu', function (Blueprint $table) {
        $table->id('ma_dich_vu'); // Khóa chính
        $table->string('ten_dich_vu');
        $table->integer('don_gia'); // Đơn giá tính bằng VNĐ
        $table->integer('thoi_gian_thuc_hien'); // Thời gian khám trung bình (phút)
        $table->boolean('trang_thai')->default(true); // true: Đang áp dụng, false: Đã ngừng
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('dich_vus');
    }
};
