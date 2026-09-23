<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChiDinhDichVu extends Model
{
    protected $table = 'ChiDinhDichVu';
    protected $primaryKey = 'ma_chi_dinh';
    public $timestamps = false;

    protected $fillable = ['ma_phien_kham', 'ma_dich_vu', 'ket_qua_chi_tiet', 'trang_thai'];

    public function phienKham()
    {
        return $this->belongsTo(PhienKham::class, 'ma_phien_kham');
    }

    public function dichVu()
    {
        return $this->belongsTo(DichVu::class, 'ma_dich_vu');
    }
}