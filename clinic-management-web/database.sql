-- Tạo cơ sở dữ liệu
CREATE DATABASE IF NOT EXISTS QuanLyKhamChuaBenh DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE QuanLyKhamChuaBenh;

SET FOREIGN_KEY_CHECKS = 0;

-- ==========================================
-- 1. BẢNG TÀI KHOẢN (Account)
-- ==========================================
CREATE TABLE IF NOT EXISTS TaiKhoan (
    ma_tk INT AUTO_INCREMENT PRIMARY KEY,
    ten_dang_nhap VARCHAR(50) NOT NULL UNIQUE,
    mat_khau VARCHAR(255) NOT NULL,
    vai_tro ENUM('QuanTri', 'BacSi', 'LeTan', 'BenhNhan') NOT NULL,
    trang_thai BOOLEAN DEFAULT TRUE,
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 2. BẢNG CHUYÊN KHOA (Specialty)
-- ==========================================
CREATE TABLE IF NOT EXISTS ChuyenKhoa (
    ma_chuyen_khoa INT AUTO_INCREMENT PRIMARY KEY,
    ten_chuyen_khoa VARCHAR(100) NOT NULL,
    mo_ta TEXT,
    trang_thai BOOLEAN DEFAULT TRUE
);

-- ==========================================
-- 3. BẢNG BÁC SĨ (Doctor)
-- ==========================================
CREATE TABLE IF NOT EXISTS BacSi (
    ma_bs INT AUTO_INCREMENT PRIMARY KEY,
    ma_tk INT UNIQUE, 
    ma_chuyen_khoa INT,
    ho_ten VARCHAR(100) NOT NULL,
    phong_kham VARCHAR(50), -- Bổ sung phòng khám để Lễ tân điều phối
    trinh_do VARCHAR(100),
    luot_kham_toi_da_moi_ca INT DEFAULT 20,
    FOREIGN KEY (ma_tk) REFERENCES TaiKhoan(ma_tk) ON DELETE SET NULL,
    FOREIGN KEY (ma_chuyen_khoa) REFERENCES ChuyenKhoa(ma_chuyen_khoa) ON DELETE SET NULL
);

-- ==========================================
-- 4. BẢNG BỆNH NHÂN (Patient)
-- ==========================================
CREATE TABLE IF NOT EXISTS BenhNhan (
    ma_bn INT AUTO_INCREMENT PRIMARY KEY,
    ma_tk INT UNIQUE NULL, 
    ho_ten VARCHAR(100) NOT NULL,
    ngay_sinh DATE,
    gioi_tinh ENUM('Nam', 'Nu', 'Khac'),
    so_dien_thoai VARCHAR(15) UNIQUE,
    email VARCHAR(100),
    cccd VARCHAR(20) UNIQUE,
    dia_chi VARCHAR(255),
    nguoi_lien_he_khan_cap VARCHAR(100),
    tien_su_benh TEXT,
    di_ung TEXT,
    nhom_mau VARCHAR(5),
    FOREIGN KEY (ma_tk) REFERENCES TaiKhoan(ma_tk) ON DELETE SET NULL
);

-- ==========================================
-- 5. BẢNG CA LÀM VIỆC (Shift)
-- ==========================================
CREATE TABLE IF NOT EXISTS CaLamViec (
    ma_ca INT AUTO_INCREMENT PRIMARY KEY,
    ten_ca VARCHAR(50) NOT NULL, 
    gio_bat_dau TIME NOT NULL,
    gio_ket_thuc TIME NOT NULL,
    luot_kham_toi_da INT DEFAULT 20
);

-- ==========================================
-- 6. BẢNG KHUNG GIỜ (Time Slot)
-- ==========================================
CREATE TABLE IF NOT EXISTS KhungGio (
    ma_khung_gio INT AUTO_INCREMENT PRIMARY KEY,
    ma_ca INT NOT NULL,
    gio_bat_dau TIME NOT NULL,
    gio_ket_thuc TIME NOT NULL,
    luot_kham_toi_da INT DEFAULT 3, 
    FOREIGN KEY (ma_ca) REFERENCES CaLamViec(ma_ca) ON DELETE CASCADE
);

-- ==========================================
-- 7. BẢNG LỊCH ĐẶT KHÁM (Appointment)
-- ==========================================
CREATE TABLE IF NOT EXISTS LichKham (
    ma_lich_dat INT AUTO_INCREMENT PRIMARY KEY,
    ma_bn INT NOT NULL,
    ma_bs INT NOT NULL,
    ngay_kham DATE NOT NULL,
    ma_khung_gio INT NOT NULL,
    thoi_gian_den_quay TIME NULL, 
    khach_vang_lai BOOLEAN DEFAULT FALSE,
    diem_uu_tien INT DEFAULT 0,
    trang_thai ENUM('ChoXacNhan', 'ChoDenKham', 'ChoKham', 'DangKham', 'HoanThanh', 'DaHuy') DEFAULT 'ChoXacNhan',
    ghi_chu TEXT,
    FOREIGN KEY (ma_bn) REFERENCES BenhNhan(ma_bn) ON DELETE CASCADE,
    FOREIGN KEY (ma_bs) REFERENCES BacSi(ma_bs) ON DELETE CASCADE,
    FOREIGN KEY (ma_khung_gio) REFERENCES KhungGio(ma_khung_gio) ON DELETE RESTRICT
);

-- ==========================================
-- 8. BẢNG PHIÊN KHÁM BỆNH (Medical Record / Visit)
-- ==========================================
CREATE TABLE IF NOT EXISTS PhienKham (
    ma_phien_kham INT AUTO_INCREMENT PRIMARY KEY,
    ma_lich_dat INT UNIQUE NOT NULL, 
    chan_doan_so_bo TEXT,
    chan_doan_cuoi_cung TEXT,
    ghi_chu_y_te TEXT,
    trang_thai ENUM('ChoCanLamSang', 'ChoKetLuan', 'ChoThanhToan', 'HoanThanh') DEFAULT 'HoanThanh',
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ma_lich_dat) REFERENCES LichKham(ma_lich_dat) ON DELETE CASCADE
);

-- ==========================================
-- 9. BẢNG DỊCH VỤ CẬN LÂM SÀNG (Service)
-- ==========================================
CREATE TABLE IF NOT EXISTS DichVu (
    ma_dich_vu INT AUTO_INCREMENT PRIMARY KEY,
    ten_dich_vu VARCHAR(150) NOT NULL,
    don_gia DECIMAL(12,2) NOT NULL,
    mo_ta TEXT
);

CREATE TABLE IF NOT EXISTS ChiDinhDichVu (
    ma_chi_dinh INT AUTO_INCREMENT PRIMARY KEY,
    ma_phien_kham INT NOT NULL,
    ma_dich_vu INT NOT NULL,
    ket_qua_chi_tiet TEXT,
    trang_thai ENUM('ChoThucHien', 'DaCoKetQua', 'DaHuy') DEFAULT 'ChoThucHien',
    FOREIGN KEY (ma_phien_kham) REFERENCES PhienKham(ma_phien_kham) ON DELETE CASCADE,
    FOREIGN KEY (ma_dich_vu) REFERENCES DichVu(ma_dich_vu) ON DELETE CASCADE
);

-- ==========================================
-- 10. BẢNG THUỐC & ĐƠN THUỐC (Medicine & Prescription)
-- ==========================================
CREATE TABLE IF NOT EXISTS Thuoc (
    ma_thuoc INT AUTO_INCREMENT PRIMARY KEY,
    ten_thuoc VARCHAR(150) NOT NULL,
    don_vi_tinh VARCHAR(50),
    don_gia DECIMAL(12,2) NOT NULL,
    so_luong_ton INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS DonThuoc (
    ma_don_thuoc INT AUTO_INCREMENT PRIMARY KEY,
    ma_phien_kham INT UNIQUE NOT NULL,
    tong_tien DECIMAL(12,2) DEFAULT 0,
    ngay_ke_don DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ma_phien_kham) REFERENCES PhienKham(ma_phien_kham) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ChiTietDonThuoc (
    ma_chi_tiet INT AUTO_INCREMENT PRIMARY KEY,
    ma_don_thuoc INT NOT NULL,
    ma_thuoc INT NOT NULL,
    so_luong INT NOT NULL,
    lieu_luong VARCHAR(255) NOT NULL,
    thanh_tien DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (ma_don_thuoc) REFERENCES DonThuoc(ma_don_thuoc) ON DELETE CASCADE,
    FOREIGN KEY (ma_thuoc) REFERENCES Thuoc(ma_thuoc) ON DELETE RESTRICT
);

-- ==========================================
-- 11. BẢNG HÓA ĐƠN THANH TOÁN (Payment)
-- ==========================================
CREATE TABLE IF NOT EXISTS HoaDon (
    ma_hoa_don INT AUTO_INCREMENT PRIMARY KEY,
    ma_phien_kham INT UNIQUE NOT NULL,
    tien_kham_benh DECIMAL(12,2) DEFAULT 0,
    tien_dich_vu DECIMAL(12,2) DEFAULT 0,
    tien_thuoc DECIMAL(12,2) DEFAULT 0,
    tong_cong DECIMAL(12,2) NOT NULL,
    phuong_thuc ENUM('TienMat', 'Momo', 'VNPay', 'ChuyenKhoan') NULL,
    trang_thai ENUM('ChuaThanhToan', 'DaThanhToan', 'DaHuy') DEFAULT 'ChuaThanhToan',
    ngay_tao DATETIME DEFAULT CURRENT_TIMESTAMP,
    ngay_thanh_toan DATETIME NULL,
    FOREIGN KEY (ma_phien_kham) REFERENCES PhienKham(ma_phien_kham) ON DELETE CASCADE
);

-- ==========================================
-- 12. BẢNG NHẬT KÝ HỆ THỐNG (Audit Log)
-- ==========================================
CREATE TABLE IF NOT EXISTS NhatKyHeThong (
    ma_nhat_ky INT AUTO_INCREMENT PRIMARY KEY,
    ma_tk INT,
    hanh_dong VARCHAR(50) NOT NULL,
    bang_tac_dong VARCHAR(50) NOT NULL,
    du_lieu_cu JSON,
    du_lieu_moi JSON,
    thoi_gian DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ma_tk) REFERENCES TaiKhoan(ma_tk) ON DELETE SET NULL
);

-- ==========================================
-- 13. BẢNG THÔNG BÁO (Notification)
-- ==========================================
CREATE TABLE IF NOT EXISTS ThongBao (
    ma_thong_bao INT AUTO_INCREMENT PRIMARY KEY,
    ma_tk INT,
    tieu_de VARCHAR(255) NOT NULL,
    noi_dung TEXT,
    loai VARCHAR(50) DEFAULT 'he_thong',
    duong_dan VARCHAR(255) NULL,
    da_doc BOOLEAN DEFAULT FALSE,
    thoi_gian DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ma_tk) REFERENCES TaiKhoan(ma_tk) ON DELETE CASCADE
);

SET FOREIGN_KEY_CHECKS = 1;
