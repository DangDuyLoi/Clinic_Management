<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HoSoBenhAn extends Model
{
    protected $table = 'HoSoBenhAn';
    protected $primaryKey = 'ma_ho_so';
    public $timestamps = false;

    protected $fillable = [
        'ma_benh_nhan', 'tien_su_benh', 'nhom_mau', 'ma_bhyt', 'muc_huong_bhyt', 
        'ngay_het_han_bhyt', 'la_thai_phu', 'la_khuyet_tat',
        'ho_chu_lot', 'ten', 'ngay_sinh', 'dan_toc', 'gioi_tinh', 
        'nghe_nghiep', 'quan_he', 'so_dien_thoai', 'email', 'cccd', 
        'ho_chieu', 'so_dinh_danh', 'quoc_gia', 'tinh_thanh', 
        'quan_huyen', 'phuong_xa', 'so_nha'
    ];

    // Quan hệ với bảng Bệnh nhân
    public function benhNhan() {
        return $this->belongsTo(BenhNhan::class, 'ma_benh_nhan', 'ma_benh_nhan');
    }

    // Quan hệ với bảng Lượt khám
    public function lichKham() {
        return $this->hasMany(LichKham::class, 'ma_ho_so', 'ma_ho_so');
    }
}