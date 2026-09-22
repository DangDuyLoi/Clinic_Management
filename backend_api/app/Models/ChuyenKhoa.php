<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChuyenKhoa extends Model
{
    // Báo cho Laravel biết tên bảng và khóa chính xác
    protected $table = 'ChuyenKhoa';
    protected $primaryKey = 'ma_chuyen_khoa';

    // Tắt tính năng tự động thêm created_at và updated_at
    public $timestamps = false;

    // Cho phép thêm dữ liệu vào các cột này
    protected $fillable = [
        'ten_chuyen_khoa',
        'mo_ta',
        'trang_thai'
    ];
}
