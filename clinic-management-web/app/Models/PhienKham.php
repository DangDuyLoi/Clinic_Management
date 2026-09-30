<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PhienKham extends Model
{
    protected $table = 'PhienKham';
    protected $primaryKey = 'ma_phien_kham';
    public $timestamps = false;

    protected $fillable = [
        'ma_lich_dat', 'chan_doan_so_bo', 'chan_doan_cuoi_cung',
        'ghi_chu_y_te', 'trang_thai', 'ngay_tao',
    ];

    public function lichKham()
    {
        return $this->belongsTo(LichKham::class, 'ma_lich_dat');
    }

    public function chiDinh()
    {
        return $this->hasMany(ChiDinhDichVu::class, 'ma_phien_kham');
    }

    public function donThuoc()
    {
        return $this->hasOne(DonThuoc::class, 'ma_phien_kham');
    }

    public function hoaDon()
    {
        return $this->hasOne(HoaDon::class, 'ma_phien_kham');
    }
}