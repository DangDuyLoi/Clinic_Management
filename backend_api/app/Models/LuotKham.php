<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class LuotKham extends Model {
    protected $table = 'luot_kham';
    protected $primaryKey = 'ma_luot_kham';
    protected $fillable = ['ma_ho_so', 'ma_bac_si', 'thoi_gian_den_kham', 'trang_thai', 'chan_doan'];
}
