<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('benhnhan', function (Blueprint $table) {
            if (! Schema::hasColumn('benhnhan', 'ho_chu_lot')) {
                $table->string('ho_chu_lot')->nullable()->after('ho_ten');
            }
            if (! Schema::hasColumn('benhnhan', 'ten')) {
                $table->string('ten')->nullable()->after('ho_chu_lot');
            }
        });
    }

    public function down(): void
    {
        Schema::table('benhnhan', function (Blueprint $table) {
            $table->dropColumn(['ho_chu_lot', 'ten']);
        });
    }
};
