USE QuanLyKhamChuaBenh;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE NhatKyHeThong;
TRUNCATE TABLE HoaDon;
TRUNCATE TABLE ChiTietDonThuoc;
TRUNCATE TABLE DonThuoc;
TRUNCATE TABLE ChiDinhDichVu;
TRUNCATE TABLE PhienKham;
TRUNCATE TABLE LichKham;
TRUNCATE TABLE KhungGio;
TRUNCATE TABLE CaLamViec;
TRUNCATE TABLE Thuoc;
TRUNCATE TABLE DichVu;
TRUNCATE TABLE BenhNhan;
TRUNCATE TABLE BacSi;
TRUNCATE TABLE ChuyenKhoa;
TRUNCATE TABLE TaiKhoan;

SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO TaiKhoan (ma_tk, ten_dang_nhap, mat_khau, vai_tro, trang_thai) VALUES
-- Admin
(1,  'admin',        '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'QuanTri', TRUE),

-- Bác sĩ (8)
(2,  'bs.hoangtuan',   '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),
(3,  'bs.mailan',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),
(4,  'bs.quockhanh',   '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),
(5,  'bs.thuhang',     '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),
(6,  'bs.ducthanh',    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),
(7,  'bs.minhtam',     '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),
(8,  'bs.thaovy',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),
(9,  'bs.vanson',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BacSi', TRUE),

-- Lễ tân (3)
(10, 'letan.lan',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'LeTan', TRUE),
(11, 'letan.huong',    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'LeTan', TRUE),
(12, 'letan.thao',     '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'LeTan', TRUE),

-- Bệnh nhân (13)
(13, 'bn.hoangphuc',  '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(14, 'bn.kimoanh',    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(15, 'bn.quocbao',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(16, 'bn.ngocdiem',    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(17, 'bn.duchuy',   '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(18, 'bn.anhtuyet',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(19, 'bn.xuantruong',    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(20, 'bn.thanhha',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(21, 'bn.minhkhue',      '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(22, 'bn.gialinh',     '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(23, 'bn.trongnghia',    '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(24, 'bn.baongoc',     '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE),
(25, 'bn.vankhanh',  '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyWpNBnHBnHBnG', 'BenhNhan', TRUE);

INSERT INTO ChuyenKhoa (ma_chuyen_khoa, ten_chuyen_khoa, mo_ta) VALUES
(1, 'Nội tổng hợp',    'Khám và điều trị các bệnh lý nội khoa tổng quát: tiêu hóa, hô hấp, thần kinh, nội tiết'),
(2, 'Tim mạch',        'Khám, chẩn đoán và điều trị các bệnh lý về tim và mạch máu: tăng huyết áp, suy tim, rối loạn nhịp tim'),
(3, 'Da liễu',         'Khám và điều trị các bệnh về da, tóc, móng và các bệnh lây truyền qua đường tình dục'),
(4, 'Nhi khoa',        'Khám và điều trị bệnh lý cho trẻ em từ 0-16 tuổi: hô hấp, tiêu hóa, dinh dưỡng, tiêm chủng'),
(5, 'Tai Mũi Họng',    'Khám và điều trị các bệnh về tai, mũi, họng: viêm xoang, viêm họng, viêm tai giữa, ù tai'),
(6, 'Xương khớp',      'Khám và điều trị các bệnh về cơ xương khớp: thoái hóa khớp, đau lưng, gút, viêm khớp dạng thấp'),
(7, 'Sản phụ khoa',    'Khám phụ khoa, theo dõi thai kỳ, tư vấn sinh sản và các bệnh lý phụ nữ'),
(8, 'Mắt',             'Khám và điều trị các bệnh về mắt: cận thị, viễn thị, đục thủy tinh thể, tăng nhãn áp');

INSERT INTO BacSi (ma_bs, ma_tk, ma_chuyen_khoa, ho_ten, trinh_do, luot_kham_toi_da_moi_ca) VALUES
(1, 2, 1, 'Hoàng Minh Tuấn',   'Thạc sĩ - Bác sĩ Chuyên khoa II Nội tổng hợp',    20),
(2, 3, 2, 'Nguyễn Thị Mai Lan', 'Tiến sĩ - Bác sĩ Chuyên khoa II Tim mạch',        15),
(3, 4, 3, 'Trần Quốc Khánh',   'Bác sĩ Chuyên khoa I Da liễu',                    18),
(4, 5, 4, 'Lê Thị Thu Hằng',   'Thạc sĩ - Bác sĩ Nhi khoa',                       25),
(5, 6, 5, 'Phạm Đức Thành',    'Bác sĩ Chuyên khoa I Tai Mũi Họng',               20),
(6, 7, 6, 'Vũ Minh Tâm',       'Thạc sĩ - Bác sĩ Chuyên khoa II Xương khớp',      18),
(7, 8, 7, 'Đặng Thị Thảo Vy',  'Bác sĩ Chuyên khoa I Sản phụ khoa',               15),
(8, 9, 8, 'Bùi Văn Sơn',       'Thạc sĩ - Bác sĩ Chuyên khoa II Mắt',             20);

INSERT INTO BenhNhan (ma_bn, ma_tk, ho_ten, ngay_sinh, gioi_tinh, so_dien_thoai, email, cccd, dia_chi, nguoi_lien_he_khan_cap, tien_su_benh, di_ung, nhom_mau) VALUES
(1,  13, 'Nguyễn Hoàng Phúc',      '1985-03-15', 'Nam', '0901234567', 'nguyenvanan@gmail.com',    '079085001234', '123 Lê Lợi, Quận 1, TP.HCM',      'Nguyễn Thị Hoa (vợ) - 0901234568', 'Tăng huyết áp', 'Không',              'O'),
(2,  14, 'Trần Thị Kim Oanh',      '1990-07-22', 'Nu',  '0912345678', 'tranthibinh@gmail.com',    '079090002345', '456 Nguyễn Huệ, Quận 1, TP.HCM',  'Trần Văn Minh (chồng) - 0912345679', 'Không', 'Dị ứng hải sản',     'A'),
(3,  15, 'Lê Quốc Bảo',       '1978-11-05', 'Nam', '0903456789', 'levancuong@gmail.com',     '079078003456', '789 Võ Văn Tần, Quận 3, TP.HCM',  'Lê Thị Mai (vợ) - 0903456790', 'Đái tháo đường type 2', 'Không',     'B'),
(4,  16, 'Phạm Ngọc Diễm',      '1995-02-18', 'Nu',  '0934567890', 'phamthidung@gmail.com',    '079095004567', '101 Điện Biên Phủ, Quận 3, TP.HCM', 'Phạm Văn Hùng (bố) - 0934567891', 'Không', 'Dị ứng penicillin',  'AB'),
(5,  17, 'Hoàng Đức Huy',       '1982-09-30', 'Nam', '0945678901', 'hoangvanem@gmail.com',     '079082005678', '202 Cách Mạng Tháng 8, Quận 10, TP.HCM', 'Hoàng Thị Lan (mẹ) - 0945678902', 'Viêm gan B', 'Không',        'O'),
(6,  18, 'Vũ Thị Ánh Tuyết',      '2000-05-12', 'Nu',  '0956789012', 'vuthiphuong@gmail.com',    '079000006789', '303 Lý Thường Kiệt, Quận 10, TP.HCM', 'Vũ Văn Nam (bố) - 0956789013', 'Không', 'Không',              'A'),
(7,  19, 'Đặng Xuân Trường',     '1975-12-25', 'Nam', '0967890123', 'dangvangiang@gmail.com',   '079075007890', '404 Hoàng Văn Thụ, Tân Bình, TP.HCM', 'Đặng Thị Thu (vợ) - 0967890124', 'Thoái hóa khớp gối', 'Không',   'B'),
(8,  20, 'Bùi Thanh Hà',       '1988-08-08', 'Nu',  '0978901234', 'buithihanh@gmail.com',     '079088008901', '505 Trường Chinh, Tân Bình, TP.HCM', 'Bùi Văn Tâm (chồng) - 0978901235', 'Không', 'Dị ứng phấn hoa',   'O'),
(9,  21, 'Đỗ Minh Khuê',         '1992-04-20', 'Nu',  '0989012345', 'dothikim@gmail.com',       '079092009012', '606 Lê Văn Sỹ, Quận 3, TP.HCM',   'Đỗ Văn Long (bố) - 0989012346', 'Không', 'Không',              'A'),
(10, 22, 'Ngô Gia Linh',       '1998-10-14', 'Nu',  '0990123456', 'ngothilinh@gmail.com',     '079098000123', '707 Nguyễn Trãi, Quận 5, TP.HCM', 'Ngô Văn Tùng (chồng) - 0990123457', 'Không', 'Dị ứng tôm cua',    'B'),
(11, 23, 'Đinh Trọng Nghĩa',      '1968-06-03', 'Nam', '0901234568', 'dinhvanminh@gmail.com',    '079068001234', '808 Hùng Vương, Quận 5, TP.HCM',  'Đinh Thị Nga (vợ) - 0901234569', 'Cao huyết áp, mỡ máu cao', 'Không', 'O'),
(12, 24, 'Lưu Bảo Ngọc',       '2005-01-28', 'Nu',  '0912345680', 'luuthingoc@gmail.com',     '079005002345', '909 Trần Hưng Đạo, Quận 1, TP.HCM', 'Lưu Văn Bình (bố) - 0912345681', 'Không', 'Không',            'AB'),
(13, 25, 'Trương Văn Khánh',    '1980-07-19', 'Nam', '0923456789', 'truongvanoanh@gmail.com',  '079080003456', '111 Pasteur, Quận 1, TP.HCM',     'Trương Thị Tuyết (vợ) - 0923456790', 'Viêm dạ dày mãn tính', 'Không', 'A');

INSERT INTO CaLamViec (ma_ca, ten_ca, gio_bat_dau, gio_ket_thuc, luot_kham_toi_da) VALUES
(1, 'Ca sáng', '07:30:00', '11:30:00', 100),
(2, 'Ca chiều','13:00:00', '17:00:00', 100);

INSERT INTO KhungGio (ma_khung_gio, ma_ca, gio_bat_dau, gio_ket_thuc, luot_kham_toi_da) VALUES
-- Ca sáng: 4 khung
(1, 1, '07:30:00', '08:30:00', 5),
(2, 1, '08:30:00', '09:30:00', 5),
(3, 1, '09:30:00', '10:30:00', 5),
(4, 1, '10:30:00', '11:30:00', 5),
-- Ca chiều: 4 khung
(5, 2, '13:00:00', '14:00:00', 5),
(6, 2, '14:00:00', '15:00:00', 5),
(7, 2, '15:00:00', '16:00:00', 5),
(8, 2, '16:00:00', '17:00:00', 5);

INSERT INTO Thuoc (ma_thuoc, ten_thuoc, don_vi_tinh, don_gia, so_luong_ton) VALUES
-- Thuốc giảm đau, hạ sốt
(1,  'Paracetamol 500mg',        'Viên', 1500,   2000),
(2,  'Ibuprofen 400mg',          'Viên', 2500,   1500),
(3,  'Efferalgan 500mg',         'Viên', 3000,   800),
(4,  'Aspirin 81mg',             'Viên', 1800,   1200),

-- Kháng sinh
(5,  'Amoxicillin 500mg',        'Viên', 3500,   900),
(6,  'Azithromycin 250mg',       'Viên', 12000,  400),
(7,  'Cefuroxime 500mg',         'Viên', 8000,   600),
(8,  'Ciprofloxacin 500mg',      'Viên', 5500,   500),

-- Tim mạch - Huyết áp
(9,  'Amlodipine 5mg',           'Viên', 2000,   1500),
(10, 'Losartan 50mg',            'Viên', 3500,   800),
(11, 'Bisoprolol 5mg',           'Viên', 4000,   600),
(12, 'Atorvastatin 20mg',        'Viên', 6500,   700),

-- Tiêu hóa
(13, 'Omeprazole 20mg',          'Viên', 3000,   1200),
(14, 'Domperidone 10mg',         'Viên', 2000,   900),
(15, 'Smecta',                   'Gói',  5000,   500),

-- Dị ứng
(16, 'Cetirizine 10mg',          'Viên', 1500,   1000),
(17, 'Loratadine 10mg',          'Viên', 2000,   800),

-- Vitamin & bổ sung
(18, 'Vitamin C 1000mg',         'Viên', 2500,   2000),
(19, 'Vitamin B Complex',        'Viên', 3000,   1500),
(20, 'Calcium D3',               'Viên', 4500,   900);

INSERT INTO DichVu (ma_dich_vu, ten_dich_vu, don_gia, mo_ta) VALUES
(1,  'Xét nghiệm máu cơ bản',             250000, 'Tổng phân tích tế bào máu ngoại vi, đánh giá hồng cầu, bạch cầu, tiểu cầu'),
(2,  'Xét nghiệm đường huyết',            120000, 'Đo nồng độ glucose trong máu lúc đói'),
(3,  'Xét nghiệm mỡ máu',                280000, 'Định lượng cholesterol, triglyceride, HDL, LDL'),
(4,  'Xét nghiệm chức năng gan',          350000, 'Đánh giá men gan AST, ALT, GGT, bilirubin'),
(5,  'Xét nghiệm chức năng thận',         300000, 'Định lượng creatinine, ure, eGFR'),
(6,  'Xét nghiệm nước tiểu',             150000, 'Phân tích 10 thông số nước tiểu'),
(7,  'Đo điện tâm đồ (ECG)',             180000, 'Ghi lại hoạt động điện của tim, phát hiện rối loạn nhịp'),
(8,  'Siêu âm tim',                      500000, 'Đánh giá cấu trúc và chức năng các buồng tim, van tim'),
(9,  'Siêu âm bụng tổng quát',           350000, 'Khảo sát gan, mật, tụy, thận, lách và các cơ quan ổ bụng'),
(10, 'Siêu âm tuyến giáp',               300000, 'Đánh giá kích thước, cấu trúc và nhân tuyến giáp'),
(11, 'X-quang ngực thẳng',               250000, 'Chụp X-quang phổi, tim, trung thất'),
(12, 'X-quang cột sống thắt lưng',        300000, 'Khảo sát tình trạng thoái hóa, gai cột sống'),
(13, 'Nội soi dạ dày',                   800000, 'Quan sát trực tiếp niêm mạc dạ dày, phát hiện viêm loét'),
(14, 'Đo chức năng hô hấp',              400000, 'Đánh giá dung tích phổi và lưu lượng khí thở ra'),
(15, 'Đo mật độ xương (DEXA)',           600000, 'Chẩn đoán loãng xương, đánh giá nguy cơ gãy xương');

INSERT INTO LichKham (ma_lich_dat, ma_bn, ma_bs, ngay_kham, ma_khung_gio, thoi_gian_den_quay, khach_vang_lai, diem_uu_tien, trang_thai, ghi_chu) VALUES
-- Ngày 20/09/2026 (đã hoàn thành)
(1,  1,  1, '2026-09-20', 1, '07:35:00', FALSE, 0, 'HoanThanh', NULL),
(2,  2,  2, '2026-09-20', 2, '08:40:00', FALSE, 0, 'HoanThanh', NULL),
(3,  3,  1, '2026-09-20', 5, '13:05:00', FALSE, 2, 'HoanThanh', 'Bệnh nhân lớn tuổi, ưu tiên'),

-- Ngày 21/09/2026 (đã hoàn thành)
(4,  4,  3, '2026-09-21', 1, '07:40:00', FALSE, 0, 'HoanThanh', NULL),
(5,  5,  1, '2026-09-21', 3, '09:45:00', FALSE, 0, 'HoanThanh', NULL),
(6,  6,  4, '2026-09-21', 6, '14:10:00', FALSE, 0, 'HoanThanh', NULL),

-- Ngày 22/09/2026 (đã hoàn thành)
(7,  7,  6, '2026-09-22', 2, '08:35:00', FALSE, 1, 'HoanThanh', 'Đau khớp nặng'),
(8,  8,  3, '2026-09-22', 4, '10:40:00', FALSE, 0, 'HoanThanh', NULL),
(9,  9,  7, '2026-09-22', 7, '15:15:00', FALSE, 0, 'HoanThanh', NULL),

-- Ngày 23/09/2026 (đã hoàn thành)
(10, 10, 5, '2026-09-23', 1, '07:45:00', FALSE, 0, 'HoanThanh', NULL),
(11, 11, 2, '2026-09-23', 3, '09:35:00', FALSE, 3, 'HoanThanh', 'Huyết áp cao, cần theo dõi'),
(12, 12, 4, '2026-09-23', 8, '16:20:00', FALSE, 0, 'HoanThanh', NULL),

-- Ngày 24/09/2026 (đã hoàn thành)
(13, 13, 1, '2026-09-24', 2, '08:50:00', FALSE, 0, 'HoanThanh', NULL),
(14, 1,  8, '2026-09-24', 5, '13:15:00', FALSE, 0, 'HoanThanh', 'Khám mắt định kỳ'),

-- Ngày 25/09/2026 (đã hoàn thành)
(15, 2,  3, '2026-09-25', 1, '07:40:00', FALSE, 0, 'HoanThanh', NULL),
(16, 3,  6, '2026-09-25', 4, '10:30:00', FALSE, 0, 'HoanThanh', NULL),

-- Ngày 26/09/2026 (đã hoàn thành)
(17, 4,  2, '2026-09-26', 3, '09:30:00', FALSE, 0, 'HoanThanh', NULL),
(18, 5,  1, '2026-09-26', 6, '14:20:00', FALSE, 0, 'HoanThanh', NULL),
(19, 6,  7, '2026-09-26', 8, '16:10:00', FALSE, 0, 'HoanThanh', NULL),

-- Ngày 27/09/2026 (đã hủy)
(20, 7,  6, '2026-09-27', 2, NULL, FALSE, 0, 'DaHuy', 'Bệnh nhân bận, xin hủy'),

-- Ngày 28/09/2026 (hôm nay - có các trạng thái khác nhau)
(21, 8,  3, '2026-09-28', 1, '07:50:00', FALSE, 0, 'HoanThanh', NULL),
(22, 9,  5, '2026-09-28', 3, '09:40:00', FALSE, 0, 'ChoKham', NULL),
(23, 10, 4, '2026-09-28', 5, NULL, FALSE, 0, 'ChoXacNhan', NULL),
(24, 11, 2, '2026-09-28', 7, NULL, FALSE, 0, 'ChoXacNhan', NULL),

-- Ngày 29/09/2026 (tương lai)
(25, 12, 4, '2026-09-29', 2, NULL, FALSE, 0, 'ChoXacNhan', 'Khám sức khỏe định kỳ cho bé'),
(26, 13, 1, '2026-09-29', 4, NULL, FALSE, 1, 'ChoXacNhan', NULL),
(27, 1,  2, '2026-09-29', 6, NULL, FALSE, 0, 'ChoXacNhan', 'Tái khám tim mạch'),

-- Ngày 30/09/2026 (tương lai)
(28, 2,  8, '2026-09-30', 1, NULL, FALSE, 0, 'ChoXacNhan', NULL),
(29, 3,  5, '2026-09-30', 5, NULL, FALSE, 0, 'ChoXacNhan', NULL),

-- Ngày 01/10/2026 (tương lai)
(30, 4,  3, '2026-10-01', 3, NULL, FALSE, 0, 'ChoXacNhan', NULL);

INSERT INTO PhienKham (ma_phien_kham, ma_lich_dat, chan_doan_so_bo, chan_doan_cuoi_cung, ghi_chu_y_te, trang_thai, ngay_tao) VALUES
(1,  1,  'Đau đầu, chóng mặt nhẹ', 'Tăng huyết áp độ 1, theo dõi định kỳ', 'Bệnh nhân cần kiểm tra huyết áp hàng ngày tại nhà. Tái khám sau 1 tháng.', 'HoanThanh', '2026-09-20 08:00:00'),
(2,  2,  'Đau ngực khi vận động', 'Đau thắt ngực ổn định, chưa có dấu hiệu nhồi máu', 'Tránh vận động mạnh. Tái khám sau 2 tuần mang theo kết quả ECG.', 'HoanThanh', '2026-09-20 09:00:00'),
(3,  3,  'Mệt mỏi, chán ăn', 'Suy nhược cơ thể, thiếu máu nhẹ', 'Bổ sung sắt và vitamin. Nghỉ ngơi hợp lý. Tái khám sau 2 tuần.', 'HoanThanh', '2026-09-20 14:00:00'),
(4,  4,  'Nổi mẩn đỏ, ngứa nhiều vùng tay chân', 'Viêm da dị ứng tiếp xúc', 'Tránh xa dị nguyên. Bôi kem dưỡng ẩm. Uống thuốc kháng histamin.', 'HoanThanh', '2026-09-21 08:00:00'),
(5,  5,  'Đau bụng âm ỉ vùng thượng vị', 'Viêm dạ dày cấp tính', 'Kiêng rượu bia, đồ cay nóng. Ăn nhiều bữa nhỏ. Tái khám sau 2 tuần.', 'HoanThanh', '2026-09-21 10:00:00'),
(6,  6,  'Sốt nhẹ, ho khan', 'Cảm cúm thông thường', 'Nghỉ ngơi, uống nhiều nước ấm. Uống thuốc theo đơn.', 'HoanThanh', '2026-09-21 14:30:00'),
(7,  7,  'Đau nhức khớp gối khi đi lại', 'Thoái hóa khớp gối độ 2', 'Hạn chế leo cầu thang. Tập vật lý trị liệu. Giảm cân nếu thừa cân.', 'HoanThanh', '2026-09-22 09:00:00'),
(8,  8,  'Ngứa da đầu, rụng tóc nhiều', 'Viêm da tiết bã nhờn', 'Gội đầu bằng dầu gội trị nấm. Tránh stress. Tái khám sau 3 tuần.', 'HoanThanh', '2026-09-22 11:00:00'),
(9,  9,  'Chậm kinh, đau bụng dưới', 'Rối loạn kinh nguyệt do stress', 'Nghỉ ngơi, tránh căng thẳng. Tái khám nếu không cải thiện.', 'HoanThanh', '2026-09-22 15:30:00'),
(10, 10, 'Đau họng, khó nuốt', 'Viêm họng cấp do vi khuẩn', 'Súc miệng nước muối ấm. Uống kháng sinh đủ liều theo đơn.', 'HoanThanh', '2026-09-23 08:00:00'),
(11, 11, 'Huyết áp cao 160/95 mmHg', 'Tăng huyết áp độ 2', 'Uống thuốc đều đặn hàng ngày. Kiểm tra huyết áp 2 lần/ngày.', 'HoanThanh', '2026-09-23 10:00:00'),
(12, 12, 'Trẻ sốt cao, quấy khóc', 'Sốt virus ở trẻ nhỏ', 'Cho trẻ uống nhiều nước. Lau người bằng nước ấm. Tái khám nếu sốt > 39°C.', 'HoanThanh', '2026-09-23 16:30:00'),
(13, 13, 'Đau lưng sau khi khuân vác', 'Căng cơ lưng cấp tính', 'Nghỉ ngơi, tránh mang vác nặng. Chườm ấm vùng lưng.', 'HoanThanh', '2026-09-24 09:00:00'),
(14, 14, 'Mờ mắt khi đọc sách', 'Cận thị nhẹ 2 độ', 'Đeo kính đúng độ. Hạn chế nhìn màn hình lâu. Khám lại sau 6 tháng.', 'HoanThanh', '2026-09-24 13:30:00'),
(15, 15, 'Da mặt nổi mụn nhiều', 'Mụn trứng cá mức độ trung bình', 'Rửa mặt 2 lần/ngày bằng sữa rửa mặt dịu nhẹ. Tránh nặn mụn.', 'HoanThanh', '2026-09-25 08:00:00'),
(16, 16, 'Đau khớp ngón tay, cứng khớp buổi sáng', 'Viêm khớp dạng thấp giai đoạn đầu', 'Tập vật lý trị liệu. Uống thuốc kháng viêm theo đơn. Tái khám sau 1 tháng.', 'HoanThanh', '2026-09-25 10:30:00'),
(17, 17, 'Hồi hộp, đánh trống ngực', 'Rối loạn lo âu kèm nhịp nhanh xoang', 'Tập thở sâu, thiền. Hạn chế caffeine. Tái khám sau 2 tuần.', 'HoanThanh', '2026-09-26 09:30:00'),
(18, 18, 'Đau bụng, tiêu chảy', 'Rối loạn tiêu hóa do thức ăn', 'Ăn thức ăn dễ tiêu. Uống nhiều nước bù điện giải.', 'HoanThanh', '2026-09-26 14:30:00'),
(19, 19, 'Khí hư bất thường, ngứa vùng kín', 'Viêm âm đạo do nấm Candida', 'Giữ vệ sinh sạch sẽ. Mặc quần áo thoáng mát. Đặt thuốc theo đơn.', 'HoanThanh', '2026-09-26 16:30:00'),
(20, 21, 'Đau mắt đỏ, chảy nước mắt', 'Viêm kết mạc cấp', 'Nhỏ thuốc theo đơn. Không dụi mắt. Rửa tay thường xuyên.', 'HoanThanh', '2026-09-28 08:00:00');

INSERT INTO ChiDinhDichVu (ma_chi_dinh, ma_phien_kham, ma_dich_vu, ket_qua_chi_tiet, trang_thai) VALUES
-- Phiên 1 (Tăng huyết áp)
(1,  1,  1,  'Hồng cầu 4.5 T/L, Bạch cầu 7.2 G/L, Tiểu cầu 250 G/L - Bình thường', 'DaCoKetQua'),
(2,  1,  7,  'Nhịp xoang đều, tần số 78 lần/phút. Không phát hiện bất thường.', 'DaCoKetQua'),

-- Phiên 2 (Đau thắt ngực)
(3,  2,  7,  'Nhịp xoang, ST chênh xuống nhẹ ở D2, D3, aVF - Nghi ngờ thiếu máu cơ tim', 'DaCoKetQua'),
(4,  2,  8,  'Chức năng tâm thu thất trái EF 55%, không có huyết khối buồng tim', 'DaCoKetQua'),
(5,  2,  3,  'Cholesterol toàn phần 6.2 mmol/L (cao), LDL 4.1 mmol/L (cao)', 'DaCoKetQua'),

-- Phiên 3 (Thiếu máu)
(6,  3,  1,  'Hồng cầu 3.8 T/L, Hemoglobin 105 g/L - Thiếu máu nhẹ', 'DaCoKetQua'),

-- Phiên 4 (Viêm da)
(7,  4,  1,  'Công thức máu bình thường. Bạch cầu ái toan tăng nhẹ 7%.', 'DaCoKetQua'),

-- Phiên 5 (Viêm dạ dày)
(8,  5,  13, 'Niêm mạc dạ dày sung huyết, có vài ổ viêm trợt nhỏ. HP test âm tính.', 'DaCoKetQua'),

-- Phiên 6 (Cảm cúm)
(9,  6,  1,  'Bạch cầu bình thường. Không có dấu hiệu nhiễm khuẩn.', 'DaCoKetQua'),

-- Phiên 7 (Thoái hóa khớp)
(10, 7,  12, 'Hẹp khe khớp gối, có gai xương bờ khớp. Thoái hóa độ 2.', 'DaCoKetQua'),
(11, 7,  1,  'Công thức máu bình thường. CRP 5 mg/L (tăng nhẹ).', 'DaCoKetQua'),

-- Phiên 10 (Viêm họng)
(12, 10, 1,  'Bạch cầu 11.5 G/L (tăng), Neutrophil 80% - Nhiễm khuẩn', 'DaCoKetQua'),

-- Phiên 11 (Tăng huyết áp độ 2)
(13, 11, 7,  'Nhịp xoang, dày thất trái nhẹ', 'DaCoKetQua'),
(14, 11, 3,  'Cholesterol 5.8 mmol/L, LDL 3.8 mmol/L', 'DaCoKetQua'),
(15, 11, 5,  'Creatinine 95 µmol/L, eGFR 78 mL/phút - Bình thường', 'DaCoKetQua'),

-- Phiên 12 (Sốt virus)
(16, 12, 1,  'Bạch cầu 6.5 G/L, Lymphocyte 45% - Nghi virus', 'DaCoKetQua'),

-- Phiên 14 (Cận thị)
(17, 14, 1,  'Công thức máu bình thường', 'DaCoKetQua'),

-- Phiên 16 (Viêm khớp dạng thấp)
(18, 16, 1,  'CRP 15 mg/L (tăng), RF dương tính, Anti-CCP dương tính', 'DaCoKetQua'),
(19, 16, 12, 'Hẹp khe khớp nhẹ, không có gai xương. Phù mô mềm quanh khớp.', 'DaCoKetQua'),

-- Phiên 17 (Rối loạn lo âu)
(20, 17, 7,  'Nhịp nhanh xoang 105 lần/phút. Không có rối loạn nhịp nguy hiểm.', 'DaCoKetQua'),

-- Phiên 18 (Rối loạn tiêu hóa)
(21, 18, 1,  'Công thức máu bình thường', 'DaCoKetQua'),
(22, 18, 6,  'Nước tiểu vàng đậm, không có bạch cầu, hồng cầu', 'DaCoKetQua'),

-- Phiên 19 (Viêm âm đạo)
(23, 19, 6,  'Nước tiểu bình thường, không nhiễm khuẩn', 'DaCoKetQua'),

-- Phiên 20 (Viêm kết mạc)
(24, 20, 1,  'Công thức máu bình thường', 'DaCoKetQua');

INSERT INTO DonThuoc (ma_don_thuoc, ma_phien_kham, tong_tien, ngay_ke_don) VALUES
(1,  1,  150000, '2026-09-20 08:30:00'),
(2,  2,  255000, '2026-09-20 09:30:00'),
(3,  3,  135000, '2026-09-20 14:30:00'),
(4,  4,  90000,  '2026-09-21 08:30:00'),
(5,  5,  180000, '2026-09-21 10:30:00'),
(6,  6,  75000,  '2026-09-21 15:00:00'),
(7,  7,  240000, '2026-09-22 09:30:00'),
(8,  8,  120000, '2026-09-22 11:30:00'),
(9,  9,  105000, '2026-09-22 16:00:00'),
(10, 10, 165000, '2026-09-23 08:30:00'),
(11, 11, 315000, '2026-09-23 10:30:00'),
(12, 12, 90000,  '2026-09-23 17:00:00'),
(13, 13, 120000, '2026-09-24 09:30:00'),
(14, 14, 45000,  '2026-09-24 14:00:00'),
(15, 15, 105000, '2026-09-25 08:30:00'),
(16, 16, 285000, '2026-09-25 11:00:00'),
(17, 17, 135000, '2026-09-26 10:00:00'),
(18, 18, 90000,  '2026-09-26 15:00:00'),
(19, 19, 150000, '2026-09-26 17:00:00'),
(20, 20, 75000,  '2026-09-28 08:30:00');

INSERT INTO ChiTietDonThuoc (ma_chi_tiet, ma_don_thuoc, ma_thuoc, so_luong, lieu_luong, thanh_tien) VALUES
-- Đơn 1: Tăng huyết áp
(1,  1,  9,  30, 'Uống 1 viên mỗi sáng sau ăn, uống đều đặn hàng ngày', 60000),
(2,  1,  12, 30, 'Uống 1 viên mỗi tối trước khi đi ngủ, không uống khi đói', 195000),
(3,  1,  18, 30, 'Uống 1 viên mỗi sáng, giúp tăng đề kháng', 75000),

-- Đơn 2: Đau thắt ngực
(4,  2,  4,  30, 'Uống 1 viên mỗi sáng sau ăn, không nhai viên thuốc', 54000),
(5,  2,  10, 30, 'Uống 1 viên mỗi sáng, huyết áp cần theo dõi', 105000),
(6,  2,  11, 30, 'Uống 1 viên mỗi sáng, không ngừng thuốc đột ngột', 120000),
(7,  2,  12, 30, 'Uống 1 viên buổi tối trước khi đi ngủ', 195000),

-- Đơn 3: Thiếu máu
(8,  3,  18, 30, 'Uống 1 viên mỗi sáng sau ăn', 75000),
(9,  3,  19, 30, 'Uống 1 viên mỗi sáng, bổ sung vitamin nhóm B', 90000),

-- Đơn 4: Viêm da dị ứng
(10, 4,  16, 30, 'Uống 1 viên mỗi tối trước khi đi ngủ, có thể gây buồn ngủ', 45000),
(11, 4,  17, 30, 'Uống 1 viên mỗi sáng, không dùng chung với rượu bia', 60000),

-- Đơn 5: Viêm dạ dày
(12, 5,  13, 30, 'Uống 1 viên trước bữa ăn sáng 30 phút, không nhai', 90000),
(13, 5,  14, 30, 'Uống 1 viên trước bữa ăn 15 phút, giảm đầy bụng khó tiêu', 60000),
(14, 5,  15, 15, 'Uống 1 gói pha với 50ml nước, ngày 2-3 lần khi đau bụng', 75000),

-- Đơn 6: Cảm cúm
(15, 6,  1,  20, 'Uống 1 viên khi sốt trên 38.5°C, không quá 4 viên/ngày', 30000),
(16, 6,  18, 20, 'Uống 1 viên mỗi sáng sau ăn', 50000),

-- Đơn 7: Thoái hóa khớp
(17, 7,  2,  30, 'Uống 1 viên sau bữa ăn sáng, không uống khi đói', 75000),
(18, 7,  20, 30, 'Uống 1 viên mỗi sáng sau ăn, bổ sung canxi cho xương', 135000),
(19, 7,  3,  30, 'Uống 1 viên khi đau nhiều, không quá 3 viên/ngày', 90000),

-- Đơn 8: Viêm da đầu
(20, 8,  16, 30, 'Uống 1 viên mỗi tối, giảm ngứa và viêm da', 45000),
(21, 8,  19, 30, 'Uống 1 viên mỗi sáng sau ăn', 90000),

-- Đơn 9: Rối loạn kinh nguyệt
(22, 9,  19, 30, 'Uống 1 viên mỗi sáng, hỗ trợ tuần hoàn máu', 90000),

-- Đơn 10: Viêm họng
(23, 10, 5,  30, 'Uống 1 viên mỗi 8 giờ, uống đủ liều 7 ngày', 105000),
(24, 10, 1,  20, 'Uống 1 viên khi đau họng, có thể ngậm', 30000),

-- Đơn 11: Tăng huyết áp độ 2
(25, 11, 9,  30, 'Uống 1 viên mỗi sáng sau ăn, không bỏ thuốc', 60000),
(26, 11, 12, 30, 'Uống 1 viên mỗi tối trước khi ngủ', 195000),
(27, 11, 4,  30, 'Uống 1 viên mỗi sáng, phòng ngừa biến chứng tim mạch', 54000),

-- Đơn 12: Sốt virus trẻ em
(28, 12, 1,  15, 'Cho trẻ uống 1/2 viên khi sốt, không quá 4 lần/ngày', 22500),
(29, 12, 18, 15, 'Cho trẻ uống 1/2 viên mỗi sáng, tăng sức đề kháng', 37500),

-- Đơn 13: Căng cơ lưng
(30, 13, 2,  20, 'Uống 1 viên sau ăn sáng và tối khi đau', 50000),
(31, 13, 15, 10, 'Uống 1 gói pha nước khi đau nhiều', 50000),

-- Đơn 14: Cận thị
(32, 14, 18, 30, 'Uống 1 viên mỗi sáng, hỗ trợ thị lực', 75000),

-- Đơn 15: Mụn trứng cá
(33, 15, 19, 30, 'Uống 1 viên mỗi sáng sau ăn', 90000),
(34, 15, 18, 30, 'Uống 1 viên mỗi sáng, hỗ trợ làm đẹp da', 75000),

-- Đơn 16: Viêm khớp dạng thấp
(35, 16, 2,  30, 'Uống 1 viên sau bữa ăn sáng và tối', 150000),
(36, 16, 20, 30, 'Uống 1 viên mỗi sáng, bổ sung canxi', 135000),

-- Đơn 17: Rối loạn lo âu
(37, 17, 19, 30, 'Uống 1 viên mỗi sáng, giảm căng thẳng thần kinh', 90000),
(38, 17, 17, 30, 'Uống 1 viên mỗi tối trước khi ngủ', 60000),

-- Đơn 18: Rối loạn tiêu hóa
(39, 18, 15, 10, 'Uống 1 gói pha nước, ngày 2-3 lần sau ăn', 50000),
(40, 18, 14, 20, 'Uống 1 viên trước ăn 15 phút, giảm đầy bụng', 40000),

-- Đơn 19: Viêm âm đạo
(41, 19, 16, 30, 'Uống 1 viên mỗi tối, giảm ngứa và viêm', 45000),

-- Đơn 20: Viêm kết mạc
(42, 20, 18, 30, 'Uống 1 viên mỗi sáng, hỗ trợ phục hồi', 75000);

INSERT INTO HoaDon (ma_hoa_don, ma_phien_kham, tien_kham_benh, tien_dich_vu, tien_thuoc, tong_cong, phuong_thuc, trang_thai, ngay_tao, ngay_thanh_toan) VALUES
(1,  1,  100000, 330000, 150000, 580000,  'TienMat',   'DaThanhToan',  '2026-09-20 08:00:00', '2026-09-20 09:00:00'),
(2,  2,  150000, 780000, 255000, 1185000, 'VNPay',     'DaThanhToan',  '2026-09-20 09:00:00', '2026-09-20 10:00:00'),
(3,  3,  100000, 250000, 135000, 485000,  'Momo',      'DaThanhToan',  '2026-09-20 14:00:00', '2026-09-20 15:00:00'),
(4,  4,  120000, 250000, 90000,  460000,  'TienMat',   'DaThanhToan',  '2026-09-21 08:00:00', '2026-09-21 09:00:00'),
(5,  5,  100000, 800000, 180000, 1080000, 'ChuyenKhoan','DaThanhToan', '2026-09-21 10:00:00', '2026-09-21 11:00:00'),
(6,  6,  150000, 250000, 75000,  475000,  'TienMat',   'DaThanhToan',  '2026-09-21 14:30:00', '2026-09-21 15:30:00'),
(7,  7,  120000, 550000, 240000, 910000,  'TienMat',   'DaThanhToan',  '2026-09-22 09:00:00', '2026-09-22 10:00:00'),
(8,  8,  120000, 250000, 120000, 490000,  'Momo',      'DaThanhToan',  '2026-09-22 11:00:00', '2026-09-22 12:00:00'),
(9,  9,  120000, 150000, 105000, 375000,  'TienMat',   'DaThanhToan',  '2026-09-22 15:30:00', '2026-09-22 16:30:00'),
(10, 10, 120000, 250000, 165000, 535000,  'TienMat',   'DaThanhToan',  '2026-09-23 08:00:00', '2026-09-23 09:00:00'),
(11, 11, 150000, 730000, 315000, 1195000, 'VNPay',     'DaThanhToan',  '2026-09-23 10:00:00', '2026-09-23 11:00:00'),
(12, 12, 120000, 250000, 90000,  460000,  'TienMat',   'DaThanhToan',  '2026-09-23 16:30:00', '2026-09-23 17:30:00'),
(13, 13, 100000, 300000, 120000, 520000,  'Momo',      'DaThanhToan',  '2026-09-24 09:00:00', '2026-09-24 10:00:00'),
(14, 14, 150000, 250000, 45000,  445000,  'TienMat',   'DaThanhToan',  '2026-09-24 13:30:00', '2026-09-24 14:30:00'),
(15, 15, 120000, 250000, 105000, 475000,  'TienMat',   'DaThanhToan',  '2026-09-25 08:00:00', '2026-09-25 09:00:00'),
(16, 16, 120000, 550000, 285000, 955000,  'VNPay',     'DaThanhToan',  '2026-09-25 10:30:00', '2026-09-25 11:30:00'),
(17, 17, 150000, 180000, 135000, 465000,  'TienMat',   'DaThanhToan',  '2026-09-26 09:30:00', '2026-09-26 10:30:00'),
(18, 18, 100000, 400000, 90000,  590000,  'Momo',      'DaThanhToan',  '2026-09-26 14:30:00', '2026-09-26 15:30:00'),
(19, 19, 150000, 150000, 150000, 450000,  'TienMat',   'DaThanhToan',  '2026-09-26 16:30:00', '2026-09-26 17:30:00'),
(20, 20, 150000, 250000, 75000,  475000,  'TienMat',   'DaThanhToan',  '2026-09-28 08:00:00', '2026-09-28 09:00:00');

INSERT INTO NhatKyHeThong (ma_nhat_ky, ma_tk, hanh_dong, bang_tac_dong, du_lieu_cu, du_lieu_moi, thoi_gian) VALUES
(1,  10, 'CREATE', 'LichKham',     NULL, '{"ma_lich_dat": 28, "ma_bn": 2, "ma_bs": 8, "trang_thai": "ChoXacNhan"}', '2026-09-28 08:00:00'),
(2,  10, 'CREATE', 'LichKham',     NULL, '{"ma_lich_dat": 29, "ma_bn": 3, "ma_bs": 5, "trang_thai": "ChoXacNhan"}', '2026-09-28 09:00:00'),
(3,  10, 'CREATE', 'LichKham',     NULL, '{"ma_lich_dat": 30, "ma_bn": 4, "ma_bs": 3, "trang_thai": "ChoXacNhan"}', '2026-09-28 10:00:00'),
(4,  2,  'CREATE', 'PhienKham',    NULL, '{"ma_phien_kham": 20, "ma_lich_dat": 21, "trang_thai": "ChoCanLamSang"}', '2026-09-28 08:00:00'),
(5,  2,  'UPDATE', 'PhienKham',    '{"trang_thai": "ChoCanLamSang"}', '{"trang_thai": "HoanThanh", "chan_doan_cuoi_cung": "Viêm kết mạc cấp"}', '2026-09-28 08:30:00'),
(6,  2,  'CREATE', 'DonThuoc',     NULL, '{"ma_don_thuoc": 20, "ma_phien_kham": 20, "tong_tien": 75000}', '2026-09-28 08:30:00'),
(7,  2,  'CREATE', 'HoaDon',       NULL, '{"ma_hoa_don": 20, "tong_cong": 475000, "trang_thai": "ChuaThanhToan"}', '2026-09-28 08:30:00'),
(8,  10, 'UPDATE', 'HoaDon',       '{"trang_thai": "ChuaThanhToan"}', '{"trang_thai": "DaThanhToan", "phuong_thuc": "TienMat"}', '2026-09-28 09:00:00'),
(9,  10, 'UPDATE', 'LichKham',     '{"trang_thai": "ChoThanhToan"}', '{"trang_thai": "HoanThanh"}', '2026-09-28 09:00:00'),
(10, 2,  'UPDATE', 'Thuoc',        '{"so_luong_ton": 2030}', '{"so_luong_ton": 2000}', '2026-09-28 08:30:00'),
(11, 11, 'UPDATE', 'LichKham',     '{"trang_thai": "ChoXacNhan"}', '{"trang_thai": "ChoKham", "thoi_gian_den_quay": "09:40:00"}', '2026-09-28 09:40:00'),
(12, 2,  'CREATE', 'PhienKham',    NULL, '{"ma_phien_kham": 21, "ma_lich_dat": 22, "trang_thai": "ChoCanLamSang"}', '2026-09-28 10:00:00'),
(13, 1,  'UPDATE', 'TaiKhoan',     '{"trang_thai": true}', '{"trang_thai": false}', '2026-09-28 10:30:00'),
(14, 10, 'CREATE', 'BenhNhan',     NULL, '{"ma_bn": 13, "ho_ten": "Trương Văn Khánh", "so_dien_thoai": "0923456789"}', '2026-09-28 11:00:00'),
(15, 1,  'UPDATE', 'ChuyenKhoa',   '{"mo_ta": "Cũ"}', '{"mo_ta": "Khám và điều trị các bệnh lý nội khoa tổng quát"}', '2026-09-28 11:30:00'),
(16, 1,  'CREATE', 'BacSi',        NULL, '{"ma_bs": 8, "ho_ten": "Bùi Văn Sơn", "ma_chuyen_khoa": 8}', '2026-09-28 12:00:00'),
(17, 10, 'CREATE', 'LichKham',     NULL, '{"ma_lich_dat": 25, "ma_bn": 12, "trang_thai": "ChoXacNhan"}', '2026-09-28 13:00:00'),
(18, 10, 'UPDATE', 'LichKham',     '{"trang_thai": "ChoXacNhan"}', '{"trang_thai": "DaHuy"}', '2026-09-28 14:00:00'),
(19, 11, 'CREATE', 'LichKham',     NULL, '{"ma_lich_dat": 26, "ma_bn": 13, "trang_thai": "ChoXacNhan"}', '2026-09-28 15:00:00'),
(20, 11, 'CREATE', 'LichKham',     NULL, '{"ma_lich_dat": 27, "ma_bn": 1, "trang_thai": "ChoXacNhan"}', '2026-09-28 16:00:00');

SELECT 'TaiKhoan'       AS bang, COUNT(*) AS so_luong FROM TaiKhoan
UNION ALL SELECT 'ChuyenKhoa',    COUNT(*) FROM ChuyenKhoa
UNION ALL SELECT 'BacSi',         COUNT(*) FROM BacSi
UNION ALL SELECT 'BenhNhan',      COUNT(*) FROM BenhNhan
UNION ALL SELECT 'CaLamViec',     COUNT(*) FROM CaLamViec
UNION ALL SELECT 'KhungGio',      COUNT(*) FROM KhungGio
UNION ALL SELECT 'Thuoc',         COUNT(*) FROM Thuoc
UNION ALL SELECT 'DichVu',        COUNT(*) FROM DichVu
UNION ALL SELECT 'LichKham',      COUNT(*) FROM LichKham
UNION ALL SELECT 'PhienKham',     COUNT(*) FROM PhienKham
UNION ALL SELECT 'ChiDinhDichVu', COUNT(*) FROM ChiDinhDichVu
UNION ALL SELECT 'DonThuoc',      COUNT(*) FROM DonThuoc
UNION ALL SELECT 'ChiTietDonThuoc', COUNT(*) FROM ChiTietDonThuoc
UNION ALL SELECT 'HoaDon',        COUNT(*) FROM HoaDon
UNION ALL SELECT 'NhatKyHeThong', COUNT(*) FROM NhatKyHeThong;