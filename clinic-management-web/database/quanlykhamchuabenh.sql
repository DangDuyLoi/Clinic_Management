-- --------------------------------------------------------
-- Máy chủ:                      127.0.0.1
-- Phiên bản máy chủ:            10.4.32-MariaDB - mariadb.org binary distribution
-- HĐH máy chủ:                  Win64
-- HeidiSQL Phiên bản:           12.22.0.7382
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Đang kết xuất đổ cấu trúc cơ sở dữ liệu cho quanlykhamchuabenh
CREATE DATABASE IF NOT EXISTS `quanlykhamchuabenh` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;
USE `quanlykhamchuabenh`;

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.bacsi
CREATE TABLE IF NOT EXISTS `bacsi` (
  `ma_bs` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_tk` bigint(20) unsigned DEFAULT NULL,
  `ma_chuyen_khoa` bigint(20) unsigned DEFAULT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `trinh_do` varchar(100) DEFAULT NULL,
  `luot_kham_toi_da_moi_ca` int(11) DEFAULT 20,
  PRIMARY KEY (`ma_bs`),
  UNIQUE KEY `ma_tk` (`ma_tk`),
  KEY `ma_chuyen_khoa` (`ma_chuyen_khoa`),
  CONSTRAINT `bacsi_ibfk_1` FOREIGN KEY (`ma_tk`) REFERENCES `taikhoan` (`ma_tk`) ON DELETE SET NULL,
  CONSTRAINT `bacsi_ibfk_2` FOREIGN KEY (`ma_chuyen_khoa`) REFERENCES `chuyenkhoa` (`ma_chuyen_khoa`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.bacsi: ~24 rows (xấp xỉ)
INSERT INTO `bacsi` (`ma_bs`, `ma_tk`, `ma_chuyen_khoa`, `ho_ten`, `trinh_do`, `luot_kham_toi_da_moi_ca`) VALUES
	(1, 2, 1, 'Hoàng Minh Tuấn', 'Thạc sĩ - Bác sĩ Chuyên khoa II Nội tổng hợp', 20),
	(2, 3, 2, 'Nguyễn Thị Mai Lan', 'Tiến sĩ - Bác sĩ Chuyên khoa II Tim mạch', 15),
	(3, 4, 3, 'Trần Quốc Khánh', 'Bác sĩ Chuyên khoa I Da liễu', 18),
	(4, 5, 4, 'Lê Thị Thu Hằng', 'Thạc sĩ - Bác sĩ Nhi khoa', 25),
	(5, 6, 5, 'Phạm Đức Thành', 'Bác sĩ Chuyên khoa I Tai Mũi Họng', 20),
	(6, 7, 6, 'Vũ Minh Tâm', 'Thạc sĩ - Bác sĩ Chuyên khoa II Xương khớp', 18),
	(7, 8, 7, 'Đặng Thị Thảo Vy', 'Bác sĩ Chuyên khoa I Sản phụ khoa', 15),
	(8, 9, 8, 'Bùi Văn Sơn', 'Thạc sĩ - Bác sĩ Chuyên khoa II Mắt', 20),
	(9, 26, 1, 'PGS.TS.BS Nguyễn Văn Trí', 'Phó Giáo sư - Bác sĩ Cao cấp Nội khoa', 20),
	(10, 27, 1, 'BS.CKII Trần Thị Thu Thủy', 'Bác sĩ Chuyên khoa II Nội Tiêu hóa', 20),
	(11, 28, 2, 'PGS.TS.BS Phạm Nguyễn Vinh', 'Chuyên gia Tim mạch học', 15),
	(12, 29, 2, 'ThS.BS Lê Huỳnh Trí', 'Thạc sĩ - Bác sĩ Can thiệp Tim mạch', 20),
	(13, 30, 3, 'TS.BS Lê Thái Vân Thanh', 'Tiến sĩ - Bác sĩ Da liễu', 20),
	(14, 31, 3, 'BS.CKII Nguyễn Thị Phương', 'Bác sĩ Chuyên khoa II Da liễu thẩm mỹ', 20),
	(15, 32, 4, 'PGS.TS.BS Nguyễn Anh Tuấn', 'Phó Giáo sư Nhi khoa', 25),
	(16, 33, 4, 'ThS.BS Bạch Văn Cam', 'Bác sĩ Hồi sức cấp cứu Nhi', 25),
	(17, 34, 5, 'PGS.TS.BS Nguyễn Thị Ngọc Dinh', 'Nguyên Giám đốc BV Tai Mũi Họng', 15),
	(18, 35, 5, 'BS.CKII Trần Việt Hồng', 'Bác sĩ Chuyên khoa II Tai Mũi Họng', 20),
	(19, 36, 6, 'PGS.TS.BS Lê Anh Thư', 'Chủ tịch hội Thấp khớp học', 15),
	(20, 37, 6, 'ThS.BS Võ Xuân Sơn', 'Chuyên gia Phẫu thuật Cột sống', 18),
	(21, 38, 7, 'BS.CKII Vương Thị Ngọc Lan', 'Chuyên gia Hiếm muộn - Sản khoa', 15),
	(22, 39, 7, 'ThS.BS Lê Quang Thanh', 'Bác sĩ Cao cấp - Chuyên gia Sản khoa', 20),
	(23, 40, 8, 'GS.TS.BS Đỗ Như Hơn', 'Giáo sư Nhãn khoa', 15),
	(24, 41, 8, 'BS.CKII Trần Thị Phương Thu', 'Bác sĩ Chuyên khoa II Mắt', 20);

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.benhnhan
CREATE TABLE IF NOT EXISTS `benhnhan` (
  `ma_benh_nhan` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_tk` bigint(20) unsigned DEFAULT NULL,
  `ho_ten` varchar(100) NOT NULL,
  `ngay_sinh` date DEFAULT NULL,
  `gioi_tinh` tinyint(4) DEFAULT 1,
  `que_quan` varchar(100) DEFAULT NULL,
  `so_dien_thoai` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `cccd` varchar(20) DEFAULT NULL,
  `dia_chi` varchar(255) DEFAULT NULL,
  `nguoi_lien_he_khan_cap` varchar(100) DEFAULT NULL,
  `tien_su_benh` text DEFAULT NULL,
  `di_ung` text DEFAULT NULL,
  `nhom_mau` varchar(5) DEFAULT NULL,
  `ma_bhyt` varchar(20) DEFAULT NULL,
  `muc_huong_bhyt` int(11) DEFAULT NULL,
  `ngay_het_han_bhyt` date DEFAULT NULL,
  PRIMARY KEY (`ma_benh_nhan`),
  UNIQUE KEY `ma_tk` (`ma_tk`),
  UNIQUE KEY `so_dien_thoai` (`so_dien_thoai`),
  UNIQUE KEY `cccd` (`cccd`),
  CONSTRAINT `benhnhan_ibfk_1` FOREIGN KEY (`ma_tk`) REFERENCES `taikhoan` (`ma_tk`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.benhnhan: ~14 rows (xấp xỉ)
INSERT INTO `benhnhan` (`ma_benh_nhan`, `ma_tk`, `ho_ten`, `ngay_sinh`, `gioi_tinh`, `que_quan`, `so_dien_thoai`, `email`, `cccd`, `dia_chi`, `nguoi_lien_he_khan_cap`, `tien_su_benh`, `di_ung`, `nhom_mau`, `ma_bhyt`, `muc_huong_bhyt`, `ngay_het_han_bhyt`) VALUES
	(1, 13, 'Nguyễn Hoàng Phúc', '2023-05-15', 1, 'Thành phố Đà Nẵng', '0901234567', 'nguyenhoangphuc@gmail.com', '048223862099', '123 Lê Lợi, Quận 1, TP.HCM', 'Nguyễn Thị Hoa (vợ) - 0901234568', 'Tăng huyết áp', 'Không', 'O', 'TE1791234567890', NULL, NULL),
	(2, 14, 'Trần Thị Kim Oanh', '2010-08-20', 0, 'Thành phố Hải Phòng', '0912345678', 'tranthikimoanh@gmail.com', '030310359704', '456 Nguyễn Huệ, Quận 1, TP.HCM', 'Trần Văn Minh (chồng) - 0912345679', 'Không', 'Dị ứng hải sản', 'A', 'HS4019876543210', NULL, NULL),
	(3, 15, 'Lê Quốc Bảo', '1998-03-10', 1, 'Thành phố Hải Phòng', '0903456789', 'lequocbao@gmail.com', '031098134273', '789 Võ Văn Tần, Quận 3, TP.HCM', 'Lê Thị Mai (vợ) - 0903456790', 'Đái tháo đường type 2', 'Không', 'B', 'DN4481112223334', NULL, NULL),
	(4, 16, 'Phạm Ngọc Diễm', '1955-11-05', 0, 'Tỉnh Đồng Nai', '0934567890', 'phamngocdiem@gmail.com', '075155308909', '101 Điện Biên Phủ, Quận 3, TP.HCM', 'Phạm Văn Hùng (bố) - 0934567891', 'Không', 'Dị ứng penicillin', 'AB', 'HT3795556667778', NULL, NULL),
	(5, 17, 'Hoàng Đức Huy', '2004-12-12', 1, 'Thành phố Đà Nẵng', '0945678901', 'hoangduchuy@gmail.com', '048204387566', '202 Cách Mạng Tháng 8, Quận 10, TP.HCM', 'Hoàng Thị Lan (mẹ) - 0945678902', 'Viêm gan B', 'Không', 'O', 'SV4922223334445', NULL, NULL),
	(6, 18, 'Vũ Thị Ánh Tuyết', '2000-05-12', 0, 'Thành phố Cần Thơ', '0956789012', 'vuthianhtuyet@gmail.com', '092300010111', '303 Lý Thường Kiệt, Quận 10, TP.HCM', 'Vũ Văn Nam (bố) - 0956789013', 'Không', 'Không', 'A', 'CC1318889990001', NULL, NULL),
	(7, 19, 'Đặng Xuân Trường', '1975-12-25', 1, 'Thành phố Hồ Chí Minh', '0967890123', 'dangxuantruong@gmail.com', '079075007890', '404 Hoàng Văn Thụ, Tân Bình, TP.HCM', 'Đặng Thị Thu (vợ) - 0967890124', 'Thoái hóa khớp gối', 'Không', 'B', NULL, NULL, NULL),
	(8, 20, 'Bùi Thanh Hà', '1988-08-08', 0, 'Thành phố Hải Phòng', '0978901234', 'buithanhha@gmail.com', '031188048956', '505 Trường Chinh, Tân Bình, TP.HCM', 'Bùi Văn Tâm (chồng) - 0978901235', 'Không', 'Dị ứng phấn hoa', 'O', NULL, NULL, NULL),
	(9, 21, 'Đỗ Minh Khuê', '1992-04-20', 0, 'Thành phố Hải Phòng', '0989012345', 'dominhkhue@gmail.com', '031192015379', '606 Lê Văn Sỹ, Quận 3, TP.HCM', 'Đỗ Văn Long (bố) - 0989012346', 'Không', 'Không', 'A', NULL, NULL, NULL),
	(10, 22, 'Ngô Gia Linh', '1998-10-14', 0, 'Thành phố Hải Phòng', '0990123456', 'ngogialinh@gmail.com', '030198234056', '707 Nguyễn Trãi, Quận 5, TP.HCM', 'Ngô Văn Tùng (chồng) - 0990123457', 'Không', 'Dị ứng tôm cua', 'B', NULL, NULL, NULL),
	(11, 23, 'Đinh Trọng Nghĩa', '1968-06-03', 1, 'Thành phố Hồ Chí Minh', '0901234568', 'dinhtrongnghia@gmail.com', '079068001234', '808 Hùng Vương, Quận 5, TP.HCM', 'Đinh Thị Nga (vợ) - 0901234569', 'Cao huyết áp, mỡ máu cao', 'Không', 'O', NULL, NULL, NULL),
	(12, 24, 'Lưu Bảo Ngọc', '2005-01-28', 0, 'Thành phố Hồ Chí Minh', '0912345680', 'luubaongoc@gmail.com', '079305206190', '909 Trần Hưng Đạo, Quận 1, TP.HCM', 'Lưu Văn Bình (bố) - 0912345681', 'Không', 'Không', 'AB', NULL, NULL, NULL),
	(13, 25, 'Trương Văn Khánh', '1980-07-19', 1, 'Thành phố Hồ Chí Minh', '0923456789', 'truongvankhanh@gmail.com', '079080003456', '111 Pasteur, Quận 1, TP.HCM', 'Trương Thị Tuyết (vợ) - 0923456790', 'Viêm dạ dày mãn tính', 'Không', 'A', NULL, NULL, NULL),
	(28, NULL, 'Bùi Quang Tiến', '2005-11-11', 1, 'Thành phố Hồ Chí Minh', '0961521561', 'buiquangtien@gmail.com', '079205009478', '15 Tân Thời', NULL, NULL, NULL, 'B', 'SV4794567890112', NULL, NULL);

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.calamviec
CREATE TABLE IF NOT EXISTS `calamviec` (
  `ma_ca` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_ca` varchar(50) NOT NULL,
  `gio_bat_dau` time NOT NULL,
  `gio_ket_thuc` time NOT NULL,
  `luot_kham_toi_da` int(11) DEFAULT 20,
  PRIMARY KEY (`ma_ca`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.calamviec: ~2 rows (xấp xỉ)
INSERT INTO `calamviec` (`ma_ca`, `ten_ca`, `gio_bat_dau`, `gio_ket_thuc`, `luot_kham_toi_da`) VALUES
	(1, 'Ca sáng', '07:30:00', '11:30:00', 100),
	(2, 'Ca chiều', '13:00:00', '17:00:00', 100);

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.chidinhdichvu
CREATE TABLE IF NOT EXISTS `chidinhdichvu` (
  `ma_chi_dinh` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_phien_kham` bigint(20) unsigned NOT NULL,
  `ma_dich_vu` bigint(20) unsigned NOT NULL,
  `ket_qua_chi_tiet` text DEFAULT NULL,
  `trang_thai` varchar(50) DEFAULT 'ChoThucHien',
  PRIMARY KEY (`ma_chi_dinh`),
  KEY `ma_phien_kham` (`ma_phien_kham`),
  KEY `ma_dich_vu` (`ma_dich_vu`),
  CONSTRAINT `chidinhdichvu_ibfk_1` FOREIGN KEY (`ma_phien_kham`) REFERENCES `phienkham` (`ma_phien_kham`) ON DELETE CASCADE,
  CONSTRAINT `chidinhdichvu_ibfk_2` FOREIGN KEY (`ma_dich_vu`) REFERENCES `dichvu` (`ma_dich_vu`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.chidinhdichvu: ~26 rows (xấp xỉ)
INSERT INTO `chidinhdichvu` (`ma_chi_dinh`, `ma_phien_kham`, `ma_dich_vu`, `ket_qua_chi_tiet`, `trang_thai`) VALUES
	(1, 1, 1, 'Hồng cầu 4.5 T/L - Bình thường', 'DaCoKetQua'),
	(2, 1, 7, 'Nhịp xoang đều - Bình thường', 'DaCoKetQua'),
	(3, 2, 7, 'ST chênh xuống nhẹ - Nghi ngờ thiếu máu cơ tim', 'DaCoKetQua'),
	(4, 2, 8, 'EF 55%, không có huyết khối', 'DaCoKetQua'),
	(5, 2, 3, 'Cholesterol 6.2 mmol/L (cao)', 'DaCoKetQua'),
	(6, 3, 1, 'Hemoglobin 105 g/L - Thiếu máu nhẹ', 'DaCoKetQua'),
	(7, 4, 1, 'Bạch cầu ái toan tăng nhẹ', 'DaCoKetQua'),
	(8, 5, 13, 'Viêm trợt nhỏ niêm mạc dạ dày', 'DaCoKetQua'),
	(9, 6, 1, 'Bạch cầu bình thường', 'DaCoKetQua'),
	(10, 7, 12, 'Thoái hóa khớp gối độ 2', 'DaCoKetQua'),
	(11, 7, 1, 'CRP 5 mg/L (tăng nhẹ)', 'DaCoKetQua'),
	(12, 10, 1, 'Bạch cầu tăng - Nhiễm khuẩn', 'DaCoKetQua'),
	(13, 11, 7, 'Dày thất trái nhẹ', 'DaCoKetQua'),
	(14, 11, 3, 'Cholesterol 5.8 mmol/L', 'DaCoKetQua'),
	(15, 11, 5, 'Creatinine 95 µmol/L - Bình thường', 'DaCoKetQua'),
	(16, 12, 1, 'Lymphocyte 45% - Nghi virus', 'DaCoKetQua'),
	(17, 14, 1, 'Công thức máu bình thường', 'DaCoKetQua'),
	(18, 16, 1, 'RF dương tính', 'DaCoKetQua'),
	(19, 16, 12, 'Hẹp khe khớp nhẹ', 'DaCoKetQua'),
	(20, 17, 7, 'Nhịp nhanh xoang 105', 'DaCoKetQua'),
	(21, 18, 1, 'Bình thường', 'DaCoKetQua'),
	(22, 18, 6, 'Nước tiểu vàng đậm', 'DaCoKetQua'),
	(23, 19, 6, 'Nước tiểu bình thường', 'DaCoKetQua'),
	(24, 20, 1, 'Bình thường', 'DaCoKetQua'),
	(27, 21, 14, NULL, 'ChoThucHien'),
	(28, 22, 15, NULL, 'ChoThucHien'),
	(29, 22, 12, NULL, 'ChoThucHien');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.chitietdonthuoc
CREATE TABLE IF NOT EXISTS `chitietdonthuoc` (
  `ma_chi_tiet` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_don_thuoc` bigint(20) unsigned NOT NULL,
  `ma_thuoc` bigint(20) unsigned NOT NULL,
  `so_luong` int(11) NOT NULL,
  `lieu_luong` varchar(255) NOT NULL,
  `thanh_tien` decimal(12,2) NOT NULL,
  PRIMARY KEY (`ma_chi_tiet`),
  KEY `ma_don_thuoc` (`ma_don_thuoc`),
  KEY `ma_thuoc` (`ma_thuoc`),
  CONSTRAINT `chitietdonthuoc_ibfk_1` FOREIGN KEY (`ma_don_thuoc`) REFERENCES `donthuoc` (`ma_don_thuoc`) ON DELETE CASCADE,
  CONSTRAINT `chitietdonthuoc_ibfk_2` FOREIGN KEY (`ma_thuoc`) REFERENCES `thuoc` (`ma_thuoc`)
) ENGINE=InnoDB AUTO_INCREMENT=44 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.chitietdonthuoc: ~42 rows (xấp xỉ)
INSERT INTO `chitietdonthuoc` (`ma_chi_tiet`, `ma_don_thuoc`, `ma_thuoc`, `so_luong`, `lieu_luong`, `thanh_tien`) VALUES
	(1, 1, 9, 30, 'Uống 1 viên mỗi sáng', 60000.00),
	(2, 1, 12, 30, 'Uống 1 viên mỗi tối', 195000.00),
	(3, 1, 18, 30, 'Uống 1 viên mỗi sáng', 75000.00),
	(4, 2, 4, 30, 'Uống 1 viên mỗi sáng', 54000.00),
	(5, 2, 10, 30, 'Uống 1 viên mỗi sáng', 105000.00),
	(6, 2, 11, 30, 'Uống 1 viên mỗi sáng', 120000.00),
	(7, 2, 12, 30, 'Uống 1 viên mỗi tối', 195000.00),
	(8, 3, 18, 30, 'Uống 1 viên mỗi sáng', 75000.00),
	(9, 3, 19, 30, 'Uống 1 viên mỗi sáng', 90000.00),
	(10, 4, 16, 30, 'Uống 1 viên mỗi tối', 45000.00),
	(11, 4, 17, 30, 'Uống 1 viên mỗi sáng', 60000.00),
	(12, 5, 13, 30, 'Uống 1 viên trước ăn', 90000.00),
	(13, 5, 14, 30, 'Uống 1 viên trước ăn', 60000.00),
	(14, 5, 15, 15, 'Uống 1 gói khi đau', 75000.00),
	(15, 6, 1, 20, 'Uống 1 viên khi sốt', 30000.00),
	(16, 6, 18, 20, 'Uống 1 viên mỗi sáng', 50000.00),
	(17, 7, 2, 30, 'Uống 1 viên sau ăn', 75000.00),
	(18, 7, 20, 30, 'Uống 1 viên mỗi sáng', 135000.00),
	(19, 7, 3, 30, 'Uống 1 viên khi đau', 90000.00),
	(20, 8, 16, 30, 'Uống 1 viên mỗi tối', 45000.00),
	(21, 8, 19, 30, 'Uống 1 viên mỗi sáng', 90000.00),
	(22, 9, 19, 30, 'Uống 1 viên mỗi sáng', 90000.00),
	(23, 10, 5, 30, 'Uống 1 viên mỗi 8 giờ', 105000.00),
	(24, 10, 1, 20, 'Uống 1 viên khi đau', 30000.00),
	(25, 11, 9, 30, 'Uống 1 viên mỗi sáng', 60000.00),
	(26, 11, 12, 30, 'Uống 1 viên mỗi tối', 195000.00),
	(27, 11, 4, 30, 'Uống 1 viên mỗi sáng', 54000.00),
	(28, 12, 1, 15, 'Cho trẻ uống 1/2 viên', 22500.00),
	(29, 12, 18, 15, 'Cho trẻ uống 1/2 viên', 37500.00),
	(30, 13, 2, 20, 'Uống 1 viên khi đau', 50000.00),
	(31, 13, 15, 10, 'Uống 1 gói khi đau', 50000.00),
	(32, 14, 18, 30, 'Uống 1 viên mỗi sáng', 75000.00),
	(33, 15, 19, 30, 'Uống 1 viên mỗi sáng', 90000.00),
	(34, 15, 18, 30, 'Uống 1 viên mỗi sáng', 75000.00),
	(35, 16, 2, 30, 'Uống 1 viên sau ăn', 150000.00),
	(36, 16, 20, 30, 'Uống 1 viên mỗi sáng', 135000.00),
	(37, 17, 19, 30, 'Uống 1 viên mỗi sáng', 90000.00),
	(38, 17, 17, 30, 'Uống 1 viên mỗi tối', 60000.00),
	(39, 18, 15, 10, 'Uống 1 gói sau ăn', 50000.00),
	(40, 18, 14, 20, 'Uống 1 viên trước ăn', 40000.00),
	(41, 19, 16, 30, 'Uống 1 viên mỗi tối', 45000.00),
	(42, 20, 18, 30, 'Uống 1 viên mỗi sáng', 75000.00);

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.chuyenkhoa
CREATE TABLE IF NOT EXISTS `chuyenkhoa` (
  `ma_chuyen_khoa` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_chuyen_khoa` varchar(100) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `trang_thai` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`ma_chuyen_khoa`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.chuyenkhoa: ~8 rows (xấp xỉ)
INSERT INTO `chuyenkhoa` (`ma_chuyen_khoa`, `ten_chuyen_khoa`, `mo_ta`, `trang_thai`) VALUES
	(1, 'Nội tổng hợp', 'Khám và điều trị các bệnh lý nội khoa tổng quát', 1),
	(2, 'Tim mạch', 'Khám, chẩn đoán và điều trị các bệnh lý về tim và mạch máu', 1),
	(3, 'Da liễu', 'Khám và điều trị các bệnh về da, tóc, móng', 1),
	(4, 'Nhi khoa', 'Khám và điều trị bệnh lý cho trẻ em từ 0-16 tuổi', 1),
	(5, 'Tai Mũi Họng', 'Khám và điều trị các bệnh về tai, mũi, họng', 1),
	(6, 'Xương khớp', 'Khám và điều trị các bệnh về cơ xương khớp', 1),
	(7, 'Sản phụ khoa', 'Khám phụ khoa, theo dõi thai kỳ', 1),
	(8, 'Mắt', 'Khám và điều trị các bệnh về mắt', 1);

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.dichvu
CREATE TABLE IF NOT EXISTS `dichvu` (
  `ma_dich_vu` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_dich_vu` varchar(150) NOT NULL,
  `don_gia` decimal(12,2) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  PRIMARY KEY (`ma_dich_vu`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.dichvu: ~15 rows (xấp xỉ)
INSERT INTO `dichvu` (`ma_dich_vu`, `ten_dich_vu`, `don_gia`, `mo_ta`) VALUES
	(1, 'Xét nghiệm máu cơ bản', 250000.00, 'Tổng phân tích tế bào máu'),
	(2, 'Xét nghiệm đường huyết', 120000.00, 'Đo nồng độ glucose'),
	(3, 'Xét nghiệm mỡ máu', 280000.00, 'Định lượng cholesterol'),
	(4, 'Xét nghiệm chức năng gan', 350000.00, 'Đánh giá men gan'),
	(5, 'Xét nghiệm chức năng thận', 300000.00, 'Định lượng creatinine'),
	(6, 'Xét nghiệm nước tiểu', 150000.00, 'Phân tích 10 thông số'),
	(7, 'Đo điện tâm đồ (ECG)', 180000.00, 'Ghi lại hoạt động điện của tim'),
	(8, 'Siêu âm tim', 500000.00, 'Đánh giá cấu trúc tim'),
	(9, 'Siêu âm bụng tổng quát', 350000.00, 'Khảo sát ổ bụng'),
	(10, 'Siêu âm tuyến giáp', 300000.00, 'Đánh giá tuyến giáp'),
	(11, 'X-quang ngực thẳng', 250000.00, 'Chụp X-quang phổi'),
	(12, 'X-quang cột sống thắt lưng', 300000.00, 'Khảo sát cột sống'),
	(13, 'Nội soi dạ dày', 800000.00, 'Quan sát niêm mạc dạ dày'),
	(14, 'Đo chức năng hô hấp', 400000.00, 'Đánh giá dung tích phổi'),
	(15, 'Đo mật độ xương (DEXA)', 600000.00, 'Chẩn đoán loãng xương');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.donthuoc
CREATE TABLE IF NOT EXISTS `donthuoc` (
  `ma_don_thuoc` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_phien_kham` bigint(20) unsigned NOT NULL,
  `tong_tien` decimal(12,2) DEFAULT 0.00,
  `ngay_ke_don` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ma_don_thuoc`),
  UNIQUE KEY `ma_phien_kham` (`ma_phien_kham`),
  CONSTRAINT `donthuoc_ibfk_1` FOREIGN KEY (`ma_phien_kham`) REFERENCES `phienkham` (`ma_phien_kham`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.donthuoc: ~20 rows (xấp xỉ)
INSERT INTO `donthuoc` (`ma_don_thuoc`, `ma_phien_kham`, `tong_tien`, `ngay_ke_don`) VALUES
	(1, 1, 150000.00, '2026-09-20 08:30:00'),
	(2, 2, 255000.00, '2026-09-20 09:30:00'),
	(3, 3, 135000.00, '2026-09-20 14:30:00'),
	(4, 4, 90000.00, '2026-09-21 08:30:00'),
	(5, 5, 180000.00, '2026-09-21 10:30:00'),
	(6, 6, 75000.00, '2026-09-21 15:00:00'),
	(7, 7, 240000.00, '2026-09-22 09:30:00'),
	(8, 8, 120000.00, '2026-09-22 11:30:00'),
	(9, 9, 105000.00, '2026-09-22 16:00:00'),
	(10, 10, 165000.00, '2026-09-23 08:30:00'),
	(11, 11, 315000.00, '2026-09-23 10:30:00'),
	(12, 12, 90000.00, '2026-09-23 17:00:00'),
	(13, 13, 120000.00, '2026-09-24 09:30:00'),
	(14, 14, 45000.00, '2026-09-24 14:00:00'),
	(15, 15, 105000.00, '2026-09-25 08:30:00'),
	(16, 16, 285000.00, '2026-09-25 11:00:00'),
	(17, 17, 135000.00, '2026-09-26 10:00:00'),
	(18, 18, 90000.00, '2026-09-26 15:00:00'),
	(19, 19, 150000.00, '2026-09-26 17:00:00'),
	(20, 20, 75000.00, '2026-09-28 08:30:00');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.hoadon
CREATE TABLE IF NOT EXISTS `hoadon` (
  `ma_hoa_don` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_phien_kham` bigint(20) unsigned NOT NULL,
  `tien_kham_benh` decimal(12,2) DEFAULT 0.00,
  `tien_dich_vu` decimal(12,2) DEFAULT 0.00,
  `tien_thuoc` decimal(12,2) DEFAULT 0.00,
  `tong_cong` decimal(12,2) NOT NULL,
  `tien_bhyt_tra` decimal(12,2) DEFAULT 0.00,
  `tien_benh_nhan_tra` decimal(12,2) DEFAULT 0.00,
  `phuong_thuc` varchar(50) DEFAULT NULL,
  `trang_thai` varchar(50) DEFAULT 'ChuaThanhToan',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  `ngay_thanh_toan` datetime DEFAULT NULL,
  PRIMARY KEY (`ma_hoa_don`),
  UNIQUE KEY `ma_phien_kham` (`ma_phien_kham`),
  CONSTRAINT `hoadon_ibfk_1` FOREIGN KEY (`ma_phien_kham`) REFERENCES `phienkham` (`ma_phien_kham`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.hoadon: ~21 rows (xấp xỉ)
INSERT INTO `hoadon` (`ma_hoa_don`, `ma_phien_kham`, `tien_kham_benh`, `tien_dich_vu`, `tien_thuoc`, `tong_cong`, `tien_bhyt_tra`, `tien_benh_nhan_tra`, `phuong_thuc`, `trang_thai`, `ngay_tao`, `ngay_thanh_toan`) VALUES
	(1, 1, 100000.00, 330000.00, 150000.00, 580000.00, 0.00, 580000.00, 'TienMat', 'DaThanhToan', '2026-09-20 08:00:00', '2026-09-20 09:00:00'),
	(2, 2, 150000.00, 780000.00, 255000.00, 1185000.00, 0.00, 1185000.00, 'VNPay', 'DaThanhToan', '2026-09-20 09:00:00', '2026-09-20 10:00:00'),
	(3, 3, 100000.00, 250000.00, 135000.00, 485000.00, 0.00, 485000.00, 'Momo', 'DaThanhToan', '2026-09-20 14:00:00', '2026-09-20 15:00:00'),
	(4, 4, 120000.00, 250000.00, 90000.00, 460000.00, 0.00, 460000.00, 'TienMat', 'DaThanhToan', '2026-09-21 08:00:00', '2026-09-21 09:00:00'),
	(5, 5, 100000.00, 800000.00, 180000.00, 1080000.00, 0.00, 1080000.00, 'ChuyenKhoan', 'DaThanhToan', '2026-09-21 10:00:00', '2026-09-21 11:00:00'),
	(6, 6, 150000.00, 250000.00, 75000.00, 475000.00, 0.00, 475000.00, 'TienMat', 'DaThanhToan', '2026-09-21 14:30:00', '2026-09-21 15:30:00'),
	(7, 7, 120000.00, 550000.00, 240000.00, 910000.00, 0.00, 910000.00, 'TienMat', 'DaThanhToan', '2026-09-22 09:00:00', '2026-09-22 10:00:00'),
	(8, 8, 120000.00, 250000.00, 120000.00, 490000.00, 0.00, 490000.00, 'Momo', 'DaThanhToan', '2026-09-22 11:00:00', '2026-09-22 12:00:00'),
	(9, 9, 120000.00, 150000.00, 105000.00, 375000.00, 0.00, 375000.00, 'TienMat', 'DaThanhToan', '2026-09-22 15:30:00', '2026-09-22 16:30:00'),
	(10, 10, 120000.00, 250000.00, 165000.00, 535000.00, 0.00, 535000.00, 'TienMat', 'DaThanhToan', '2026-09-23 08:00:00', '2026-09-23 09:00:00'),
	(11, 11, 150000.00, 730000.00, 315000.00, 1195000.00, 0.00, 1195000.00, 'VNPay', 'DaThanhToan', '2026-09-23 10:00:00', '2026-09-23 11:00:00'),
	(12, 12, 120000.00, 250000.00, 90000.00, 460000.00, 0.00, 460000.00, 'TienMat', 'DaThanhToan', '2026-09-23 16:30:00', '2026-09-23 17:30:00'),
	(13, 13, 100000.00, 300000.00, 120000.00, 520000.00, 0.00, 520000.00, 'Momo', 'DaThanhToan', '2026-09-24 09:00:00', '2026-09-24 10:00:00'),
	(14, 14, 150000.00, 250000.00, 45000.00, 445000.00, 0.00, 445000.00, 'TienMat', 'DaThanhToan', '2026-09-24 13:30:00', '2026-09-24 14:30:00'),
	(15, 15, 120000.00, 250000.00, 105000.00, 475000.00, 0.00, 475000.00, 'TienMat', 'DaThanhToan', '2026-09-25 08:00:00', '2026-09-25 09:00:00'),
	(16, 16, 120000.00, 550000.00, 285000.00, 955000.00, 0.00, 955000.00, 'VNPay', 'DaThanhToan', '2026-09-25 10:30:00', '2026-09-25 11:30:00'),
	(17, 17, 150000.00, 180000.00, 135000.00, 465000.00, 0.00, 465000.00, 'TienMat', 'DaThanhToan', '2026-09-26 09:30:00', '2026-09-26 10:30:00'),
	(18, 18, 100000.00, 400000.00, 90000.00, 590000.00, 0.00, 590000.00, 'Momo', 'DaThanhToan', '2026-09-26 14:30:00', '2026-09-26 15:30:00'),
	(19, 19, 150000.00, 150000.00, 150000.00, 450000.00, 0.00, 450000.00, 'TienMat', 'DaThanhToan', '2026-09-26 16:30:00', '2026-09-26 17:30:00'),
	(20, 20, 150000.00, 250000.00, 75000.00, 475000.00, 0.00, 475000.00, 'TienMat', 'DaThanhToan', '2026-09-28 08:00:00', '2026-09-28 09:00:00'),
	(21, 21, 0.00, 400000.00, 0.00, 400000.00, 320000.00, 80000.00, NULL, 'ChuaThanhToan', '2026-11-09 16:05:31', NULL),
	(22, 22, 0.00, 900000.00, 0.00, 900000.00, 855000.00, 45000.00, 'VNPay', 'DaThanhToan', '2026-11-09 16:38:52', '2026-11-09 16:41:07');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.hosobenhan
CREATE TABLE IF NOT EXISTS `hosobenhan` (
  `ma_ho_so` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_benh_nhan` bigint(20) unsigned DEFAULT NULL,
  `tien_su_benh` text DEFAULT NULL,
  `nhom_mau` varchar(5) DEFAULT NULL,
  `ma_bhyt` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ma_ho_so`),
  UNIQUE KEY `ma_benh_nhan` (`ma_benh_nhan`),
  CONSTRAINT `hosobenhan_ibfk_1` FOREIGN KEY (`ma_benh_nhan`) REFERENCES `benhnhan` (`ma_benh_nhan`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.hosobenhan: ~14 rows (xấp xỉ)
INSERT INTO `hosobenhan` (`ma_ho_so`, `ma_benh_nhan`, `tien_su_benh`, `nhom_mau`, `ma_bhyt`) VALUES
	(1, 1, 'Tăng huyết áp', 'O', 'TE1791234567890'),
	(2, 2, 'Không', 'A', 'HS4019876543210'),
	(3, 3, 'Đái tháo đường type 2', 'B', 'DN4481112223334'),
	(4, 4, 'Không', 'AB', 'HT3795556667778'),
	(5, 5, 'Viêm gan B', 'O', 'SV4922223334445'),
	(6, 6, 'Không', 'A', 'CC1318889990001'),
	(7, 7, 'Thoái hóa khớp gối', 'B', NULL),
	(8, 8, 'Không', 'O', NULL),
	(9, 9, 'Không', 'A', NULL),
	(10, 10, 'Không', 'B', NULL),
	(11, 11, 'Cao huyết áp, mỡ máu cao', 'O', NULL),
	(12, 12, 'Không', 'AB', NULL),
	(13, 13, 'Viêm dạ dày mãn tính', 'A', NULL),
	(27, 28, NULL, 'B', 'SV4794567890112');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.khunggio
CREATE TABLE IF NOT EXISTS `khunggio` (
  `ma_khung_gio` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_ca` bigint(20) unsigned NOT NULL,
  `gio_bat_dau` time NOT NULL,
  `gio_ket_thuc` time NOT NULL,
  `luot_kham_toi_da` int(11) DEFAULT 3,
  PRIMARY KEY (`ma_khung_gio`),
  KEY `ma_ca` (`ma_ca`),
  CONSTRAINT `khunggio_ibfk_1` FOREIGN KEY (`ma_ca`) REFERENCES `calamviec` (`ma_ca`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.khunggio: ~8 rows (xấp xỉ)
INSERT INTO `khunggio` (`ma_khung_gio`, `ma_ca`, `gio_bat_dau`, `gio_ket_thuc`, `luot_kham_toi_da`) VALUES
	(1, 1, '07:30:00', '08:30:00', 5),
	(2, 1, '08:30:00', '09:30:00', 5),
	(3, 1, '09:30:00', '10:30:00', 5),
	(4, 1, '10:30:00', '11:30:00', 5),
	(5, 2, '13:00:00', '14:00:00', 5),
	(6, 2, '14:00:00', '15:00:00', 5),
	(7, 2, '15:00:00', '16:00:00', 5),
	(8, 2, '16:00:00', '17:00:00', 5);

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.loaidoituongbhyt
CREATE TABLE IF NOT EXISTS `loaidoituongbhyt` (
  `ma_doi_tuong` varchar(2) NOT NULL COMMENT 'Mã 2 ký tự đầu trên thẻ BHYT',
  `ten_doi_tuong` varchar(255) NOT NULL COMMENT 'Tên nhóm đối tượng',
  `muc_huong` int(11) NOT NULL COMMENT 'Ô thứ 2 trên thẻ (1, 2, 3, 4, 5)',
  `ty_le_huong` int(11) NOT NULL COMMENT 'Phần trăm chi trả thực tế (100, 95, 80)',
  PRIMARY KEY (`ma_doi_tuong`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.loaidoituongbhyt: ~43 rows (xấp xỉ)
INSERT INTO `loaidoituongbhyt` (`ma_doi_tuong`, `ten_doi_tuong`, `muc_huong`, `ty_le_huong`) VALUES
	('BT', 'Người hưởng trợ cấp bảo trợ xã hội', 2, 100),
	('CA', 'Sỹ quan, hạ sỹ quan Công an nhân dân', 5, 100),
	('CB', 'Cựu chiến binh', 2, 100),
	('CC', 'Người có công với cách mạng (đặc biệt)', 1, 100),
	('CH', 'Người lao động trong cơ quan nhà nước', 4, 80),
	('CK', 'Người có công với cách mạng (khác)', 2, 100),
	('CN', 'Người thuộc hộ gia đình cận nghèo', 3, 95),
	('CS', 'Công nhân cao su nghỉ việc hưởng trợ cấp', 4, 80),
	('CT', 'Người từ 80 tuổi hưởng trợ cấp tuất hàng tháng', 4, 80),
	('CY', 'Người làm công tác cơ yếu', 5, 100),
	('DK', 'Người sống vùng kinh tế đặc biệt khó khăn', 2, 100),
	('DN', 'Người lao động trong doanh nghiệp', 4, 80),
	('DT', 'Người dân tộc thiểu số vùng khó khăn', 2, 100),
	('GB', 'Người làm nông, lâm, ngư nghiệp mức sống TB', 4, 80),
	('GD', 'Người tham gia BHYT theo hộ gia đình', 4, 80),
	('HC', 'Cán bộ, công chức, viên chức', 4, 80),
	('HD', 'Đại biểu Quốc hội, HĐND các cấp', 4, 80),
	('HG', 'Người đã hiến bộ phận cơ thể', 4, 80),
	('HN', 'Người thuộc hộ gia đình nghèo', 2, 100),
	('HS', 'Học sinh', 4, 80),
	('HT', 'Người hưởng lương hưu, trợ cấp mất sức', 3, 95),
	('HX', 'Người lao động trong hợp tác xã', 4, 80),
	('KC', 'Người tham gia kháng chiến', 2, 100),
	('LS', 'Người nước ngoài học tập tại VN (học bổng NSNN)', 4, 80),
	('MS', 'Người thôi hưởng trợ cấp mất sức lao động', 4, 80),
	('NN', 'Người lao động trong tổ chức nước ngoài', 4, 80),
	('NO', 'Người nghỉ việc hưởng chế độ ốm đau', 4, 80),
	('PV', 'Người phục vụ người có công với cách mạng', 4, 80),
	('QN', 'Sỹ quan, quân nhân chuyên nghiệp', 5, 100),
	('SV', 'Sinh viên', 4, 80),
	('TA', 'Thân nhân của đối tượng CA', 4, 80),
	('TB', 'Người hưởng trợ cấp tai nạn lao động', 4, 80),
	('TC', 'Thân nhân người có công (khác)', 3, 95),
	('TE', 'Trẻ em dưới 6 tuổi', 1, 100),
	('TK', 'Người lao động trong các tổ chức khác', 4, 80),
	('TN', 'Người hưởng trợ cấp thất nghiệp', 4, 80),
	('TQ', 'Thân nhân của đối tượng QN', 4, 80),
	('TS', 'Thân nhân người có công (cha, mẹ, vợ, chồng, con liệt sĩ)', 2, 100),
	('TY', 'Thân nhân của đối tượng CY', 4, 80),
	('XB', 'Cán bộ xã nghỉ việc hưởng trợ cấp', 4, 80),
	('XD', 'Người sống tại xã đảo, huyện đảo', 2, 100),
	('XK', 'Người hoạt động không chuyên trách cấp xã', 4, 80),
	('XN', 'Cán bộ xã nghỉ việc hưởng trợ cấp từ NSNN', 4, 80);

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.luotkham
CREATE TABLE IF NOT EXISTS `luotkham` (
  `ma_luot_kham` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_ho_so` bigint(20) unsigned NOT NULL,
  `ma_bac_si` bigint(20) unsigned DEFAULT NULL,
  `hinh_thuc_kham` enum('BHYT','DichVu') DEFAULT 'DichVu',
  `priority_level` int(11) DEFAULT 4,
  `so_thu_tu` int(11) DEFAULT NULL,
  `thoi_gian_den_kham` datetime NOT NULL,
  `trang_thai` varchar(50) DEFAULT 'cho_thanh_toan',
  `chan_doan` text DEFAULT NULL,
  `qr_token` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`ma_luot_kham`),
  KEY `ma_ho_so` (`ma_ho_so`),
  KEY `ma_bac_si` (`ma_bac_si`),
  CONSTRAINT `luotkham_ibfk_1` FOREIGN KEY (`ma_ho_so`) REFERENCES `hosobenhan` (`ma_ho_so`) ON DELETE CASCADE,
  CONSTRAINT `luotkham_ibfk_2` FOREIGN KEY (`ma_bac_si`) REFERENCES `bacsi` (`ma_bs`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.luotkham: ~29 rows (xấp xỉ)
INSERT INTO `luotkham` (`ma_luot_kham`, `ma_ho_so`, `ma_bac_si`, `hinh_thuc_kham`, `priority_level`, `so_thu_tu`, `thoi_gian_den_kham`, `trang_thai`, `chan_doan`, `qr_token`, `created_at`, `updated_at`) VALUES
	(1, 1, 1, 'DichVu', 4, NULL, '2026-09-20 07:35:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(2, 2, 2, 'DichVu', 4, NULL, '2026-09-20 08:40:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(3, 3, 1, 'DichVu', 2, NULL, '2026-09-20 13:05:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(4, 4, 3, 'DichVu', 4, NULL, '2026-09-21 07:40:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(5, 5, 1, 'DichVu', 4, NULL, '2026-09-21 09:45:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(6, 6, 4, 'DichVu', 4, NULL, '2026-09-21 14:10:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(7, 7, 6, 'DichVu', 3, NULL, '2026-09-22 08:35:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(8, 8, 3, 'DichVu', 4, NULL, '2026-09-22 10:40:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(9, 9, 7, 'DichVu', 4, NULL, '2026-09-22 15:15:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(10, 10, 5, 'DichVu', 4, NULL, '2026-09-23 07:45:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(11, 11, 2, 'DichVu', 1, NULL, '2026-09-23 09:35:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(12, 12, 4, 'DichVu', 4, NULL, '2026-09-23 16:20:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(13, 13, 1, 'DichVu', 4, NULL, '2026-09-24 08:50:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(14, 1, 8, 'DichVu', 4, NULL, '2026-09-24 13:15:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(15, 2, 3, 'DichVu', 4, NULL, '2026-09-25 07:40:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(16, 3, 6, 'DichVu', 4, NULL, '2026-09-25 10:30:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(17, 4, 2, 'DichVu', 4, NULL, '2026-09-26 09:30:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(18, 5, 1, 'DichVu', 4, NULL, '2026-09-26 14:20:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(19, 6, 7, 'DichVu', 4, NULL, '2026-09-26 16:10:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(20, 7, 6, 'DichVu', 4, NULL, '2026-09-27 08:00:00', 'huy', NULL, NULL, NULL, NULL),
	(21, 8, 3, 'DichVu', 4, NULL, '2026-09-28 07:50:00', 'hoan_thanh', NULL, NULL, NULL, NULL),
	(22, 9, 5, 'DichVu', 4, NULL, '2026-09-28 09:40:00', 'cho_kham', NULL, NULL, NULL, NULL),
	(31, 10, 5, 'BHYT', 4, NULL, '2026-11-09 15:00:00', 'dang_kham', NULL, NULL, '2026-11-09 08:55:37', '2026-11-09 09:09:18'),
	(32, 1, 1, 'DichVu', 4, NULL, '2026-11-10 07:30:00', 'da_thanh_toan', NULL, NULL, '2026-11-09 09:12:20', '2026-11-09 09:13:41'),
	(33, 11, 6, 'BHYT', 4, NULL, '2026-11-09 16:00:00', 'hoan_thanh', NULL, NULL, '2026-11-09 09:34:13', '2026-11-09 09:41:07'),
	(41, 6, 2, 'BHYT', 4, NULL, '2026-11-09 13:00:00', 'da_thanh_toan', NULL, NULL, '2026-11-09 11:28:25', '2026-11-09 11:28:34'),
	(45, 27, 1, 'BHYT', 4, NULL, '2026-11-11 07:30:00', 'dang_kham', NULL, NULL, '2026-11-11 02:39:03', '2026-11-11 02:39:42'),
	(46, 2, 2, 'BHYT', 4, NULL, '2026-11-11 07:30:00', 'cho_kham', NULL, 'LKB37C76BE71CE11A2E19476A622668E53', '2026-11-11 02:48:29', '2026-11-11 02:59:55'),
	(47, 1, 4, 'BHYT', 4, NULL, '2026-11-11 07:30:00', 'cho_kham', NULL, 'LKFF1F21647E23E633A0A197BA2E2C2BAD', '2026-11-11 03:00:52', '2026-11-11 03:05:09');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.nhatkyhethong
CREATE TABLE IF NOT EXISTS `nhatkyhethong` (
  `ma_nhat_ky` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_tk` bigint(20) unsigned DEFAULT NULL,
  `hanh_dong` varchar(50) NOT NULL,
  `bang_tac_dong` varchar(50) NOT NULL,
  `du_lieu_cu` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`du_lieu_cu`)),
  `du_lieu_moi` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`du_lieu_moi`)),
  `thoi_gian` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ma_nhat_ky`),
  KEY `ma_tk` (`ma_tk`),
  CONSTRAINT `nhatkyhethong_ibfk_1` FOREIGN KEY (`ma_tk`) REFERENCES `taikhoan` (`ma_tk`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=93 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.nhatkyhethong: ~86 rows (xấp xỉ)
INSERT INTO `nhatkyhethong` (`ma_nhat_ky`, `ma_tk`, `hanh_dong`, `bang_tac_dong`, `du_lieu_cu`, `du_lieu_moi`, `thoi_gian`) VALUES
	(1, 10, 'CREATE', 'LichKham', NULL, '{"ma_lich_dat": 28, "ma_bn": 2, "ma_bs": 8, "trang_thai": "ChoXacNhan"}', '2026-09-28 08:00:00'),
	(2, 10, 'CREATE', 'LichKham', NULL, '{"ma_lich_dat": 29, "ma_bn": 3, "ma_bs": 5, "trang_thai": "ChoXacNhan"}', '2026-09-28 09:00:00'),
	(3, 10, 'CREATE', 'LichKham', NULL, '{"ma_lich_dat": 30, "ma_bn": 4, "ma_bs": 3, "trang_thai": "ChoXacNhan"}', '2026-09-28 10:00:00'),
	(4, 2, 'CREATE', 'PhienKham', NULL, '{"ma_phien_kham": 20, "ma_lich_dat": 21, "trang_thai": "ChoCanLamSang"}', '2026-09-28 08:00:00'),
	(5, 2, 'UPDATE', 'PhienKham', '{"trang_thai": "ChoCanLamSang"}', '{"trang_thai": "HoanThanh", "chan_doan_cuoi_cung": "Viêm kết mạc cấp"}', '2026-09-28 08:30:00'),
	(6, 2, 'CREATE', 'DonThuoc', NULL, '{"ma_don_thuoc": 20, "ma_phien_kham": 20, "tong_tien": 75000}', '2026-09-28 08:30:00'),
	(7, 2, 'CREATE', 'HoaDon', NULL, '{"ma_hoa_don": 20, "tong_cong": 475000, "trang_thai": "ChuaThanhToan"}', '2026-09-28 08:30:00'),
	(8, 10, 'UPDATE', 'HoaDon', '{"trang_thai": "ChuaThanhToan"}', '{"trang_thai": "DaThanhToan", "phuong_thuc": "TienMat"}', '2026-09-28 09:00:00'),
	(9, 10, 'UPDATE', 'LichKham', '{"trang_thai": "ChoThanhToan"}', '{"trang_thai": "HoanThanh"}', '2026-09-28 09:00:00'),
	(10, 2, 'UPDATE', 'Thuoc', '{"so_luong_ton": 2030}', '{"so_luong_ton": 2000}', '2026-09-28 08:30:00'),
	(11, 11, 'UPDATE', 'LichKham', '{"trang_thai": "ChoXacNhan"}', '{"trang_thai": "ChoKham", "thoi_gian_den_quay": "09:40:00"}', '2026-09-28 09:40:00'),
	(12, 2, 'CREATE', 'PhienKham', NULL, '{"ma_phien_kham": 21, "ma_lich_dat": 22, "trang_thai": "ChoCanLamSang"}', '2026-09-28 10:00:00'),
	(13, 1, 'UPDATE', 'TaiKhoan', '{"trang_thai": true}', '{"trang_thai": false}', '2026-09-28 10:30:00'),
	(14, 10, 'CREATE', 'BenhNhan', NULL, '{"ma_bn": 13, "ho_ten": "Trương Văn Khánh", "so_dien_thoai": "0923456789"}', '2026-09-28 11:00:00'),
	(15, 1, 'UPDATE', 'ChuyenKhoa', '{"mo_ta": "Cũ"}', '{"mo_ta": "Khám và điều trị các bệnh lý nội khoa tổng quát"}', '2026-09-28 11:30:00'),
	(16, 1, 'CREATE', 'BacSi', NULL, '{"ma_bs": 8, "ho_ten": "Bùi Văn Sơn", "ma_chuyen_khoa": 8}', '2026-09-28 12:00:00'),
	(17, 10, 'CREATE', 'LichKham', NULL, '{"ma_lich_dat": 25, "ma_bn": 12, "trang_thai": "ChoXacNhan"}', '2026-09-28 13:00:00'),
	(18, 10, 'UPDATE', 'LichKham', '{"trang_thai": "ChoXacNhan"}', '{"trang_thai": "DaHuy"}', '2026-09-28 14:00:00'),
	(19, 11, 'CREATE', 'LichKham', NULL, '{"ma_lich_dat": 26, "ma_bn": 13, "trang_thai": "ChoXacNhan"}', '2026-09-28 15:00:00'),
	(20, 11, 'CREATE', 'LichKham', NULL, '{"ma_lich_dat": 27, "ma_bn": 1, "trang_thai": "ChoXacNhan"}', '2026-09-28 16:00:00'),
	(21, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":10,"ma_bac_si":5,"thoi_gian_den_kham":"2026-11-09 15:00:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-09 15:55:37","created_at":"2026-11-09 15:55:37","ma_luot_kham":31}', '2026-11-09 15:55:37'),
	(22, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":31,"ma_ho_so":10,"ma_bac_si":5,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T08:00:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T08:55:37.000000Z","updated_at":"2026-11-09T08:55:37.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-09 15:56:02"}', '2026-11-09 15:56:02'),
	(23, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":31,"ma_ho_so":10,"ma_bac_si":5,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T08:00:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T08:55:37.000000Z","updated_at":"2026-11-09T08:56:02.000000Z"}', '{"trang_thai":"cho_kham","updated_at":"2026-11-09 16:04:08"}', '2026-11-09 16:04:08'),
	(24, 6, 'CREATE', 'PhienKham', NULL, '{"ma_lich_dat":"31","trang_thai":"ChoCanLamSang","ma_phien_kham":21}', '2026-11-09 16:04:19'),
	(25, 6, 'UPDATE', 'LuotKham', '{"ma_luot_kham":31,"ma_ho_so":10,"ma_bac_si":5,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T08:00:00.000000Z","trang_thai":"cho_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T08:55:37.000000Z","updated_at":"2026-11-09T09:04:08.000000Z"}', '{"trang_thai":"dang_kham","updated_at":"2026-11-09 16:04:19"}', '2026-11-09 16:04:19'),
	(26, 6, 'UPDATE', 'PhienKham', '{"ma_phien_kham":21,"ma_lich_dat":31,"chan_doan_so_bo":null,"chan_doan_cuoi_cung":null,"ghi_chu_y_te":null,"trang_thai":"ChoCanLamSang","ngay_tao":"2026-11-09 16:04:19"}', '{"chan_doan_so_bo":"H\\u1ec7 h\\u00f4 h\\u1ea5p \\u1ed5n \\u0111\\u1ecbnh","chan_doan_cuoi_cung":"T\\u1ed1t"}', '2026-11-09 16:05:31'),
	(27, 6, 'UPDATE', 'PhienKham', '{"ma_phien_kham":21,"ma_lich_dat":31,"chan_doan_so_bo":"H\\u1ec7 h\\u00f4 h\\u1ea5p \\u1ed5n \\u0111\\u1ecbnh","chan_doan_cuoi_cung":"T\\u1ed1t","ghi_chu_y_te":null,"trang_thai":"ChoCanLamSang","ngay_tao":"2026-11-09 16:04:19"}', '{"trang_thai":"ChoThanhToan"}', '2026-11-09 16:05:31'),
	(28, 6, 'UPDATE', 'LuotKham', '{"ma_luot_kham":31,"ma_ho_so":10,"ma_bac_si":5,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T08:00:00.000000Z","trang_thai":"dang_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T08:55:37.000000Z","updated_at":"2026-11-09T09:04:19.000000Z"}', '{"trang_thai":"hoan_tat_hoa_don","updated_at":"2026-11-09 16:05:31"}', '2026-11-09 16:05:31'),
	(29, 6, 'CREATE', 'HoaDon', NULL, '{"ma_phien_kham":21,"tien_kham_benh":0,"tien_dich_vu":400000,"tien_thuoc":0,"tong_cong":400000,"tien_bhyt_tra":320000,"tien_benh_nhan_tra":80000,"trang_thai":"ChuaThanhToan","ngay_tao":"2026-11-09T09:05:31.433189Z","ma_hoa_don":21}', '2026-11-09 16:05:31'),
	(30, 6, 'UPDATE', 'LuotKham', '{"ma_luot_kham":31,"ma_ho_so":10,"ma_bac_si":5,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T08:00:00.000000Z","trang_thai":"hoan_tat_hoa_don","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T08:55:37.000000Z","updated_at":"2026-11-09T09:05:31.000000Z"}', '{"trang_thai":"dang_kham","updated_at":"2026-11-09 16:09:18"}', '2026-11-09 16:09:18'),
	(31, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":1,"ma_bac_si":1,"thoi_gian_den_kham":"2026-11-10 07:30:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"DichVu","updated_at":"2026-11-09 16:12:20","created_at":"2026-11-09 16:12:20","ma_luot_kham":32}', '2026-11-09 16:12:20'),
	(32, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":32,"ma_ho_so":1,"ma_bac_si":1,"hinh_thuc_kham":"DichVu","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-10T00:30:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T09:12:20.000000Z","updated_at":"2026-11-09T09:12:20.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-09 16:13:41"}', '2026-11-09 16:13:41'),
	(33, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":11,"ma_bac_si":6,"thoi_gian_den_kham":"2026-11-09 16:00:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-09 16:34:13","created_at":"2026-11-09 16:34:13","ma_luot_kham":33}', '2026-11-09 16:34:13'),
	(34, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":33,"ma_ho_so":11,"ma_bac_si":6,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T09:00:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T09:34:13.000000Z","updated_at":"2026-11-09T09:34:13.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-09 16:34:53"}', '2026-11-09 16:34:53'),
	(35, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":33,"ma_ho_so":11,"ma_bac_si":6,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T09:00:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T09:34:13.000000Z","updated_at":"2026-11-09T09:34:53.000000Z"}', '{"trang_thai":"cho_kham","updated_at":"2026-11-09 16:35:28"}', '2026-11-09 16:35:28'),
	(36, 7, 'CREATE', 'PhienKham', NULL, '{"ma_lich_dat":"33","trang_thai":"ChoCanLamSang","ma_phien_kham":22}', '2026-11-09 16:36:39'),
	(37, 7, 'UPDATE', 'LuotKham', '{"ma_luot_kham":33,"ma_ho_so":11,"ma_bac_si":6,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T09:00:00.000000Z","trang_thai":"cho_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T09:34:13.000000Z","updated_at":"2026-11-09T09:35:28.000000Z"}', '{"trang_thai":"dang_kham","updated_at":"2026-11-09 16:36:39"}', '2026-11-09 16:36:39'),
	(38, 7, 'UPDATE', 'PhienKham', '{"ma_phien_kham":22,"ma_lich_dat":33,"chan_doan_so_bo":null,"chan_doan_cuoi_cung":null,"ghi_chu_y_te":null,"trang_thai":"ChoCanLamSang","ngay_tao":"2026-11-09 16:36:39"}', '{"trang_thai":"ChoThanhToan"}', '2026-11-09 16:38:52'),
	(39, 7, 'UPDATE', 'LuotKham', '{"ma_luot_kham":33,"ma_ho_so":11,"ma_bac_si":6,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T09:00:00.000000Z","trang_thai":"dang_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T09:34:13.000000Z","updated_at":"2026-11-09T09:36:39.000000Z"}', '{"trang_thai":"hoan_tat_hoa_don","updated_at":"2026-11-09 16:38:52"}', '2026-11-09 16:38:52'),
	(40, 7, 'CREATE', 'HoaDon', NULL, '{"ma_phien_kham":22,"tien_kham_benh":0,"tien_dich_vu":900000,"tien_thuoc":0,"tong_cong":900000,"tien_bhyt_tra":855000,"tien_benh_nhan_tra":45000,"trang_thai":"ChuaThanhToan","ngay_tao":"2026-11-09T09:38:52.075657Z","ma_hoa_don":22}', '2026-11-09 16:38:52'),
	(41, NULL, 'UPDATE', 'HoaDon', '"{\\"trang_thai\\":\\"ChuaThanhToan\\"}"', '"{\\"trang_thai\\":\\"DaThanhToan\\",\\"phuong_thuc\\":\\"VNPay\\"}"', '2026-11-09 16:41:07'),
	(48, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":6,"ma_bac_si":2,"thoi_gian_den_kham":"2026-11-09 13:00:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-09 18:28:25","created_at":"2026-11-09 18:28:25","ma_luot_kham":41}', '2026-11-09 18:28:25'),
	(49, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":41,"ma_ho_so":6,"ma_bac_si":2,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T06:00:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T11:28:25.000000Z","updated_at":"2026-11-09T11:28:25.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-09 18:28:34"}', '2026-11-09 18:28:34'),
	(50, 10, 'CREATE', 'BenhNhan', NULL, '{"ho_ten":"B\\u00f9i Quang TI\\u1ebfn","ngay_sinh":"2005-11-11 00:00:00","gioi_tinh":1,"so_dien_thoai":"0921247254","email":"tienchusi@gmail.com","cccd":"079205009467","dia_chi":"243 Phan \\u0110\\u00ecnh Ph\\u00f9ng","tien_su_benh":null,"di_ung":null,"nhom_mau":"B","ma_benh_nhan":26}', '2026-11-09 19:19:46'),
	(51, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":25,"ma_bac_si":11,"thoi_gian_den_kham":"2026-11-09 13:00:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"DichVu","updated_at":"2026-11-09 19:22:13","created_at":"2026-11-09 19:22:13","ma_luot_kham":42}', '2026-11-09 19:22:13'),
	(52, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":25,"ma_bac_si":3,"thoi_gian_den_kham":"2026-11-09 07:30:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-09 19:54:37","created_at":"2026-11-09 19:54:37","ma_luot_kham":43}', '2026-11-09 19:54:37'),
	(53, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":43,"ma_ho_so":25,"ma_bac_si":3,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T00:30:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T12:54:37.000000Z","updated_at":"2026-11-09T12:54:37.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-09 19:55:06"}', '2026-11-09 19:55:06'),
	(54, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":43,"ma_ho_so":25,"ma_bac_si":3,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T00:30:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T12:54:37.000000Z","updated_at":"2026-11-09T12:55:06.000000Z"}', '{"trang_thai":"cho_kham","updated_at":"2026-11-09 19:55:58"}', '2026-11-09 19:55:58'),
	(55, 4, 'CREATE', 'PhienKham', NULL, '{"ma_lich_dat":"43","trang_thai":"ChoCanLamSang","ma_phien_kham":26}', '2026-11-09 19:56:21'),
	(56, 4, 'UPDATE', 'LuotKham', '{"ma_luot_kham":43,"ma_ho_so":25,"ma_bac_si":3,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T00:30:00.000000Z","trang_thai":"cho_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T12:54:37.000000Z","updated_at":"2026-11-09T12:55:58.000000Z"}', '{"trang_thai":"dang_kham","updated_at":"2026-11-09 19:56:21"}', '2026-11-09 19:56:21'),
	(57, 4, 'UPDATE', 'PhienKham', '{"ma_phien_kham":26,"ma_lich_dat":43,"chan_doan_so_bo":null,"chan_doan_cuoi_cung":null,"ghi_chu_y_te":null,"trang_thai":"ChoCanLamSang","ngay_tao":"2026-11-09 19:56:21"}', '{"trang_thai":"ChoThanhToan"}', '2026-11-09 19:56:50'),
	(58, 4, 'UPDATE', 'LuotKham', '{"ma_luot_kham":43,"ma_ho_so":25,"ma_bac_si":3,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T00:30:00.000000Z","trang_thai":"dang_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T12:54:37.000000Z","updated_at":"2026-11-09T12:56:21.000000Z"}', '{"trang_thai":"hoan_tat_hoa_don","updated_at":"2026-11-09 19:56:50"}', '2026-11-09 19:56:50'),
	(59, 4, 'CREATE', 'HoaDon', NULL, '{"ma_phien_kham":26,"tien_kham_benh":0,"tien_dich_vu":250000,"tien_thuoc":0,"tong_cong":250000,"tien_bhyt_tra":250000,"tien_benh_nhan_tra":0,"trang_thai":"ChuaThanhToan","ngay_tao":"2026-11-09T12:56:50.538693Z","ma_hoa_don":24}', '2026-11-09 19:56:50'),
	(60, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":25,"ma_bac_si":1,"thoi_gian_den_kham":"2026-11-09 16:00:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-09 20:38:41","created_at":"2026-11-09 20:38:41","ma_luot_kham":44}', '2026-11-09 20:38:41'),
	(61, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":44,"ma_ho_so":25,"ma_bac_si":1,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T09:00:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T13:38:41.000000Z","updated_at":"2026-11-09T13:38:41.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-09 20:39:01"}', '2026-11-09 20:39:01'),
	(62, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":44,"ma_ho_so":25,"ma_bac_si":1,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T09:00:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T13:38:41.000000Z","updated_at":"2026-11-09T13:39:01.000000Z"}', '{"trang_thai":"cho_kham","updated_at":"2026-11-09 20:39:16"}', '2026-11-09 20:39:16'),
	(63, 2, 'CREATE', 'PhienKham', NULL, '{"ma_lich_dat":"44","trang_thai":"ChoCanLamSang","ma_phien_kham":27}', '2026-11-09 20:39:22'),
	(64, 2, 'UPDATE', 'LuotKham', '{"ma_luot_kham":44,"ma_ho_so":25,"ma_bac_si":1,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-09T09:00:00.000000Z","trang_thai":"cho_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-09T13:38:41.000000Z","updated_at":"2026-11-09T13:39:16.000000Z"}', '{"trang_thai":"dang_kham","updated_at":"2026-11-09 20:39:22"}', '2026-11-09 20:39:22'),
	(65, 10, 'CREATE', 'BenhNhan', NULL, '{"ho_ten":"B\\u00f9i Quang Ti\\u1ebfn","ngay_sinh":"2005-11-11 00:00:00","gioi_tinh":1,"so_dien_thoai":"0961521561","email":null,"cccd":"179205009478","dia_chi":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","ma_benh_nhan":27}', '2026-11-10 17:07:09'),
	(66, 10, 'DELETE', 'BenhNhan', '{"ma_benh_nhan":27,"ma_tk":null,"ho_ten":"B\\u00f9i Quang Ti\\u1ebfn","ngay_sinh":"2005-11-10T17:00:00.000000Z","gioi_tinh":1,"so_dien_thoai":"0961521561","email":null,"cccd":"179205009478","dia_chi":null,"nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', NULL, '2026-11-10 17:07:17'),
	(67, 10, 'CREATE', 'BenhNhan', NULL, '{"ho_ten":"B\\u00f9i Quang Ti\\u1ebfn","ngay_sinh":"2005-11-11 00:00:00","gioi_tinh":1,"so_dien_thoai":"0961521561","email":null,"cccd":"079205009478","dia_chi":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","ma_benh_nhan":28}', '2026-11-10 17:22:29'),
	(68, 10, 'UPDATE', 'BenhNhan', '{"ma_benh_nhan":28,"ma_tk":null,"ho_ten":"B\\u00f9i Quang Ti\\u1ebfn","ngay_sinh":"2005-11-10T17:00:00.000000Z","gioi_tinh":1,"so_dien_thoai":"0961521561","email":null,"cccd":"079205009478","dia_chi":null,"nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', '{"email":"buitien111105@gmail.com","dia_chi":"15 T\\u00e2n Th\\u1eddi"}', '2026-11-10 17:28:15'),
	(69, 10, 'CREATE', 'BenhNhan', NULL, '{"ho_ten":"Ch\\u00e2u Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521562","email":null,"cccd":"079205009477","dia_chi":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","ma_benh_nhan":29}', '2026-11-10 17:30:49'),
	(70, 10, 'DELETE', 'BenhNhan', '{"ma_benh_nhan":29,"ma_tk":null,"ho_ten":"Ch\\u00e2u Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521562","email":null,"cccd":"079205009477","dia_chi":null,"nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', NULL, '2026-11-10 17:31:01'),
	(71, 10, 'CREATE', 'BenhNhan', NULL, '{"ho_ten":"\\u0110\\u1eb7ng Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521562","email":null,"cccd":"079205009477","dia_chi":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","ma_benh_nhan":30}', '2026-11-10 17:36:32'),
	(72, 10, 'DELETE', 'BenhNhan', '{"ma_benh_nhan":30,"ma_tk":null,"ho_ten":"\\u0110\\u1eb7ng Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521562","email":null,"cccd":"079205009477","dia_chi":null,"nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', NULL, '2026-11-10 17:37:01'),
	(73, 10, 'CREATE', 'BenhNhan', NULL, '{"ho_ten":"\\u0110\\u1eb7ng Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521563","email":null,"cccd":"079205009479","dia_chi":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","ma_benh_nhan":31}', '2026-11-10 17:37:34'),
	(74, 10, 'DELETE', 'BenhNhan', '{"ma_benh_nhan":31,"ma_tk":null,"ho_ten":"\\u0110\\u1eb7ng Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521563","email":null,"cccd":"079205009479","dia_chi":null,"nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', NULL, '2026-11-10 17:38:35'),
	(75, 10, 'CREATE', 'BenhNhan', NULL, '{"ho_ten":"\\u0110\\u1eb7ng Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521562","email":null,"cccd":"079222009474","dia_chi":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890111","ma_benh_nhan":32}', '2026-11-10 17:40:53'),
	(76, 10, 'UPDATE', 'BenhNhan', '{"ma_benh_nhan":32,"ma_tk":null,"ho_ten":"\\u0110\\u1eb7ng Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521562","email":null,"cccd":"079222009474","dia_chi":null,"nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890111","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', '{"cccd":"079232009474"}', '2026-11-10 17:41:37'),
	(77, 10, 'DELETE', 'BenhNhan', '{"ma_benh_nhan":32,"ma_tk":null,"ho_ten":"\\u0110\\u1eb7ng Th\\u1ecb","ngay_sinh":null,"gioi_tinh":1,"so_dien_thoai":"0961521562","email":null,"cccd":"079232009474","dia_chi":null,"nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890111","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', NULL, '2026-11-10 17:46:33'),
	(78, 10, 'UPDATE', 'BenhNhan', '{"ma_benh_nhan":28,"ma_tk":null,"ho_ten":"B\\u00f9i Quang Ti\\u1ebfn","ngay_sinh":"2005-11-10T17:00:00.000000Z","gioi_tinh":1,"que_quan":"Th\\u00e0nh ph\\u1ed1 H\\u1ed3 Ch\\u00ed Minh","so_dien_thoai":"0961521561","email":"buiquangtien@gmail.com","cccd":"079205009478","dia_chi":"15 T\\u00e2n Th\\u1eddi","nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"DN4794567890112","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', '{"ma_bhyt":"SV4794567890112"}', '2026-11-11 09:35:49'),
	(79, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":27,"ma_bac_si":1,"thoi_gian_den_kham":"2026-11-11 07:30:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-11 09:39:03","created_at":"2026-11-11 09:39:03","ma_luot_kham":45}', '2026-11-11 09:39:03'),
	(80, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":45,"ma_ho_so":27,"ma_bac_si":1,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-11T02:39:03.000000Z","updated_at":"2026-11-11T02:39:03.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-11 09:39:12"}', '2026-11-11 09:39:12'),
	(81, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":45,"ma_ho_so":27,"ma_bac_si":1,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-11T02:39:03.000000Z","updated_at":"2026-11-11T02:39:12.000000Z"}', '{"trang_thai":"cho_kham","updated_at":"2026-11-11 09:39:15"}', '2026-11-11 09:39:15'),
	(82, 2, 'CREATE', 'PhienKham', NULL, '{"ma_lich_dat":"45","trang_thai":"ChoCanLamSang","ma_phien_kham":28}', '2026-11-11 09:39:42'),
	(83, 2, 'UPDATE', 'LuotKham', '{"ma_luot_kham":45,"ma_ho_so":27,"ma_bac_si":1,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"cho_kham","chan_doan":null,"qr_token":null,"created_at":"2026-11-11T02:39:03.000000Z","updated_at":"2026-11-11T02:39:15.000000Z"}', '{"trang_thai":"dang_kham","updated_at":"2026-11-11 09:39:42"}', '2026-11-11 09:39:42'),
	(84, 10, 'UPDATE', 'BenhNhan', '{"ma_benh_nhan":28,"ma_tk":null,"ho_ten":"B\\u00f9i Quang Ti\\u1ebfn","ngay_sinh":"2005-11-10T17:00:00.000000Z","gioi_tinh":1,"que_quan":"Th\\u00e0nh ph\\u1ed1 H\\u1ed3 Ch\\u00ed Minh","so_dien_thoai":"0961521561","email":"buiquangtien@gmail.com","cccd":"079205009478","dia_chi":"15 T\\u00e2n Th\\u1eddi","nguoi_lien_he_khan_cap":null,"tien_su_benh":null,"di_ung":null,"nhom_mau":null,"ma_bhyt":"SV4794567890112","muc_huong_bhyt":null,"ngay_het_han_bhyt":null}', '{"nhom_mau":"B"}', '2026-11-11 09:40:53'),
	(85, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":2,"ma_bac_si":2,"thoi_gian_den_kham":"2026-11-11 07:30:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-11 09:48:29","created_at":"2026-11-11 09:48:29","ma_luot_kham":46}', '2026-11-11 09:48:29'),
	(86, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":46,"ma_ho_so":2,"ma_bac_si":2,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-11T02:48:29.000000Z","updated_at":"2026-11-11T02:48:29.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-11 09:48:35"}', '2026-11-11 09:48:35'),
	(87, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":46,"ma_ho_so":2,"ma_bac_si":2,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-11T02:48:29.000000Z","updated_at":"2026-11-11T02:48:35.000000Z"}', '{"qr_token":"LKB37C76BE71CE11A2E19476A622668E53","updated_at":"2026-11-11 09:52:09"}', '2026-11-11 09:52:09'),
	(88, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":46,"ma_ho_so":2,"ma_bac_si":2,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":"LKB37C76BE71CE11A2E19476A622668E53","created_at":"2026-11-11T02:48:29.000000Z","updated_at":"2026-11-11T02:52:09.000000Z"}', '{"trang_thai":"cho_kham","updated_at":"2026-11-11 09:59:55"}', '2026-11-11 09:59:55'),
	(89, 10, 'CREATE', 'LuotKham', NULL, '{"ma_ho_so":1,"ma_bac_si":4,"thoi_gian_den_kham":"2026-11-11 07:30:00","trang_thai":"cho_thanh_toan","hinh_thuc_kham":"BHYT","updated_at":"2026-11-11 10:00:52","created_at":"2026-11-11 10:00:52","ma_luot_kham":47}', '2026-11-11 10:00:52'),
	(90, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":47,"ma_ho_so":1,"ma_bac_si":4,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"cho_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-11T03:00:52.000000Z","updated_at":"2026-11-11T03:00:52.000000Z"}', '{"trang_thai":"da_thanh_toan","updated_at":"2026-11-11 10:01:02"}', '2026-11-11 10:01:02'),
	(91, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":47,"ma_ho_so":1,"ma_bac_si":4,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":null,"created_at":"2026-11-11T03:00:52.000000Z","updated_at":"2026-11-11T03:01:02.000000Z"}', '{"qr_token":"LKFF1F21647E23E633A0A197BA2E2C2BAD","updated_at":"2026-11-11 10:01:12"}', '2026-11-11 10:01:12'),
	(92, 10, 'UPDATE', 'LuotKham', '{"ma_luot_kham":47,"ma_ho_so":1,"ma_bac_si":4,"hinh_thuc_kham":"BHYT","priority_level":4,"so_thu_tu":null,"thoi_gian_den_kham":"2026-11-11T00:30:00.000000Z","trang_thai":"da_thanh_toan","chan_doan":null,"qr_token":"LKFF1F21647E23E633A0A197BA2E2C2BAD","created_at":"2026-11-11T03:00:52.000000Z","updated_at":"2026-11-11T03:01:12.000000Z"}', '{"trang_thai":"cho_kham","updated_at":"2026-11-11 10:05:09"}', '2026-11-11 10:05:09');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.phienkham
CREATE TABLE IF NOT EXISTS `phienkham` (
  `ma_phien_kham` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_lich_dat` bigint(20) unsigned NOT NULL,
  `chan_doan_so_bo` text DEFAULT NULL,
  `chan_doan_cuoi_cung` text DEFAULT NULL,
  `ghi_chu_y_te` text DEFAULT NULL,
  `trang_thai` varchar(50) DEFAULT 'ChoCanLamSang',
  `ngay_tao` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ma_phien_kham`),
  UNIQUE KEY `ma_lich_dat` (`ma_lich_dat`),
  CONSTRAINT `phienkham_ibfk_1` FOREIGN KEY (`ma_lich_dat`) REFERENCES `luotkham` (`ma_luot_kham`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.phienkham: ~21 rows (xấp xỉ)
INSERT INTO `phienkham` (`ma_phien_kham`, `ma_lich_dat`, `chan_doan_so_bo`, `chan_doan_cuoi_cung`, `ghi_chu_y_te`, `trang_thai`, `ngay_tao`) VALUES
	(1, 1, 'Đau đầu, chóng mặt nhẹ', 'Tăng huyết áp độ 1', 'Bệnh nhân cần kiểm tra huyết áp hàng ngày', 'HoanThanh', '2026-09-20 08:00:00'),
	(2, 2, 'Đau ngực khi vận động', 'Đau thắt ngực ổn định', 'Tránh vận động mạnh', 'HoanThanh', '2026-09-20 09:00:00'),
	(3, 3, 'Mệt mỏi, chán ăn', 'Suy nhược cơ thể, thiếu máu nhẹ', 'Bổ sung sắt và vitamin', 'HoanThanh', '2026-09-20 14:00:00'),
	(4, 4, 'Nổi mẩn đỏ, ngứa', 'Viêm da dị ứng tiếp xúc', 'Tránh xa dị nguyên', 'HoanThanh', '2026-09-21 08:00:00'),
	(5, 5, 'Đau bụng âm ỉ', 'Viêm dạ dày cấp tính', 'Kiêng rượu bia, đồ cay nóng', 'HoanThanh', '2026-09-21 10:00:00'),
	(6, 6, 'Sốt nhẹ, ho khan', 'Cảm cúm thông thường', 'Nghỉ ngơi, uống nhiều nước', 'HoanThanh', '2026-09-21 14:30:00'),
	(7, 7, 'Đau nhức khớp gối', 'Thoái hóa khớp gối độ 2', 'Hạn chế leo cầu thang', 'HoanThanh', '2026-09-22 09:00:00'),
	(8, 8, 'Ngứa da đầu', 'Viêm da tiết bã nhờn', 'Gội đầu bằng dầu gội trị nấm', 'HoanThanh', '2026-09-22 11:00:00'),
	(9, 9, 'Chậm kinh, đau bụng dưới', 'Rối loạn kinh nguyệt do stress', 'Nghỉ ngơi, tránh căng thẳng', 'HoanThanh', '2026-09-22 15:30:00'),
	(10, 10, 'Đau họng, khó nuốt', 'Viêm họng cấp do vi khuẩn', 'Súc miệng nước muối ấm', 'HoanThanh', '2026-09-23 08:00:00'),
	(11, 11, 'Huyết áp cao 160/95', 'Tăng huyết áp độ 2', 'Uống thuốc đều đặn hàng ngày', 'HoanThanh', '2026-09-23 10:00:00'),
	(12, 12, 'Trẻ sốt cao, quấy khóc', 'Sốt virus ở trẻ nhỏ', 'Cho trẻ uống nhiều nước', 'HoanThanh', '2026-09-23 16:30:00'),
	(13, 13, 'Đau lưng sau khi khuân vác', 'Căng cơ lưng cấp tính', 'Nghỉ ngơi, tránh mang vác nặng', 'HoanThanh', '2026-09-24 09:00:00'),
	(14, 14, 'Mờ mắt khi đọc sách', 'Cận thị nhẹ 2 độ', 'Đeo kính đúng độ', 'HoanThanh', '2026-09-24 13:30:00'),
	(15, 15, 'Da mặt nổi mụn nhiều', 'Mụn trứng cá mức độ trung bình', 'Rửa mặt 2 lần/ngày', 'HoanThanh', '2026-09-25 08:00:00'),
	(16, 16, 'Đau khớp ngón tay', 'Viêm khớp dạng thấp giai đoạn đầu', 'Tập vật lý trị liệu', 'HoanThanh', '2026-09-25 10:30:00'),
	(17, 17, 'Hồi hộp, đánh trống ngực', 'Rối loạn lo âu', 'Tập thở sâu, thiền', 'HoanThanh', '2026-09-26 09:30:00'),
	(18, 18, 'Đau bụng, tiêu chảy', 'Rối loạn tiêu hóa do thức ăn', 'Ăn thức ăn dễ tiêu', 'HoanThanh', '2026-09-26 14:30:00'),
	(19, 19, 'Khí hư bất thường', 'Viêm âm đạo do nấm Candida', 'Giữ vệ sinh sạch sẽ', 'HoanThanh', '2026-09-26 16:30:00'),
	(20, 21, 'Đau mắt đỏ', 'Viêm kết mạc cấp', 'Nhỏ thuốc theo đơn', 'HoanThanh', '2026-09-28 08:00:00'),
	(21, 31, 'Hệ hô hấp ổn định', 'Tốt', NULL, 'ChoThanhToan', '2026-11-09 16:04:19'),
	(22, 33, NULL, NULL, NULL, 'HoanThanh', '2026-11-09 16:36:39'),
	(28, 45, NULL, NULL, NULL, 'ChoCanLamSang', '2026-11-11 09:39:42');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.taikhoan
CREATE TABLE IF NOT EXISTS `taikhoan` (
  `ma_tk` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_dang_nhap` varchar(50) NOT NULL,
  `mat_khau` varchar(255) NOT NULL,
  `ho_ten` varchar(100) DEFAULT NULL,
  `vai_tro` enum('QuanTri','BacSi','LeTan','BenhNhan') NOT NULL,
  `trang_thai` tinyint(1) DEFAULT 1,
  `ngay_tao` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ma_tk`),
  UNIQUE KEY `ten_dang_nhap` (`ten_dang_nhap`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.taikhoan: ~41 rows (xấp xỉ)
INSERT INTO `taikhoan` (`ma_tk`, `ten_dang_nhap`, `mat_khau`, `ho_ten`, `vai_tro`, `trang_thai`, `ngay_tao`) VALUES
	(1, 'admin', '$2y$12$/7jw/m2NvTr3PslrKgSw0OsijD7Gh9XKt.hIrEFNaYXbuvPkEHW6u', 'Quản trị viên', 'QuanTri', 1, '2026-11-09 15:31:22'),
	(2, 'bs.hoangtuan', '$2y$12$UIYbsv/tSiMGiODQ3ZJ.Ue2mbWlkU.VZ08H4IZ/p.Pi6esHsLQeBC', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(3, 'bs.mailan', '$2y$12$u0d5IS0q64UWmkt8lgKt..KspHojZr2Av2YzjyRIJTfPpG4TS2QbG', 'Nguyễn Thị Mai Lan', 'BacSi', 1, '2026-11-09 15:31:22'),
	(4, 'bs.quockhanh', '$2y$12$SSiVOwTZficrH9rAbE6.V.jjycuerNjGnAQhLzHCRbFqFvXtDGLUy', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(5, 'bs.thuhang', '$2y$12$GUMift6rF8KMxYga9PJ1pOSPbmJQxtlFyvtDio33NX4LA0iqFpD8i', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(6, 'bs.ducthanh', '$2y$12$CkQluZvXElLQdTFqm5qI4uarqrW/Q8tW6pYYcEYwqOWQGsU2GfE.y', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(7, 'bs.minhtam', '$2y$12$UaC4SCrWCm1Jzg3/4t8yz.P/Ei5q6nm4jvXTySOPRigFOYpnVWfpS', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(8, 'bs.thaovy', '$2y$12$lUkn8thZjfed6gfBZ53uu.TPN9qvfcTHltbgeGyaZUoOAzF71u.62', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(9, 'bs.vanson', '$2y$12$sNVbnthMaxc6lfugEwvseOKeo5JHeLyxmhRnhGQPjKrGTEV9JOTGq', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(10, 'letan.lan', '$2y$12$l49kSp4kvs/OBEwfPGTMlOAJMpdkqIwAPkf5F3UJeoiXkNuhzFfeK', 'Lê Thị Lan', 'LeTan', 1, '2026-11-09 15:31:22'),
	(11, 'letan.huong', '$2y$12$TmRHRZA/HHU/z9UXBEQVreV3XCyjWSEldIG3pXrwm8zk5Jt4TDkBa', 'Trần Thị Hương', 'LeTan', 1, '2026-11-09 15:31:22'),
	(12, 'letan.thao', '$2y$12$b95jRa29M7YHFhiQLGAp.uEbvrhCWJMsSgMzOy9tlF/Ed5UnOF7ua', NULL, 'LeTan', 1, '2026-11-09 15:31:22'),
	(13, 'bn.hoangphuc', '$2y$12$7vrS2wCTMHHzRC3coNHGde2pbkWeuo7vho347ZefPyr3I8hH.31vi', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(14, 'bn.kimoanh', '$2y$12$aHpvVmIwqdB7Z2cQ6Co39.bPSg1nw7G3jm3lIlNjrm6er4UUjwkMa', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(15, 'bn.quocbao', '$2y$12$acaRRzz03s.lVgWQDeK5huWpg5K00MWwZK9T49jXd5JZcG4/Gu64a', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(16, 'bn.ngocdiem', '$2y$12$Dl9ZcCy0/4SrG78rE7jZS.Qx2a2VNTA0CQi7tN5wKd6ZrTHC3r6o2', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(17, 'bn.duchuy', '$2y$12$P4b3ApIJ8H00B96BvgNMBeK.d6sJQQR1TcAW2BabBFxfnRPVC.TXu', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(18, 'bn.anhtuyet', '$2y$12$6qgA.9fx7VDXyQuk7gT9xuJmjpkrXDlCj7v5PuDEOfxdtSemvVcwS', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(19, 'bn.xuantruong', '$2y$12$NuIiRX7KN1cc0QfejUkIN.6Lui86lqntSa2K3bcO/vqngnETUZYQi', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(20, 'bn.thanhha', '$2y$12$wQfZpDsHtyV9VDpI7wcEieQUsAkYFM.uJrkkcC7bYvHUP.aR5zZSi', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(21, 'bn.minhkhue', '$2y$12$zEmla9/mtjWkfcsCGWBL3eUd8/OiNKtmgoATy4j7FHOlqI9cl/uIS', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(22, 'bn.gialinh', '$2y$12$xQpW2s06uGVmbh0Hd2EaJevKKznlvS.zfGapNMwswW7XY7s7AQDHu', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(23, 'bn.trongnghia', '$2y$12$d2R.7ZSoN21QUXRJ6XfvBeL1yDgaL1.jN5yMs5yvu60wsr0.q5KkW', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(24, 'bn.baongoc', '$2y$12$lEkRXbZcX0OtH8kV9ISUp.K0ujUyjjLkAyGzg5UzebpRjEfuhPLYK', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(25, 'bn.vankhanh', '$2y$12$4FRhuxQYPcFsQNUU14CcU.6KdTmH04Vqszjjcaexr5vuduBcyilDO', NULL, 'BenhNhan', 1, '2026-11-09 15:31:22'),
	(26, 'bs.vantri', '$2y$12$xCZdQs7gp8.cmJy0OT6ryOfUdwzGFZMmX2KT1FDsJNPQEWBU8j35G', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(27, 'bs.thuthuy', '$2y$12$iOaG22R3frGeWFzaWJw08ug1JOOOlK2wweNQOmnSzc6cHng7ujdWS', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(28, 'bs.nguyenvinh', '$2y$12$hx8azXzp1Bpa5KI8iW81TeUl.HSAORQzWVIIu4LMnxtUd.hLmDRzC', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(29, 'bs.huynhtri', '$2y$12$MbtbOiqnGW8ulPGh5lbw8.dtN2l0v/YVtLRJ1x3u11fAHHaEKjftm', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(30, 'bs.vanthanh', '$2y$12$aitHdjMgeXlFyYQNWbapmOIJHjRxb9H2sUViGc1pC8k84Zg.oumDa', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(31, 'bs.thiphuong', '$2y$12$EbATa5ECk9bEkMkClrH9..5edhNfK0ENFldQ028kYtqZdYuHDyhBi', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(32, 'bs.anhtuan', '$2y$12$JaHqj4EjXlcccvfyyRwZSOCDc0/v7NAHaqLnPgO//dVK5EV61gD1e', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(33, 'bs.vancam', '$2y$12$/lusWXexbYlwZJHnwOgir.UvpoMmTHeEl3VmP1hfcM1vetC4CIM9W', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(34, 'bs.ngocdinh', '$2y$12$6ar8qikZa6RiD.xg3L9gtea1oXnSEdiTtUSPOZQY3iWxnkVuXh8zC', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(35, 'bs.viethong', '$2y$12$YFRcF5S2A3THyHvcGX/4C.RXF.szp0txdIrhzaQXtq/GINwG/cX8.', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(36, 'bs.anhthu', '$2y$12$W5Up22nJmQeawXw8MwKxSenbMLjdp40Gl4Zt34NH4VE4zv.UW/Q8e', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(37, 'bs.xuanson', '$2y$12$b16bArLgJ84DNJonaFJVv.YFPbUJcEowzTD5yaVrZv/8qp4E61rBK', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(38, 'bs.ngoclan', '$2y$12$9gHZ7l.HY2AO0BZ/lr4d0uGn9BKsQeLh9AQTMSwPKSmQvZX0vTlkK', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(39, 'bs.quangthanh', '$2y$12$0HPzmpt58zlXsdAUklxjGOWN1VfNESFsn/r5xArkhT5ypVkZR.ytS', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(40, 'bs.nhuhon', '$2y$12$LV0NxAlIRuNpfCCdH3hMH..0lbYc3FWf7ViVBTP.S0xCDLiMJs8a2', NULL, 'BacSi', 1, '2026-11-09 15:31:22'),
	(41, 'bs.phuongthu', '$2y$12$uL/YCADm16iOm10.jchrduO3EPlJrU324kaAc9olTikuVrwZNc0Z2', NULL, 'BacSi', 1, '2026-11-09 15:31:22');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.tinhthanh
CREATE TABLE IF NOT EXISTS `tinhthanh` (
  `ma_tinh` varchar(2) NOT NULL COMMENT 'Mã tỉnh/thành (01-98)',
  `ten_tinh` varchar(100) NOT NULL COMMENT 'Tên tỉnh/thành phố',
  `loai` varchar(20) DEFAULT NULL COMMENT 'ThanhPho / Tinh / DacBiet',
  `ghi_chu` text DEFAULT NULL COMMENT 'Ghi chú sáp nhập (nếu có)',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ma_tinh`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.tinhthanh: ~36 rows (xấp xỉ)
INSERT INTO `tinhthanh` (`ma_tinh`, `ten_tinh`, `loai`, `ghi_chu`, `created_at`, `updated_at`) VALUES
	('01', 'Thành phố Hà Nội', 'ThanhPho', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('04', 'Tỉnh Cao Bằng', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('08', 'Tỉnh Tuyên Quang', 'Tinh', 'Sáp nhập Hà Giang + Tuyên Quang', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('11', 'Tỉnh Điện Biên', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('12', 'Tỉnh Lai Châu', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('14', 'Tỉnh Sơn La', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('15', 'Tỉnh Lào Cai', 'Tinh', 'Sáp nhập Lào Cai + Yên Bái', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('19', 'Tỉnh Thái Nguyên', 'Tinh', 'Sáp nhập Thái Nguyên + Bắc Kạn', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('20', 'Tỉnh Lạng Sơn', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('22', 'Tỉnh Quảng Ninh', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('24', 'Tỉnh Bắc Ninh', 'Tinh', 'Sáp nhập Bắc Ninh + Bắc Giang', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('25', 'Tỉnh Phú Thọ', 'Tinh', 'Sáp nhập Hòa Bình + Vĩnh Phúc + Phú Thọ', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('31', 'Thành phố Hải Phòng', 'ThanhPho', 'Sáp nhập Hải Phòng + Hải Dương', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('33', 'Tỉnh Hưng Yên', 'Tinh', 'Sáp nhập Hưng Yên + Thái Bình', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('37', 'Tỉnh Ninh Bình', 'Tinh', 'Sáp nhập Hà Nam + Nam Định + Ninh Bình', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('38', 'Tỉnh Thanh Hóa', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('40', 'Tỉnh Nghệ An', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('42', 'Tỉnh Hà Tĩnh', 'Tinh', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('44', 'Tỉnh Quảng Trị', 'Tinh', 'Sáp nhập Quảng Bình + Quảng Trị', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('46', 'Thành phố Huế', 'ThanhPho', NULL, '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('48', 'Thành phố Đà Nẵng', 'ThanhPho', 'Sáp nhập Quảng Nam + Đà Nẵng', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('51', 'Tỉnh Quảng Ngãi', 'Tinh', 'Sáp nhập Kon Tum + Quảng Ngãi', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('52', 'Tỉnh Gia Lai', 'Tinh', 'Sáp nhập Gia Lai + Bình Định', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('56', 'Tỉnh Khánh Hòa', 'Tinh', 'Sáp nhập Khánh Hòa + Ninh Thuận', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('66', 'Tỉnh Đắk Lắk', 'Tinh', 'Sáp nhập Đắk Lắk + Phú Yên', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('68', 'Tỉnh Lâm Đồng', 'Tinh', 'Sáp nhập Lâm Đồng + Đắk Nông + Bình Thuận', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('75', 'Tỉnh Đồng Nai', 'Tinh', 'Sáp nhập Đồng Nai + Bình Phước', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('79', 'Thành phố Hồ Chí Minh', 'ThanhPho', 'Sáp nhập TP.HCM + Bình Dương + Bà Rịa - Vũng Tàu', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('80', 'Tỉnh Tây Ninh', 'Tinh', 'Sáp nhập Tây Ninh + Long An', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('82', 'Tỉnh Đồng Tháp', 'Tinh', 'Sáp nhập Đồng Tháp + Tiền Giang', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('86', 'Tỉnh Vĩnh Long', 'Tinh', 'Sáp nhập Vĩnh Long + Bến Tre + Trà Vinh', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('91', 'Tỉnh An Giang', 'Tinh', 'Sáp nhập An Giang + Kiên Giang', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('92', 'Thành phố Cần Thơ', 'ThanhPho', 'Sáp nhập Cần Thơ + Sóc Trăng + Hậu Giang', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('96', 'Tỉnh Cà Mau', 'Tinh', 'Sáp nhập Cà Mau + Bạc Liêu', '2026-11-10 14:51:20', '2026-11-10 14:51:20'),
	('97', 'Bảo hiểm xã hội Bộ Quốc phòng', 'DacBiet', 'Mã dành riêng cho thẻ BHYT do BHXH Bộ Quốc phòng cấp', '2026-11-10 14:51:27', '2026-11-10 14:51:27'),
	('98', 'Bảo hiểm xã hội Công an nhân dân', 'DacBiet', 'Mã dành riêng cho thẻ BHYT do BHXH Công an nhân dân cấp', '2026-11-10 14:51:27', '2026-11-10 14:51:27');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.thongbao
CREATE TABLE IF NOT EXISTS `thongbao` (
  `ma_thong_bao` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_tk` bigint(20) unsigned DEFAULT NULL,
  `tieu_de` varchar(255) NOT NULL,
  `noi_dung` text DEFAULT NULL,
  `loai` varchar(50) DEFAULT 'he_thong',
  `duong_dan` varchar(255) DEFAULT NULL,
  `da_doc` tinyint(1) DEFAULT 0,
  `thoi_gian` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ma_thong_bao`),
  KEY `ma_tk` (`ma_tk`),
  CONSTRAINT `thongbao_ibfk_1` FOREIGN KEY (`ma_tk`) REFERENCES `taikhoan` (`ma_tk`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.thongbao: ~0 rows (xấp xỉ)
INSERT INTO `thongbao` (`ma_thong_bao`, `ma_tk`, `tieu_de`, `noi_dung`, `loai`, `duong_dan`, `da_doc`, `thoi_gian`) VALUES
	(1, 1, '💰 Có hóa đơn mới đã thanh toán (VNPay)', 'HĐ #22 — Đinh Trọng Nghĩa — 900.000đ', 'thanh_toan', '/views/admin/dashboard.html', 0, '2026-11-09 16:41:07');

-- Đang kết xuất đổ cấu trúc cho bảng quanlykhamchuabenh.thuoc
CREATE TABLE IF NOT EXISTS `thuoc` (
  `ma_thuoc` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_thuoc` varchar(150) NOT NULL,
  `don_vi_tinh` varchar(50) DEFAULT NULL,
  `don_gia` decimal(12,2) NOT NULL,
  `so_luong_ton` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ma_thuoc`)
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Đang kết xuất đổ dữ liệu cho bảng quanlykhamchuabenh.thuoc: ~39 rows (xấp xỉ)
INSERT INTO `thuoc` (`ma_thuoc`, `ten_thuoc`, `don_vi_tinh`, `don_gia`, `so_luong_ton`) VALUES
	(1, 'Paracetamol 500mg', 'Viên', 1500.00, 2000),
	(2, 'Ibuprofen 400mg', 'Viên', 2500.00, 1500),
	(3, 'Efferalgan 500mg', 'Viên', 3000.00, 800),
	(4, 'Aspirin 81mg', 'Viên', 1800.00, 1200),
	(5, 'Amoxicillin 500mg', 'Viên', 3500.00, 900),
	(6, 'Azithromycin 250mg', 'Viên', 12000.00, 400),
	(7, 'Cefuroxime 500mg', 'Viên', 8000.00, 600),
	(8, 'Ciprofloxacin 500mg', 'Viên', 5500.00, 500),
	(9, 'Amlodipine 5mg', 'Viên', 2000.00, 1500),
	(10, 'Losartan 50mg', 'Viên', 3500.00, 800),
	(11, 'Bisoprolol 5mg', 'Viên', 4000.00, 600),
	(12, 'Atorvastatin 20mg', 'Viên', 6500.00, 700),
	(13, 'Omeprazole 20mg', 'Viên', 3000.00, 1200),
	(14, 'Domperidone 10mg', 'Viên', 2000.00, 900),
	(15, 'Smecta', 'Gói', 5000.00, 500),
	(16, 'Cetirizine 10mg', 'Viên', 1500.00, 1000),
	(17, 'Loratadine 10mg', 'Viên', 2000.00, 800),
	(18, 'Vitamin C 1000mg', 'Viên', 2500.00, 2000),
	(19, 'Vitamin B Complex', 'Viên', 3000.00, 1500),
	(20, 'Calcium D3', 'Viên', 4500.00, 900),
	(21, 'Clopidogrel 75mg', 'Viên', 5500.00, 1000),
	(22, 'Rosuvastatin 10mg', 'Viên', 4500.00, 800),
	(23, 'Isotretinoin 20mg', 'Viên', 8000.00, 500),
	(24, 'Ketoconazole 2%', 'Tuýp', 15000.00, 300),
	(25, 'Fucidin 15g', 'Tuýp', 65000.00, 200),
	(26, 'Oresol', 'Gói', 3000.00, 2000),
	(27, 'Paracetamol 250mg', 'Gói', 2500.00, 1500),
	(28, 'Otrivin 0.1%', 'Lọ', 45000.00, 400),
	(29, 'Augmentin 1g', 'Viên', 18000.00, 600),
	(30, 'Alpha Choay', 'Viên', 2500.00, 2000),
	(31, 'Meloxicam 7.5mg', 'Viên', 3000.00, 1000),
	(32, 'Celecoxib 200mg', 'Viên', 4500.00, 800),
	(33, 'Glucosamine 1500mg', 'Viên', 5000.00, 1200),
	(34, 'Acid Folic 5mg', 'Viên', 1500.00, 2000),
	(35, 'Neo-Tergynan', 'Viên', 12000.00, 300),
	(36, 'Obimin', 'Viên', 3500.00, 1000),
	(37, 'V.Rohto 13ml', 'Lọ', 55000.00, 500),
	(38, 'Tobrex 5ml', 'Lọ', 48000.00, 400),
	(39, 'Systane Ultra 5ml', 'Lọ', 75000.00, 300);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
