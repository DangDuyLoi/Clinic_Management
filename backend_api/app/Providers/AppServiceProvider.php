<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\URL;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Ép buộc toàn bộ URL sinh ra chạy trên HTTPS khi ở môi trường Production (Render)
        if ($this->app->environment('production')) {
            URL::forceScheme('https');
        }
    }
}
