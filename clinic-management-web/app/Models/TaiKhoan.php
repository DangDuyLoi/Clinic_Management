<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Tymon\JWTAuth\Contracts\JWTSubject;

class TaiKhoan extends Authenticatable implements JWTSubject
{
    protected $table = 'TaiKhoan';
    protected $primaryKey = 'ma_tk';
    public $timestamps = false;

    protected $fillable = [
        'ten_dang_nhap',
        'mat_khau',
        'vai_tro',
        'trang_thai',
    ];

    protected $hidden = [
        'mat_khau',
    ];

    protected $casts = [
        'trang_thai' => 'boolean',
    ];

    /* ============================================================
       JWT — 3 method BẮT BUỘC
       ============================================================ */

    /** JWT đọc cột mật khẩu đúng */
    public function getAuthPassword()
    {
        return $this->mat_khau;
    }

    /** JWT identifier */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /** JWT custom claims — nhét vai_tro vào token */
    public function getJWTCustomClaims()
    {
        return ['vai_tro' => $this->vai_tro];
    }

    /* ============================================================
       QUAN HỆ (Relationships)
       ============================================================ */

    /** 1 tài khoản có thể là 1 bác sĩ */
    public function bacSi()
    {
        return $this->hasOne(BacSi::class, 'ma_tk');
    }

    /** 1 tài khoản có thể là 1 bệnh nhân */
    public function benhNhan()
    {
        return $this->hasOne(BenhNhan::class, 'ma_tk');
    }

    /** 1 tài khoản có nhiều log */
    public function nhatKy()
    {
        return $this->hasMany(NhatKyHeThong::class, 'ma_tk');
    }

    /* ============================================================
       HELPERS
       ============================================================ */

    public function isAdmin(): bool
    {
        return $this->vai_tro === 'QuanTri';
    }

    public function isBacSi(): bool
    {
        return $this->vai_tro === 'BacSi';
    }

    public function isLeTan(): bool
    {
        return $this->vai_tro === 'LeTan';
    }

    public function isBenhNhan(): bool
    {
        return $this->vai_tro === 'BenhNhan';
    }
}