<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BacSi extends Model
{
    protected $table = 'BacSi';
    protected $primaryKey = 'ma_bs';
    public $timestamps = false;

    protected $fillable = [
        'ma_tk',
        'ma_chuyen_khoa',
        'ho_ten',
        'trinh_do',
        'luot_kham_toi_da_moi_ca',
    ];

    /* ---------- Quan hệ ---------- */

    public function taiKhoan()
    {
        return $this->belongsTo(TaiKhoan::class, 'ma_tk');
    }

    public function chuyenKhoa()
    {
        return $this->belongsTo(ChuyenKhoa::class, 'ma_chuyen_khoa');
    }

    public function lichKham()
    {
        return $this->hasMany(LichKham::class, 'ma_bs');
    }
}