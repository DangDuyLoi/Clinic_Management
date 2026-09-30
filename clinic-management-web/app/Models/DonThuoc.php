<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DonThuoc extends Model
{
    protected $table = 'DonThuoc';
    protected $primaryKey = 'ma_don_thuoc';
    public $timestamps = false;

    protected $fillable = ['ma_phien_kham', 'tong_tien', 'ngay_ke_don'];

    public function phienKham()
    {
        return $this->belongsTo(PhienKham::class, 'ma_phien_kham');
    }

    public function chiTiet()
    {
        return $this->hasMany(ChiTietDonThuoc::class, 'ma_don_thuoc');
    }
}