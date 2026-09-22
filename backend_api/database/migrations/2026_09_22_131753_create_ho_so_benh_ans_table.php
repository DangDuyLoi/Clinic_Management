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
        Schema::create('ho_so_benh_an', function (Blueprint $table) {
        $table->id('ma_ho_so');
        $table->foreignId('ma_benh_nhan')->constrained('benh_nhan', 'ma_benh_nhan');
        $table->text('tien_su_benh')->nullable();
        $table->text('nhom_mau', 5)->nullable();
        $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ho_so_benh_ans');
    }
};
