# PHÂN HỆ ỨNG DỤNG DI ĐỘNG DÀNH CHO BỆNH NHÂN (PATIENT MOBILE)
## HỆ THỐNG QUẢN LÝ PHÒNG KHÁM ĐA KHOA (CLINIC MANAGEMENT SYSTEM)

Dự án ứng dụng di động được xây dựng bằng **Flutter SDK (v3.11+)**, kết nối hệ thống Backend API (Laravel 11, MySQL) nhằm phục vụ người bệnh đăng ký, đặt lịch khám chữa bệnh, thanh toán số, theo dõi hàng đợi tiếp nhận và tra cứu hồ sơ bệnh án điện tử.

---

## 1. TÀI LIỆU QUAN TRỌNG DÀNH CHO HỘI ĐỒNG CHẤM KHÓA LUẬN

* **Hướng dẫn cài đặt, vận hành & Danh sách tài khoản thử nghiệm:**
  Vui lòng xem chi tiết tại: [HUONG_DAN_SU_DUNG.md](HUONG_DAN_SU_DUNG.md)
  *(Bao gồm: Cấu hình ADB/Wi-Fi, 04 số điện thoại kiểm thử Firebase OTP, thông tin thẻ test VNPay Sandbox, hướng dẫn từng bước 8 chức năng cốt lõi và bảng kịch bản kiểm thử mẫu TC-01 đến TC-09).*

* **Tài liệu Kiến trúc, Logic nghiệp vụ & Thuật toán:**
  Vui lòng xem chi tiết tại: [PATIENT_MOBILE_ARCHITECTURE_AND_LOGIC.md](PATIENT_MOBILE_ARCHITECTURE_AND_LOGIC.md)
  *(Bao gồm: Thiết kế kiến trúc phần mềm Clean Architecture + MVC/GetX, phân tích luồng dữ liệu Sequence Diagrams, ma trận API, giải thuật phân tích CCCD & Reactive Lock, kiểm soát đối soát chéo thẻ BHYT và giải thuật chống dồn giỏ hàng).*

---

## 2. TÓM TẮT TÀI KHOẢN KIỂM THỬ NHANH (QUICK TEST ACCOUNTS)

### 2.1. Nhóm 1: Tài khoản ĐÃ ĐĂNG KÝ trong Database (Đăng nhập trực tiếp)
| Số điện thoại | Mật khẩu thật trong Database | Họ và tên | Chức năng kiểm thử chính |
|---|---|---|---|
| **0374 244 315** | **`DLakaH@k4i`** | Đặng Duy Lợi | Dữ liệu đầy đủ: Đã có sẵn EMR, lịch sử khám, đơn thuốc, AI Explainer. Mật khẩu chuẩn chính sách bảo mật (10 ký tự, hoa, thường, số, ký tự đặc biệt). |

### 2.2. Nhóm 2: Số điện thoại Firebase CHƯA ĐĂNG KÝ (Dùng kiểm thử Đăng ký mới)
| Số điện thoại | Mã OTP Firebase | Trạng thái DB | Mật khẩu gợi ý đặt khi test | Mục đích kiểm thử |
|---|---|---|---|---|
| **0375 135 605** | `123456` | Chưa đăng ký | `Clinic@123` | Kiểm thử toàn trình luồng Đăng ký mới, tạo mật khẩu, lập hồ sơ |
| **0987 654 321** | `123456` | Chưa đăng ký | `Clinic@123` | Kiểm thử đăng ký & ràng buộc BHYT (tối đa 2 chuyên khoa/ngày) |
| **0333 713 010** | `123456` | Chưa đăng ký | `Clinic@123` | Kiểm thử đăng ký & quản lý đa hồ sơ (CCCD, BHYT đối soát tuổi) |

*Thông tin thẻ kiểm thử VNPay Sandbox:*
- Ngân hàng: **NCB** | Số thẻ: `9704198526191432198` | Tên chủ thẻ: `NGUYEN VAN A` | Ngày phát hành: `07/15` | OTP: `123456`

---

## 3. KHỞI CHẠY HỆ THỐNG NHANH (1-CLICK RUN SCRIPTS)

Dự án cung cấp sẵn tệp kịch bản tự động tại thư mục gốc `Clinic_Management_System`:
- **`run_all.bat`:** Tự động kiểm tra và bật MySQL, bật Backend API (cổng 8080), tự động cấu hình `adb reverse tcp:8080 tcp:8080` và chạy `flutter run`. Khuyến nghị sử dụng cho Hội đồng chấm khi kiểm thử trên thiết bị thật cắm cáp USB!
- **`start_backend.bat`:** Khởi chạy riêng Backend API trên cổng 8080 (khi dùng file APK độc lập hoặc máy ảo).
