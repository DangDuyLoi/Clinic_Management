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
            $table->string('ho_chieu', 20)->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('benhnhan', function (Blueprint $table) {
            $table->dropColumn('ho_chieu');
        });
    }
};
