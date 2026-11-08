@echo off
chcp 65001 >nul
title [HUIT CLINIC] KHOI DONG HE THONG CLINIC MANAGEMENT
color 0B

echo =====================================================================
echo           HE THONG DICH VU CLINIC MANAGEMENT SYSTEM
echo =====================================================================
echo.

:: 1. Thiet lap PATH cho cac cong cu can thiet
set "PATH=C:\laragon\bin\php\php-8.3.30-Win32-vs16-x64;C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin;C:\flutter_windows_3.41.5-stable\flutter\bin;C:\Users\LENOVO\AppData\Local\Android\Sdk\platform-tools;%PATH%"

:: 2. Kiem tra MySQL
echo [1/4] Kiem tra Database MySQL...
tasklist /FI "IMAGENAME eq mysqld.exe" 2>NUL | find /I /N "mysqld.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo  [OK] MySQL dang chay.
) else (
    echo  [!] Dang khoi dong MySQL...
    start "" "C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysqld.exe" --console
    timeout /t 3 /nobreak >nul
)

:: 3. Khoi dong Backend API (cong 8080)
echo.
echo [2/4] Khoi dong Backend API tai:
echo       - Localhost: http://127.0.0.1:8080/api
echo       - Mang Wi-Fi: http://192.168.1.7:8080/api
start "Backend API - HUIT Clinic (Port 8080)" cmd /k "cd /d \"%~dp0backend_api\" && php artisan serve --host=0.0.0.0 --port=8080"
timeout /t 2 /nobreak >nul

:: 4. Kiem tra thiet bi dien thoai ket noi qua ADB
echo.
echo [3/4] Kiem tra ket noi dien thoai Android (qua cap USB)...
adb start-server >nul 2>&1
echo Danh sach thiet bi ADB:
adb devices
echo.

:: 5. Thiet lap ADB reverse phong khi dung qua USB
adb reverse tcp:8080 tcp:8080 >nul 2>&1

:: 6. Chay ung dung Flutter len dien thoai
echo.
echo [4/4] Dang chay ung dung Flutter...
cd /d "%~dp0patient_mobile"
flutter run

pause
