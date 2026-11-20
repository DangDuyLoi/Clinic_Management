<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Thuoc extends Model
{
    protected $table = 'thuoc';

    protected $primaryKey = 'ma_thuoc';

    public $timestamps = false;

    protected $fillable = ['ten_thuoc', 'don_vi_tinh', 'don_gia', 'so_luong_ton', 'is_bhyt'];

    protected $casts = [
        'is_bhyt' => 'boolean',
    ];

    public function chiTietDonThuoc()
    {
        return $this->hasMany(ChiTietDonThuoc::class, 'ma_thuoc');
    }
}
