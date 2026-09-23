<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NhatKyHeThong extends Model
{
    protected $table = 'NhatKyHeThong';
    protected $primaryKey = 'ma_nhat_ky';
    public $timestamps = false;

    protected $fillable = [
        'ma_tk', 'hanh_dong', 'bang_tac_dong',
        'du_lieu_cu', 'du_lieu_moi', 'thoi_gian',
    ];

    protected $casts = [
        'du_lieu_cu'  => 'array',
        'du_lieu_moi' => 'array',
    ];

    public function taiKhoan()
    {
        return $this->belongsTo(TaiKhoan::class, 'ma_tk');
    }
}