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
        Schema::table('benhnhan', function (Blueprint $table) {
            $table->string('tinh_thanh', 100)->nullable();
            $table->string('phuong_xa', 100)->nullable();
            $table->string('so_nha')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('benhnhan', function (Blueprint $table) {
            $table->dropColumn(['tinh_thanh', 'phuong_xa', 'so_nha']);
        });
    }
};
