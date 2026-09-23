# 🏥 Nền tảng Quản lý Phòng khám Đa khoa

**Đề tài:** CNTT-KLCN098 — Khoa CNTT, ĐH Công Thương TP.HCM
**GVHD:** Trần Văn Thọ
**Nhóm SV:**
- Phan Tại Phú (2001230675)
- Đặng Duy Lợi (2001230479)
- Bùi Quang Tiến (2001230807)

---

## 📖 Giới thiệu

Hệ thống quản lý phòng khám đa khoa với 2 nền tảng:
- **Web**: dành cho Lễ tân, Bác sĩ, Quản trị viên
- **Mobile**: dành cho Bệnh nhân (dự kiến)

### Công nghệ
- **Backend**: PHP 8.3 + Laravel 11
- **Frontend**: HTML5, CSS3, JavaScript ES6+
- **CSDL**: MySQL 8.0
- **Xác thực**: JWT (tymon/jwt-auth)
- **Deploy**: Docker + Nginx

---

## 🚀 Cài đặt

### Yêu cầu
- PHP >= 8.2
- Composer
- MySQL 8.0
- Node.js (tùy chọn)
- Docker (nếu deploy)

### Các bước

```bash
# 1. Clone
git clone <repo-url>
cd clinic-management

# 2. Cài dependencies
composer install

# 3. Cấu hình .env
cp .env.example .env
php artisan key:generate
php artisan jwt:secret

# 4. Import CSDL
mysql -u root -p < database.sql

# 5. Chạy
php artisan serve
# → http://localhost:8000