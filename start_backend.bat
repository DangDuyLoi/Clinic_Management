@echo off
chcp 65001 >nul
title [HUIT CLINIC] BACKEND API (PORT 8080)
color 0A

set "PATH=C:\laragon\bin\php\php-8.3.30-Win32-vs16-x64;%PATH%"

echo =========================================================
echo       KHOI DONG BACKEND API (LARAVEL) - PORT 8080
echo =========================================================
echo.
cd /d "%~dp0backend_api"
php artisan serve --host=0.0.0.0 --port=8080
pause

