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
        \Illuminate\Support\Facades\DB::statement("ALTER TABLE luot_kham MODIFY COLUMN trang_thai ENUM('cho_thanh_toan', 'da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh', 'huy') DEFAULT 'cho_thanh_toan'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        \Illuminate\Support\Facades\DB::statement("ALTER TABLE luot_kham MODIFY COLUMN trang_thai ENUM('cho_kham', 'dang_kham', 'hoan_thanh', 'huy') DEFAULT 'cho_kham'");
    }
};
