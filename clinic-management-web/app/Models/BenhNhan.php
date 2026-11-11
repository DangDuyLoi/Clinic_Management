<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BenhNhan extends Model
{
    protected $table = 'BenhNhan';
    protected $primaryKey = 'ma_benh_nhan';
    public $timestamps = false;

    protected $fillable = [
        'ma_tk', 'ho_ten', 'ngay_sinh', 'gioi_tinh', 'so_dien_thoai',
        'email', 'cccd', 'dia_chi', 'nguoi_lien_he_khan_cap',
        'tien_su_benh', 'di_ung', 'nhom_mau', 'ma_bhyt', 
        'muc_huong_bhyt', 'ngay_het_han_bhyt','que_quan'
    ];

    protected $casts = [
        'ngay_sinh' => 'date',
        'ngay_het_han_bhyt' => 'date',
    ];

    // Quan hệ với Tài khoản
    public function taiKhoan()
    {
        return $this->belongsTo(TaiKhoan::class, 'ma_tk');
    }

    // Quan hệ với Hồ sơ bệnh án
    public function hoSoBenhAn()
    {
        return $this->hasOne(HoSoBenhAn::class, 'ma_benh_nhan', 'ma_benh_nhan');
    }

    // Quan hệ với Lịch khám (Lượt khám)
    public function lichKham()
    {
        return $this->hasManyThrough(
            LichKham::class, 
            HoSoBenhAn::class, 
            'ma_benh_nhan', // FK trên bảng ho_so_benh_an
            'ma_ho_so',     // FK trên bảng luot_kham
            'ma_benh_nhan', // PK trên bảng benh_nhan
            'ma_ho_so'      // PK trên bảng ho_so_benh_an
        );
    }
}