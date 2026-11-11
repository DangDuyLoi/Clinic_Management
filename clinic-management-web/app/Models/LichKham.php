<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class LichKham extends Model
{
    // Trỏ đúng vào bảng mới
    protected $table = 'LuotKham';
    protected $primaryKey = 'ma_luot_kham';
    public $timestamps = true;

    protected $fillable = [
        'ma_ho_so', 'ma_bac_si', 'so_thu_tu', 'thoi_gian_den_kham', 
        'trang_thai', 'chan_doan', 'hinh_thuc_kham', 'priority_level',
        'qr_token'
    ];

    protected $casts = [
        'thoi_gian_den_kham' => 'datetime',
    ];

    public function hoSo() {
        return $this->belongsTo(HoSoBenhAn::class, 'ma_ho_so', 'ma_ho_so');
    }

    // Quan hệ với Bác sĩ
    public function bacSi() {
        return $this->belongsTo(BacSi::class, 'ma_bac_si', 'ma_bs');
    }

    // Hàm lấy Bệnh nhân thông qua Hồ sơ (Dùng cho Lễ tân/Bác sĩ)
    public function benhNhan() {
        return $this->hasOneThrough(
            BenhNhan::class, 
            HoSoBenhAn::class,
            'ma_ho_so', 'ma_benh_nhan', 'ma_ho_so', 'ma_benh_nhan'
        );
    }
}