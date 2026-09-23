<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChiTietDonThuoc extends Model
{
    protected $table = 'ChiTietDonThuoc';
    protected $primaryKey = 'ma_chi_tiet';
    public $timestamps = false;

    protected $fillable = ['ma_don_thuoc', 'ma_thuoc', 'so_luong', 'lieu_luong', 'thanh_tien'];

    public function donThuoc()
    {
        return $this->belongsTo(DonThuoc::class, 'ma_don_thuoc');
    }

    public function thuoc()
    {
        return $this->belongsTo(Thuoc::class, 'ma_thuoc');
    }
}