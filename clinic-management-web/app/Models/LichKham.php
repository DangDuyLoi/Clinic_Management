<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LichKham extends Model
{
    protected $table = 'LichKham';
    protected $primaryKey = 'ma_lich_dat';
    public $timestamps = false;

    protected $fillable = [
        'ma_bn', 'ma_bs', 'ngay_kham', 'ma_khung_gio',
        'thoi_gian_den_quay', 'khach_vang_lai', 'diem_uu_tien',
        'trang_thai', 'ghi_chu', 'thoi_diem_dat',
    ];

    protected $casts = [
        'khach_vang_lai' => 'boolean',
        'ngay_kham'      => 'date',
    ];

    public function benhNhan()
    {
        return $this->belongsTo(BenhNhan::class, 'ma_bn');
    }

    public function bacSi()
    {
        return $this->belongsTo(BacSi::class, 'ma_bs');
    }

    public function khungGio()
    {
        return $this->belongsTo(KhungGio::class, 'ma_khung_gio');
    }
}