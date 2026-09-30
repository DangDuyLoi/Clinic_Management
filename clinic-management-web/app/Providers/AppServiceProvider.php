<?php

namespace App\Providers;

use App\Models\{
    BacSi,
    BenhNhan,
    ChuyenKhoa,
    DichVu,
    DonThuoc,
    HoaDon,
    LichKham,
    PhienKham,
    TaiKhoan,
    Thuoc
};
use App\Observers\AuditObserver;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(): void
    {
        // Đăng ký Observer cho các model chính
        LichKham::observe(AuditObserver::class);
        PhienKham::observe(AuditObserver::class);
        HoaDon::observe(AuditObserver::class);
        TaiKhoan::observe(AuditObserver::class);
        BacSi::observe(AuditObserver::class);
        BenhNhan::observe(AuditObserver::class);
        ChuyenKhoa::observe(AuditObserver::class);
        DichVu::observe(AuditObserver::class);
        Thuoc::observe(AuditObserver::class);
        DonThuoc::observe(AuditObserver::class);
    }
}