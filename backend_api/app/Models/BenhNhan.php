<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class BenhNhan extends Model {
    protected $table = 'benh_nhan';
    protected $primaryKey = 'ma_benh_nhan';
    protected $fillable = ['ho_ten', 'ngay_sinh', 'gioi_tinh', 'so_dien_thoai', 'dia_chi'];

    // Một bệnh nhân có một hồ sơ gốc
    public function hoSoBenhAn() {
        return $this->hasOne(HoSoBenhAn::class, 'ma_benh_nhan', 'ma_benh_nhan');
    }
}
