<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CaLamViec extends Model
{
    protected $table = 'CaLamViec';
    protected $primaryKey = 'ma_ca';
    public $timestamps = false;

    protected $fillable = [
        'ten_ca', 'gio_bat_dau', 'gio_ket_thuc', 'luot_kham_toi_da',
    ];

    public function khungGio()
    {
        return $this->hasMany(KhungGio::class, 'ma_ca');
    }
}