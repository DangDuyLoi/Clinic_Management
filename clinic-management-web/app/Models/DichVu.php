<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DichVu extends Model
{
    protected $table = 'DichVu';
    protected $primaryKey = 'ma_dich_vu';
    public $timestamps = false;

    protected $fillable = ['ten_dich_vu', 'don_gia', 'mo_ta'];

    public function chiDinh()
    {
        return $this->hasMany(ChiDinhDichVu::class, 'ma_dich_vu');
    }
}