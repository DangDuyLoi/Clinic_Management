# TÀI LIỆU HƯỚNG DẪN SỬ DỤNG VÀ THUẬT TOÁN HỆ THỐNG (BẢN WEB)

> **Dự án:** Hệ thống Quản lý Phòng khám Đa khoa
> **Phân hệ:** Website dành cho Quản trị viên, Bác sĩ và Lễ tân
> **Công nghệ:** Laravel API (PHP) + HTML/CSS/JS (Vanilla)
> **Cơ sở dữ liệu:** MySQL (`QuanLyKhamChuaBenh`)

---

## PHẦN 1: HƯỚNG DẪN CÀI ĐẶT VÀ KHỞI CHẠY

### 1. Yêu cầu môi trường
- Cài đặt **XAMPP** (cung cấp Apache & MySQL).
- Cài đặt **PHP >= 8.2** và **Composer**.

### 2. Các bước cài đặt
1. **Cơ sở dữ liệu:**
   - Mở phpMyAdmin (`http://localhost/phpmyadmin`).
   - Tạo database mới tên: `QuanLyKhamChuaBenh`.
   - Import file `quanlykhamchuabenh.sql` (đi kèm source code) vào database vừa tạo.
2. **Cấu hình Backend:**
   - Mở file `.env` trong thư mục source code.
   - Cập nhật thông tin kết nối CSDL:
     ```env
     DB_CONNECTION=mysql
     DB_HOST=127.0.0.1
     DB_PORT=3306
     DB_DATABASE=QuanLyKhamChuaBenh
     DB_USERNAME=root
     DB_PASSWORD=
     ```
3. **Khởi chạy Server:**
   - Mở Terminal tại thư mục dự án, chạy lần lượt các lệnh:
     ```bash
     composer install
     php artisan key:generate
     php artisan optimize:clear
     php artisan serve
     ```
4. **Truy cập Website:**
   - Mở trình duyệt, truy cập: `http://127.0.0.1:8000/login.html` (hoặc `http://huitclinic.test/login.html` nếu dùng Virtual Host).

---

## PHẦN 2: HƯỚNG DẪN SỬ DỤNG CHỨC NĂNG

### 1. Tài khoản Test (Mật khẩu chung: `123456`)
| Vai trò | Tên đăng nhập | Chức năng chính |
| :---              | :---              | :---                                                          |
| **Quản trị viên** | `admin`           | Quản lý danh mục, xem Dashboard, cấu hình lịch, xem nhật ký.  |
| **Lễ tân**        | `letan.lan`       | Đặt lịch, tiếp nhận, check-in, thu tiền, quản lý hồ sơ.       |
| **Bác sĩ**        | `bs.hoangtuan`    | Xem danh sách khám, cập nhật chẩn đoán, kê đơn thuốc.         |

### 2. Dành cho Lễ tân
- **Thêm bệnh nhân:** Vào *Hồ sơ bệnh nhân* -> Bấm *Thêm*. Hệ thống tự động kiểm tra tính hợp lệ của SĐT, CCCD (bóc tách năm sinh/giới tính) và Mã BHYT.
- **Đặt lịch khám:** Vào *Đặt lịch khám* -> Chọn bệnh nhân -> Chọn Chuyên khoa. Nếu để *Tự động chọn* khung giờ, hệ thống sẽ tự xếp bác sĩ rảnh nhất.
- **Check-in:** Vào *Check-in bệnh nhân* -> Có thể bấm Check-in trực tiếp hoặc dùng *Quét QR Check-in* (quét mã từ App Mobile).
- **Thanh toán:** Vào *Thanh toán* -> Bấm *Thu tiền*. Hệ thống hiển thị số tiền BHYT chi trả và số tiền bệnh nhân phải đóng.

### 3. Dành cho Bác sĩ
- **Khám bệnh:** Tại Dashboard, chọn bệnh nhân -> Bấm *Khám*.
- **Cập nhật kết quả:** Nhập chẩn đoán, thêm chỉ định cận lâm sàng (tự động cộng tiền vào hóa đơn), chọn thuốc và liều lượng (hệ thống tự kiểm tra tồn kho).
- **Hoàn thành:** Bấm *Hoàn thành phiên khám* để hệ thống tự tính tiền và chuyển hóa đơn cho Lễ tân.

### 4. Dành cho Quản trị viên
- **Dashboard:** Xem biểu đồ doanh thu, top bác sĩ khám nhiều nhất. Có thể xuất file Excel.
- **Cấu hình:** Thêm/Sửa/Xóa Chuyên khoa, Dịch vụ, Thuốc, Tài khoản, Ca làm việc.
- **Nhật ký:** Xem lịch sử thao tác dữ liệu (Ai sửa? Sửa gì? Lúc nào?).

---

## PHẦN 3: TÀI LIỆU THUẬT TOÁN & LOGIC NGHIỆP VỤ (BACKEND)

### 1. Thuật toán Phân bổ Bác sĩ Tự động (Load Balancing)
Khi Lễ tân đặt lịch, hệ thống không gán cứng một bác sĩ mà tìm người **rảnh nhất** trong khung giờ đó để tránh quá tải.

**Mã giả (Pseudocode):**
```text
Input: ma_chuyen_khoa, ngay_kham, khung_gio_bat_dau, khung_gio_ket_thuc
B1: Lấy danh sách bác sĩ thuộc chuyên khoa.
B2: Khởi tạo bestDoctor = null, min_lich_hen = 9999.
B3: Duyệt từng bác sĩ:
    - Đếm số lịch hẹn của bác sĩ đó trong (ngay_kham, khung_gio).
    - Nếu số lịch hẹn < min_lich_hen:
        -> min_lich_hen = số lịch hẹn
        -> bestDoctor = bác sĩ hiện tại
B4: Trả về bestDoctor.
```

### 2. Thuật toán Ràng buộc Dữ liệu Y tế (Medical Validation)
Hệ thống thực hiện kiểm tra chéo (Cross-check) để chống gian lận và nhập liệu sai.

**A. Bóc tách CCCD 12 số:**
- **3 số đầu:** Mã tỉnh/thành phố (đối chiếu với danh mục 63 tỉnh cũ).
- **Số thứ 4 (Mã thế kỷ + giới tính):**
  - Chẵn (0, 2, 4) = Nam. Lẻ (1, 3, 5) = Nữ.
  - 0, 1 = Thế kỷ 20 (19xx). 2, 3 = Thế kỷ 21 (20xx).
- **Số 5-6:** 2 số cuối của năm sinh.
- *Ràng buộc:* Năm sinh/Giới tính nhập vào form phải khớp với dữ liệu giải mã từ CCCD.

**B. Cross-check Mã BHYT (15 ký tự):**
- **2 ký tự đầu:** Mã đối tượng (tra trong bảng `loaidoituongbhyt`).
- **Ký tự thứ 3:** Mức hưởng (1-5).
- **2 ký tự tiếp:** Mã tỉnh (tra trong bảng `TinhThanh`).
- **Ràng buộc tuổi:**
  - `TE` (Trẻ em): < 6 tuổi.
  - `HS` (Học sinh): 6 - 18 tuổi.
  - `HT` (Hưu trí): >= 50 tuổi.

### 3. Thuật toán Tính tiền và Khấu trừ BHYT (Billing Engine)
Khi bác sĩ hoàn thành khám, hệ thống tính toán chi phí dựa trên các quy tắc y tế:

```text
1. Tổng tiền = Tiền dịch vụ (Xét nghiệm, CĐHA) + Tiền thuốc.
2. Nếu bệnh nhân KHÔNG có BHYT:
   -> Bệnh nhân trả = Tổng tiền.
3. Nếu bệnh nhân CÓ BHYT:
   - Xác định mức hưởng (dựa vào ký tự thứ 3 của thẻ): 100%, 95%, hoặc 80%.
   - Tiền BHYT trả = Tổng tiền * Mức hưởng.
   - Tiền bệnh nhân trả = Tổng tiền - Tiền BHYT trả.
   - *Ngoại lệ:* Nếu Tổng tiền < 379.500 VNĐ (15% lương cơ sở), bệnh nhân được MIỄN PHÍ 100% (BHYT trả hết).
4. Tạo Hóa đơn (Trạng thái: Chưa thanh toán).
5. Chuyển trạng thái Lượt khám -> "Hoàn tất hóa đơn" (Chờ Lễ tân thu tiền).
```

### 4. Cơ chế Check-in bằng mã QR (Contactless Check-in)
- **Sinh mã:** Khi tạo lịch khám, hệ thống sinh một `qr_token` ngẫu nhiên (ví dụ: `LK4F8A2B...`). Mã QR được vẽ từ chuỗi `LICHKHAM:LK4F8A2B...`.
- **Quét mã:** Lễ tân dùng webcam quét mã -> Frontend cắt lấy token -> Gửi API `POST /api/lich-kham/scan-qr`.
- **Xử lý:** Backend xóa các ký tự rác, tìm lịch khám có `qr_token` tương ứng. Nếu thấy, đổi trạng thái lượt khám sang `cho_kham`.

### 5. Cơ chế Audit Log (Nhật ký hệ thống)
Sử dụng **Laravel Observer**. Hệ thống tự động lắng nghe mọi sự kiện Thêm/Sửa/Xóa trên các bảng quan trọng (`BenhNhan`, `LichKham`, `HoaDon`...).
- Ghi nhận: `ma_tk` (ai làm), `hanh_dong` (làm gì), `du_lieu_cu` (dữ liệu trước khi sửa), `du_lieu_moi` (dữ liệu sau khi sửa), `thoi_gian`.
- Giúp Admin dễ dàng truy vết khi có sai sót hoặc tranh chấp dữ liệu.