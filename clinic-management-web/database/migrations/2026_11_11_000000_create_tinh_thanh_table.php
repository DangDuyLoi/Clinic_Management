<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('TinhThanh', function (Blueprint $table) {
            $table->string('ma_tinh', 2)->primary();
            $table->string('ten_tinh', 100);
            $table->string('loai', 20)->nullable(); // 'ThanhPho' hoặc 'Tinh'
            $table->text('ghi_chu')->nullable();     // ghi chú sáp nhập
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('TinhThanh');
    }
};