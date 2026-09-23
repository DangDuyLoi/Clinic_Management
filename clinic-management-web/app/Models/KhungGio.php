<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KhungGio extends Model
{
    protected $table = 'KhungGio';
    protected $primaryKey = 'ma_khung_gio';
    public $timestamps = false;

    protected $fillable = [
        'ma_ca', 'gio_bat_dau', 'gio_ket_thuc', 'luot_kham_toi_da',
    ];

    public function caLamViec()
    {
        return $this->belongsTo(CaLamViec::class, 'ma_ca');
    }

    public function lichKham()
    {
        return $this->hasMany(LichKham::class, 'ma_khung_gio');
    }
}