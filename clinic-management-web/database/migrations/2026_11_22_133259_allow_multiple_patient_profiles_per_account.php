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
            $table->dropUnique('ma_tk');
            $table->index('ma_tk', 'benhnhan_ma_tk_index');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('benhnhan', function (Blueprint $table) {
            $table->dropIndex('benhnhan_ma_tk_index');
            $table->unique('ma_tk', 'ma_tk');
        });
    }
};
