<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChuyenKhoa extends Model
{
    protected $table = 'ChuyenKhoa';
    protected $primaryKey = 'ma_chuyen_khoa';
    public $timestamps = false;

    protected $fillable = ['ten_chuyen_khoa', 'mo_ta'];

    public function bacSi()
    {
        return $this->hasMany(BacSi::class, 'ma_chuyen_khoa');
    }
}