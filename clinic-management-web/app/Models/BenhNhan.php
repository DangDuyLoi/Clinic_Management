<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BenhNhan extends Model
{
    protected $table = 'BenhNhan';
    protected $primaryKey = 'ma_bn';
    public $timestamps = false;

    protected $fillable = [
        'ma_tk',
        'ho_ten',
        'ngay_sinh',
        'gioi_tinh',
        'so_dien_thoai',
        'email',
        'cccd',
        'dia_chi',
        'nguoi_lien_he_khan_cap',
        'tien_su_benh',
        'di_ung',
        'nhom_mau',
    ];

    protected $casts = [
        'ngay_sinh' => 'date',
    ];

    /* ---------- Quan hệ ---------- */

    public function taiKhoan()
    {
        return $this->belongsTo(TaiKhoan::class, 'ma_tk');
    }

    public function lichKham()
    {
        return $this->hasMany(LichKham::class, 'ma_bn');
    }
}