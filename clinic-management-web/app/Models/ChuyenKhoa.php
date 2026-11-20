<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChuyenKhoa extends Model
{
    protected $table = 'chuyenkhoa';

    protected $primaryKey = 'ma_chuyen_khoa';

    public $timestamps = false;

    protected $fillable = ['ten_chuyen_khoa', 'mo_ta', 'gia_kham', 'phong_kham'];

    public function bacSi()
    {
        return $this->hasMany(BacSi::class, 'ma_chuyen_khoa');
    }
}
