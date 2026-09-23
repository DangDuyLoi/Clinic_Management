-- Tạo cơ sở dữ liệu
CREATE DATABASE IF NOT EXISTS QuanLyKhamChuaBenh DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE QuanLyKhamChuaBenh;

-- ==========================================
-- 1. BẢNG TÀI KHOẢN (Account)
-- ==========================================
CREATE TABLE TaiKhoan (
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
CREATE TABLE ChuyenKhoa (
    ma_chuyen_khoa INT AUTO_INCREMENT PRIMARY KEY,
    ten_chuyen_khoa VARCHAR(100) NOT NULL,
    mo_ta TEXT
);

-- ==========================================
-- 3. BẢNG BÁC SĨ (Doctor)
-- ==========================================
CREATE TABLE BacSi (
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
CREATE TABLE BenhNhan (
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
CREATE TABLE CaLamViec (
    ma_ca INT AUTO_INCREMENT PRIMARY KEY,
    ten_ca VARCHAR(50) NOT NULL, 
    gio_bat_dau TIME NOT NULL,
    gio_ket_thuc TIME NOT NULL,
    luot_kham_toi_da INT DEFAULT 20
);

-- ==========================================
-- 6. BẢNG KHUNG GIỜ (Time Slot)
-- ==========================================
CREATE TABLE KhungGio (
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
CREATE TABLE LichKham (
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
CREATE TABLE PhienKham (
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
CREATE TABLE DichVu (
    ma_dich_vu INT AUTO_INCREMENT PRIMARY KEY,
    ten_dich_vu VARCHAR(150) NOT NULL,
    don_gia DECIMAL(12,2) NOT NULL,
    mo_ta TEXT
);

CREATE TABLE ChiDinhDichVu (
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
CREATE TABLE Thuoc (
    ma_thuoc INT AUTO_INCREMENT PRIMARY KEY,
    ten_thuoc VARCHAR(150) NOT NULL,
    don_vi_tinh VARCHAR(50),
    don_gia DECIMAL(12,2) NOT NULL,
    so_luong_ton INT NOT NULL DEFAULT 0
);

CREATE TABLE DonThuoc (
    ma_don_thuoc INT AUTO_INCREMENT PRIMARY KEY,
    ma_phien_kham INT UNIQUE NOT NULL,
    tong_tien DECIMAL(12,2) DEFAULT 0,
    ngay_ke_don DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ma_phien_kham) REFERENCES PhienKham(ma_phien_kham) ON DELETE CASCADE
);

CREATE TABLE ChiTietDonThuoc (
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
CREATE TABLE HoaDon (
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
CREATE TABLE NhatKyHeThong (
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
-- PHẦN DỮ LIỆU MẪU (Mock Data)
-- ==========================================

INSERT INTO TaiKhoan (ten_dang_nhap, mat_khau, vai_tro) VALUES 
('admin', '123456', 'QuanTri'),
('bs_hoang', '123456', 'BacSi'),
('letan_lan', '123456', 'LeTan'),
('bn_nguyenvan', '123456', 'BenhNhan');

INSERT INTO ChuyenKhoa (ten_chuyen_khoa, mo_ta) VALUES 
('Nội tổng hợp', 'Khám các bệnh lý nội khoa chung'),
('Tim mạch', 'Khám và điều trị các bệnh tim mạch'),
('Da liễu', 'Khám các bệnh về da');

INSERT INTO BacSi (ma_tk, ma_chuyen_khoa, ho_ten, phong_kham, trinh_do, luot_kham_toi_da_moi_ca) VALUES 
(2, 2, 'Hoàng Minh Tuấn', 'Phòng 101', 'Thạc sĩ - Bác sĩ chuyên khoa II', 20);

INSERT INTO BenhNhan (ma_tk, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, di_ung, nhom_mau) VALUES 
(4, 'Nguyễn Văn A', '1990-05-15', 'Nam', '0901234567', 'Dị ứng hải sản', 'O'),
(NULL, 'Trần Thị B', '1985-10-20', 'Nu', '0912345678', 'Không', 'A');

INSERT INTO CaLamViec (ten_ca, gio_bat_dau, gio_ket_thuc) VALUES 
('Sáng', '07:30:00', '11:30:00'),
('Chiều', '13:00:00', '17:00:00');

INSERT INTO KhungGio (ma_ca, gio_bat_dau, gio_ket_thuc, luot_kham_toi_da) VALUES 
(1, '08:00:00', '08:30:00', 3),
(1, '08:30:00', '09:00:00', 3),
(2, '13:30:00', '14:00:00', 3);

INSERT INTO LichKham (ma_bn, ma_bs, ngay_kham, ma_khung_gio, khach_vang_lai, trang_thai) VALUES 
(1, 1, '2026-09-18', 1, FALSE, 'HoanThanh'),
(2, 1, '2026-09-18', 2, TRUE, 'ChoKham');

INSERT INTO PhienKham (ma_lich_dat, chan_doan_so_bo, chan_doan_cuoi_cung, trang_thai) VALUES 
(1, 'Đau tức ngực, huyết áp cao', 'Tăng huyết áp vô căn, theo dõi nhồi máu cơ tim', 'HoanThanh');

INSERT INTO DichVu (ten_dich_vu, don_gia, mo_ta) VALUES 
('Đo điện tâm đồ (ECG)', 150000, 'Đo điện tim đồ thường quy'),
('Xét nghiệm máu cơ bản', 300000, 'Tổng phân tích tế bào máu');

INSERT INTO ChiDinhDichVu (ma_phien_kham, ma_dich_vu, ket_qua_chi_tiet, trang_thai) VALUES 
(1, 1, 'Nhịp tim nhanh, có dấu hiệu thiếu máu cục bộ', 'DaCoKetQua'),
(1, 2, 'Bạch cầu bình thường, Mỡ máu cao', 'DaCoKetQua');

INSERT INTO Thuoc (ten_thuoc, don_vi_tinh, don_gia, so_luong_ton) VALUES 
('Amlodipine 5mg', 'Viên', 2000, 500),
('Aspirin 81mg', 'Viên', 1500, 1000);

INSERT INTO DonThuoc (ma_phien_kham, tong_tien) VALUES 
(1, 105000);

INSERT INTO ChiTietDonThuoc (ma_don_thuoc, ma_thuoc, so_luong, lieu_luong, thanh_tien) VALUES 
(1, 1, 30, 'Ngày uống 1 viên buổi sáng', 60000),
(1, 2, 30, 'Ngày uống 1 viên sau ăn tối', 45000);

UPDATE Thuoc SET so_luong_ton = so_luong_ton - 30 WHERE ma_thuoc IN (1, 2);

INSERT INTO HoaDon (ma_phien_kham, tien_kham_benh, tien_dich_vu, tien_thuoc, tong_cong, phuong_thuc, trang_thai, ngay_thanh_toan) VALUES 
(1, 100000, 450000, 105000, 655000, 'VNPay', 'DaThanhToan', '2026-09-18 09:15:00');

INSERT INTO NhatKyHeThong (ma_tk, hanh_dong, bang_tac_dong, du_lieu_cu, du_lieu_moi) VALUES 
(2, 'UPDATE', 'PhienKham', '{"trang_thai": "ChoCanLamSang"}', '{"trang_thai": "HoanThanh", "chan_doan_cuoi_cung": "Tăng huyết áp vô căn"}');
