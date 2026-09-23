<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Thuoc extends Model
{
    protected $table = 'Thuoc';
    protected $primaryKey = 'ma_thuoc';
    public $timestamps = false;

    protected $fillable = ['ten_thuoc', 'don_vi_tinh', 'don_gia', 'so_luong_ton'];

    public function chiTietDonThuoc()
    {
        return $this->hasMany(ChiTietDonThuoc::class, 'ma_thuoc');
    }
}