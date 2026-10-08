<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ThongBao extends Model
{
    protected $table = 'ThongBao';
    protected $primaryKey = 'ma_thong_bao';
    public $timestamps = false;

    protected $fillable = [
        'ma_tk', 'tieu_de', 'noi_dung', 'loai',
        'duong_dan', 'da_doc', 'thoi_gian',
    ];

    protected $casts = [
        'da_doc' => 'boolean',
        'thoi_gian' => 'datetime',
    ];

    public function taiKhoan()
    {
        return $this->belongsTo(TaiKhoan::class, 'ma_tk');
    }

    /* ============================================================
       HELPER — Tạo thông báo
       ============================================================ */
    public static function gui($maTk, $tieuDe, $noiDung, $loai = 'he_thong', $duongDan = null)
    {
        return self::create([
            'ma_tk'     => $maTk,
            'tieu_de'   => $tieuDe,
            'noi_dung'  => $noiDung,
            'loai'      => $loai,
            'duong_dan' => $duongDan,
            'da_doc'    => false,
            'thoi_gian' => now(),
        ]);
    }

    /**
     * Gửi thông báo đến TẤT CẢ tài khoản có vai trò X
     */
    public static function guiTheoVaiTro($vaiTro, $tieuDe, $noiDung, $loai = 'he_thong', $duongDan = null)
    {
        $dsTk = TaiKhoan::where('vai_tro', $vaiTro)
            ->where('trang_thai', true)
            ->pluck('ma_tk');

        foreach ($dsTk as $maTk) {
            self::gui($maTk, $tieuDe, $noiDung, $loai, $duongDan);
        }
    }
}