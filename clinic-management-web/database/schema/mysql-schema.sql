/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `bacsi`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bacsi` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `benhnhan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `benhnhan` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` bigint(20) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` bigint(20) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `calamviec`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calamviec` (
  `ma_ca` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_ca` varchar(50) NOT NULL,
  `gio_bat_dau` time NOT NULL,
  `gio_ket_thuc` time NOT NULL,
  `luot_kham_toi_da` int(11) DEFAULT 20,
  PRIMARY KEY (`ma_ca`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `chidinhdichvu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chidinhdichvu` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `chitietdonthuoc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chitietdonthuoc` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `chuyenkhoa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chuyenkhoa` (
  `ma_chuyen_khoa` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_chuyen_khoa` varchar(100) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  `trang_thai` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`ma_chuyen_khoa`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dichvu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dichvu` (
  `ma_dich_vu` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_dich_vu` varchar(150) NOT NULL,
  `don_gia` decimal(12,2) NOT NULL,
  `mo_ta` text DEFAULT NULL,
  PRIMARY KEY (`ma_dich_vu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `donthuoc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `donthuoc` (
  `ma_don_thuoc` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_phien_kham` bigint(20) unsigned NOT NULL,
  `tong_tien` decimal(12,2) DEFAULT 0.00,
  `ngay_ke_don` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ma_don_thuoc`),
  UNIQUE KEY `ma_phien_kham` (`ma_phien_kham`),
  CONSTRAINT `donthuoc_ibfk_1` FOREIGN KEY (`ma_phien_kham`) REFERENCES `phienkham` (`ma_phien_kham`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` varchar(255) NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`),
  KEY `failed_jobs_connection_queue_failed_at_index` (`connection`,`queue`,`failed_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `hoadon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hoadon` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `hosobenhan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hosobenhan` (
  `ma_ho_so` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_benh_nhan` bigint(20) unsigned DEFAULT NULL,
  `tien_su_benh` text DEFAULT NULL,
  `nhom_mau` varchar(5) DEFAULT NULL,
  `ma_bhyt` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`ma_ho_so`),
  UNIQUE KEY `ma_benh_nhan` (`ma_benh_nhan`),
  CONSTRAINT `hosobenhan_ibfk_1` FOREIGN KEY (`ma_benh_nhan`) REFERENCES `benhnhan` (`ma_benh_nhan`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` smallint(5) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `khunggio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `khunggio` (
  `ma_khung_gio` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ma_ca` bigint(20) unsigned NOT NULL,
  `gio_bat_dau` time NOT NULL,
  `gio_ket_thuc` time NOT NULL,
  `luot_kham_toi_da` int(11) DEFAULT 3,
  PRIMARY KEY (`ma_khung_gio`),
  KEY `ma_ca` (`ma_ca`),
  CONSTRAINT `khunggio_ibfk_1` FOREIGN KEY (`ma_ca`) REFERENCES `calamviec` (`ma_ca`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `loaidoituongbhyt`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `loaidoituongbhyt` (
  `ma_doi_tuong` varchar(2) NOT NULL COMMENT 'Mã 2 ký tự đầu trên thẻ BHYT',
  `ten_doi_tuong` varchar(255) NOT NULL COMMENT 'Tên nhóm đối tượng',
  `muc_huong` int(11) NOT NULL COMMENT 'Ô thứ 2 trên thẻ (1, 2, 3, 4, 5)',
  `ty_le_huong` int(11) NOT NULL COMMENT 'Phần trăm chi trả thực tế (100, 95, 80)',
  PRIMARY KEY (`ma_doi_tuong`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `luotkham`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `luotkham` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `nhatkyhethong`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `nhatkyhethong` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `phienkham`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phienkham` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `taikhoan`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taikhoan` (
  `ma_tk` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_dang_nhap` varchar(50) NOT NULL,
  `mat_khau` varchar(255) NOT NULL,
  `ho_ten` varchar(100) DEFAULT NULL,
  `vai_tro` enum('QuanTri','BacSi','LeTan','BenhNhan') NOT NULL,
  `trang_thai` tinyint(1) DEFAULT 1,
  `ngay_tao` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`ma_tk`),
  UNIQUE KEY `ten_dang_nhap` (`ten_dang_nhap`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `thongbao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `thongbao` (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `thuoc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `thuoc` (
  `ma_thuoc` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ten_thuoc` varchar(150) NOT NULL,
  `don_vi_tinh` varchar(50) DEFAULT NULL,
  `don_gia` decimal(12,2) NOT NULL,
  `so_luong_ton` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`ma_thuoc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tinhthanh`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tinhthanh` (
  `ma_tinh` varchar(2) NOT NULL COMMENT 'Mã tỉnh/thành (01-98)',
  `ten_tinh` varchar(100) NOT NULL COMMENT 'Tên tỉnh/thành phố',
  `loai` varchar(20) DEFAULT NULL COMMENT 'ThanhPho / Tinh / DacBiet',
  `ghi_chu` text DEFAULT NULL COMMENT 'Ghi chú sáp nhập (nếu có)',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`ma_tinh`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `fcm_token` varchar(500) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_phone_number_unique` (`phone_number`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (1,'0001_01_01_000000_create_users_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (2,'0001_01_01_000001_create_cache_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (3,'0001_01_01_000002_create_jobs_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (4,'2026_09_21_025408_create_personal_access_tokens_table',1);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (5,'2026_09_21_034642_add_phone_number_to_users_table',2);
INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES (6,'2026_10_07_070322_add_fcm_token_to_users_table',2);
