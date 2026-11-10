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
        Schema::table('ho_so_benh_an', function (Blueprint $table) {
            if (!Schema::hasColumn('ho_so_benh_an', 'nguoi_lien_he_khan_cap')) {
                $table->string('nguoi_lien_he_khan_cap', 15)->nullable()->after('so_dien_thoai')
                    ->comment('Số điện thoại cha mẹ hoặc người giám hộ (bắt buộc với trẻ em dưới 14 tuổi)');
            }
            if (!Schema::hasColumn('ho_so_benh_an', 'so_the_bhyt')) {
                $table->string('so_the_bhyt', 20)->nullable()->after('so_dinh_danh')
                    ->comment('Mã thẻ BHYT chuẩn 15 ký tự BHXH');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('ho_so_benh_an', function (Blueprint $table) {
            if (Schema::hasColumn('ho_so_benh_an', 'so_the_bhyt')) {
                $table->dropColumn('so_the_bhyt');
            }
            if (Schema::hasColumn('ho_so_benh_an', 'nguoi_lien_he_khan_cap')) {
                $table->dropColumn('nguoi_lien_he_khan_cap');
            }
        });
    }
};

