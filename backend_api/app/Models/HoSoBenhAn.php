<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HoSoBenhAn extends Model
{
    protected $table = 'ho_so_benh_an';
    protected $primaryKey = 'ma_ho_so';

    protected $fillable = [
        'ma_benh_nhan', 'tien_su_benh', 'nhom_mau',
        'ho_chu_lot', 'ten', 'ngay_sinh', 'dan_toc', 'gioi_tinh',
        'nghe_nghiep', 'quan_he', 'so_dien_thoai', 'nguoi_lien_he_khan_cap', 'email',
        'cccd', 'ho_chieu', 'so_dinh_danh', 'so_the_bhyt', 'quoc_gia',
        'tinh_thanh', 'quan_huyen', 'phuong_xa', 'so_nha'
    ];

    public function benhNhan()
    {
        return $this->belongsTo(BenhNhan::class, 'ma_benh_nhan', 'ma_benh_nhan');
    }
}
