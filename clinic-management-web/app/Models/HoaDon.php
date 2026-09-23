<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HoaDon extends Model
{
    protected $table = 'HoaDon';
    protected $primaryKey = 'ma_hoa_don';
    public $timestamps = false;

    protected $fillable = [
        'ma_phien_kham', 'tien_kham_benh', 'tien_dich_vu', 'tien_thuoc',
        'tong_cong', 'phuong_thuc', 'trang_thai', 'ngay_tao', 'ngay_thanh_toan',
    ];

    public function phienKham()
    {
        return $this->belongsTo(PhienKham::class, 'ma_phien_kham');
    }
}