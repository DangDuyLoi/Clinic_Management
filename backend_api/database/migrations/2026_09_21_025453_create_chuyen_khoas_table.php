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
    Schema::create('ChuyenKhoa', function (Blueprint $table) {
        $table->increments('ma_chuyen_khoa');
        $table->string('ten_chuyen_khoa', 100);
        $table->text('mo_ta')->nullable();
        $table->boolean('trang_thai')->default(true);
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ChuyenKhoa');
    }
};
