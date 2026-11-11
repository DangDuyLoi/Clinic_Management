# TÀI LIỆU HƯỚNG DẪN CÀI ĐẶT, VẬN HÀNH VÀ SỬ DỤNG HỆ THỐNG PATIENT-MOBILE
## PHÂN HỆ ỨNG DỤNG DI ĐỘNG DÀNH CHO BỆNH NHÂN - HỆ THỐNG QUẢN LÝ PHÒNG KHÁM
**Tài liệu phục vụ công tác Đánh giá và Chấm Khóa luận Tốt nghiệp**

---

## 1. TỔNG QUAN VÀ MỤC ĐÍCH TÀI LIỆU

Tài liệu này được biên soạn nhằm hướng dẫn Hội đồng chấm Khóa luận, Giảng viên phản biện và Người đánh giá hệ thống thực hiện cài đặt, cấu hình và thao tác kiểm thử toàn bộ các chức năng nghiệp vụ trên ứng dụng di động **Patient Mobile** (phát triển bằng Flutter Framework), kết nối với hệ thống Backend API (Laravel 11, MySQL) và các dịch vụ đám mây bên thứ ba (Firebase Authentication, Firebase Cloud Messaging, VNPay Sandbox, Google Gemini AI).

Mọi chức năng nghiệp vụ, quy tắc xác thực dữ liệu (Validation Rules), cơ chế kiểm soát gian lận bảo hiểm (Fraud Detection) và giải thuật xử lý phiên khám đều có thể được kiểm chứng thông qua danh sách tài khoản thử nghiệm và các kịch bản kiểm thử mẫu được cung cấp chi tiết trong tài liệu này.

---

## 2. YÊU CẦU MÔI TRƯỜNG VÀ HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### 2.1. Yêu cầu môi trường vận hành

| Thành phần | Phiên bản khuyến nghị | Ghi chú |
|---|---|---|
| Hệ điều hành | Windows 10/11, macOS, Linux | Môi trường phát triển và kiểm thử |
| PHP Runtime | Phiên bản >= 8.2 | Chạy Backend API (Laravel 11) |
| Cơ sở dữ liệu | MySQL Server >= 8.0 (hoặc MariaDB >= 10.4) | Lưu trữ cơ sở dữ liệu `QuanLyKhamChuaBenh` |
| Flutter SDK | Phiên bản 3.11.x trở lên | Biên dịch và chạy ứng dụng di động |
| Thiết bị chạy App | Điện thoại thật (Android 8.0+) hoặc Android Emulator | Bắt buộc có kết nối Internet để xác thực Firebase OTP |

---

### 2.2. Khởi chạy nhanh toàn bộ hệ thống bằng 1-Click Script (Khuyến nghị)

Dự án đã tích hợp sẵn 2 kịch bản khởi chạy tự động dạng `.bat` tại thư mục gốc `Clinic_Management_System`, giúp người chấm không cần gõ lệnh thủ công:

* **Tùy chọn 1 - Khởi chạy trọn gói toàn bộ hệ thống (`run_all.bat`):**
  - **Cách thực hiện:** Nhấp đúp chuột (Double click) vào tệp **`run_all.bat`** tại thư mục gốc dự án.
  - **Cơ chế tự động hóa của script:**
    1. Tự động kiểm tra và khởi động dịch vụ cơ sở dữ liệu MySQL (nếu chưa chạy).
    2. Tự động mở cửa sổ máy chủ Backend API (Laravel) trên cổng `8080`.
    3. Tự động kiểm tra kết nối thiết bị Android thật qua cổng USB (`adb devices`).
    4. Tự động thực thi lệnh đảo cổng mạng kết nối (`adb reverse tcp:8080 tcp:8080`).
    5. Tự động khởi chạy ứng dụng di động Flutter (`flutter run`) cài trực tiếp lên thiết bị di động.

* **Tùy chọn 2 - Khởi chạy riêng dịch vụ Backend API (`start_backend.bat`):**
  - Sử dụng khi người chấm chỉ cần khởi động Backend API (ví dụ khi thiết bị di động đã cài sẵn file APK độc lập hoặc đang chạy ứng dụng qua môi trường máy ảo Android Emulator):
  - **Cách thực hiện:** Nhấp đúp chuột vào tệp **`start_backend.bat`** tại thư mục gốc.
  - Máy chủ API sẽ lắng nghe tại cổng: `http://127.0.0.1:8080/api`.

---

### 2.3. Khởi chạy thủ công từng dịch vụ (Nâng cao)

Trường hợp muốn chạy từng dòng lệnh riêng biệt:

1. **Đồng bộ cơ sở dữ liệu và dữ liệu mẫu:**
   ```bash
   cd d:\Data\Khoa Luan Tot Nghiep\Clinic_Management_System\backend_api
   php artisan migrate --force
   php artisan db:seed --class=DatabaseSeeder
   ```
2. **Khởi chạy Backend API:**
   ```bash
   php artisan serve --host=0.0.0.0 --port=8080
   ```
3. **Chuyển tiếp cổng cho thiết bị Android qua cáp USB:**
   ```bash
   adb reverse tcp:8080 tcp:8080
   ```
4. **Khởi chạy ứng dụng Flutter:**
   ```bash
   cd d:\Data\Khoa Luan Tot Nghiep\Clinic_Management_System\patient_mobile
   flutter run
   ```

---

### 2.3. Cấu hình kết nối mạng cho ứng dụng di động

Ứng dụng Flutter cần kết nối tới Backend API đang chạy trên máy tính. Tùy thuộc vào hình thức thiết bị kiểm thử, thực hiện cấu hình như sau:

* **Trường hợp 1: Dùng thiết bị Android thật qua cáp kết nối USB (Khuyến nghị cao nhất):**
  Thực hiện lệnh chuyển tiếp cổng ADB sau khi cắm cáp:
  ```bash
  adb reverse tcp:8080 tcp:8080
  ```
  Khi đó, cấu hình tại tệp `patient_mobile/lib/core/constants/api_constants.dart` giữ nguyên:
  ```dart
  static const String serverHost = '127.0.0.1:8080';
  ```

* **Trường hợp 2: Dùng thiết bị Android thật qua mạng Wi-Fi nội bộ:**
  - Máy tính và điện thoại cùng kết nối vào một mạng Wi-Fi.
  - Tra cứu địa chỉ IPv4 của máy tính (ví dụ: `192.168.1.15`).
  - Mở tệp `patient_mobile/lib/core/constants/api_constants.dart` và cập nhật:
    ```dart
    static const String serverHost = '192.168.1.15:8080';
    ```

* **Trường hợp 3: Khởi chạy ứng dụng:**
  Tại thư mục `patient_mobile`, thực thi lệnh:
  ```bash
  flutter run
  ```

---

## 3. DANH SÁCH TÀI KHOẢN KIỂM THỬ VÀ THÔNG TIN THANH TOÁN

Nhằm phục vụ công tác kiểm thử của Hội đồng chấm thi một cách rõ ràng và minh bạch nhất, danh sách tài khoản được chia làm **02 nhóm chức năng riêng biệt**:
- **Nhóm 1:** Tài khoản **ĐÃ ĐĂNG KÝ SẴN** trong Cơ sở dữ liệu (Dùng để Đăng nhập ngay, có sẵn bệnh án).
- **Nhóm 2:** Số điện thoại **CHƯA ĐĂNG KÝ** trong Cơ sở dữ liệu (Dùng để kiểm thử tính năng Đăng ký mới qua Firebase OTP).

---

### 3.1. Nhóm 1: Tài khoản ĐÃ ĐĂNG KÝ SẴN trong Database (Đăng nhập trực tiếp)

Người chấm không cần đăng ký, chỉ cần mở màn hình **Đăng nhập**, nhập trực tiếp Số điện thoại và Mật khẩu tương ứng trong Database:

| Số điện thoại | Mật khẩu thật trong Database | Họ và tên bệnh nhân | Trạng thái dữ liệu | Mục đích kiểm thử khuyến nghị |
|---|---|---|---|---|
| **0374 244 315** | **`DLakaH@k4i`** | Đặng Duy Lợi | Đã đăng ký (Tài khoản chính) | Tài khoản đầy đủ dữ liệu: Đã có sẵn Hồ sơ bệnh án số 1, có lịch khám mẫu, đơn thuốc điện tử, kết quả xét nghiệm để kiểm tra tính năng EMR và Trợ lý AI Giải thích xét nghiệm. Mật khẩu tuân thủ nghiêm ngặt chính sách bảo mật (10 ký tự, chữ hoa, chữ thường, số và ký tự đặc biệt `@`). |

> **Lưu ý:** Trường hợp muốn kiểm thử chức năng **Quên mật khẩu** hoặc xác thực lại của số `0374 244 315`, mã OTP Firebase xác minh tĩnh là: **`241204`**.

---

### 3.2. Nhóm 2: Số điện thoại thử nghiệm Firebase (CHƯA ĐĂNG KÝ - Dùng để test luồng Đăng ký mới)

Các số điện thoại dưới đây đã được cấu hình trên **Firebase Authentication Console** với mã OTP xác thực tĩnh. Các số này **chưa có tài khoản trong Database**, dành riêng cho Hội đồng chấm kiểm tra toàn trình quy trình **Đăng ký tài khoản mới**:

| Số điện thoại kiểm thử | Mã OTP Firebase | Trạng thái trong Database | Mật khẩu gợi ý đặt khi đăng ký (Tuân thủ ràng buộc) | Mục đích kiểm thử khuyến nghị |
|---|---|---|---|---|
| **0375 135 605** | **`123456`** | **Chưa đăng ký** | `Clinic@123` *(hoặc `Demo@2026`)* | Kiểm thử toàn trình luồng Đăng ký: Nhập SĐT -> Nhập OTP `123456` -> Thiết lập mật khẩu mới đạt chuẩn bảo mật -> Tự động đăng nhập -> Tạo hồ sơ cá nhân. |
| **0987 654 321** | **`123456`** | **Chưa đăng ký** | `Clinic@123` *(hoặc `Demo@2026`)* | Kiểm thử đăng ký mới và kiểm chứng ràng buộc đặt lịch: Giới hạn tối đa 2 chuyên khoa BHYT trong một ngày. |
| **0333 713 010** | **`123456`** | **Chưa đăng ký** | `Clinic@123` *(hoặc `Demo@2026`)* | Kiểm thử đăng ký mới và kiểm chứng đa hồ sơ: Tạo hồ sơ con dưới 14 tuổi (không bắt buộc CCCD), tạo hồ sơ người già có thẻ BHYT diện Hưu trí (HT). |

> **Chính sách ràng buộc mật khẩu bắt buộc của hệ thống (Password Policy):**
> Khi tạo mật khẩu mới hoặc đổi mật khẩu, hệ thống bắt buộc mật khẩu phải thỏa mãn:
> - Độ dài tối thiểu: **8 ký tự**.
> - Chứa ít nhất **01 chữ cái in thường** (`a-z`).
> - Chứa ít nhất **01 chữ cái in hoa** (`A-Z`).
> - Chứa ít nhất **01 ký tự đặc biệt** (`@$!%*#?&`).
> *(Ví dụ hợp lệ: `DLakaH@k4i`, `Clinic@123`, `Demo@2026`).*

> **Hướng dẫn thao tác cho Nhóm 2 (Đăng ký mới):**
> 1. Tại màn hình Đăng nhập -> Chọn **Đăng ký tài khoản**.
> 2. Nhập một trong các số điện thoại ở bảng trên (Ví dụ: `0375135605`).
> 3. Nhập mã OTP tương ứng: `123456`.
> 4. Nhập mật khẩu đạt chuẩn bảo mật (Ví dụ: `Clinic@123`).
> 5. Hệ thống hoàn tất đăng ký và lưu tài khoản vào Database.

---

### 3.3. Thông tin thẻ ngân hàng thử nghiệm Cổng thanh toán VNPay Sandbox

Khi thực hiện thanh toán trực tuyến tiền khám qua cổng VNPay, sử dụng thông tin thẻ môi trường thử nghiệm (NCB Test Card) như sau:

| Thông tin trường | Dữ liệu kiểm thử |
|---|---|
| **Ngân hàng phát hành** | Ngân hàng Quốc Dân (**NCB**) |
| **Số thẻ** | `9704198526191432198` |
| **Tên chủ thẻ** | `NGUYEN VAN A` |
| **Ngày phát hành** | `07/15` |
| **Mật khẩu OTP xác thực giao dịch** | `123456` |

---

## 4. HƯỚNG DẪN CHI TIẾT CÁC CHỨC NĂNG NGHIỆP VỤ (STEP-BY-STEP)

### CHỨC NĂNG 1: XÁC THỰC NGƯỜI DÙNG (ĐĂNG KÝ, ĐĂNG NHẬP, QUẢN LÝ PHIÊN)

#### 1.1. Luồng Đăng nhập hệ thống
1. Khởi động ứng dụng, màn hình đăng nhập hiển thị.
2. Nhập **Số điện thoại** (Ví dụ: `0374244315`).
3. Nhập **Mật khẩu** (Mặc định: `123456` hoặc mật khẩu đã đặt khi đăng ký).
4. Nhấn nút **Đăng nhập**.
5. Hệ thống thực hiện mã hóa và gửi yêu cầu xác thực tới Backend API. Khi thông tin chính xác, JWT Token được lưu trữ an toàn trong `flutter_secure_storage` và điều hướng người dùng vào Màn hình chính (Home Screen).

#### 1.2. Luồng Đăng ký tài khoản mới qua Firebase OTP
1. Tại màn hình Đăng nhập, nhấn vào liên kết **Đăng ký tài khoản**.
2. Nhập **Số điện thoại** muốn đăng ký (Ví dụ: `0375135605`).
   * *Ràng buộc hệ thống:* Số điện thoại phải đúng định dạng chuẩn mạng viễn thông Việt Nam gồm 10 chữ số, bắt đầu bằng các đầu số hợp lệ: `03`, `05`, `07`, `08`, `09`.
3. Nhấn **Gửi mã xác thực**. Hệ thống gọi dịch vụ Firebase Phone Authentication.
4. Màn hình nhập mã xác thực hiển thị gồm 6 ô số. Nhập mã OTP tương ứng (Ví dụ: `123456`).
5. Sau khi Firebase xác minh số điện thoại thành công, ứng dụng chuyển sang màn hình **Thiết lập mật khẩu**.
6. Người dùng nhập mật khẩu mới (tối thiểu 6 ký tự) và xác nhận lại mật khẩu.
7. Nhấn **Hoàn tất đăng ký**. Tài khoản được khởi tạo thành công và người dùng được tự động đăng nhập vào ứng dụng.

---

### CHỨC NĂNG 2: QUẢN LÝ HỒ SƠ BỆNH NHÂN (MULTI-PROFILE & RÀNG BUỘC PHÁP LÝ)

Ứng dụng cho phép một tài khoản số điện thoại quản lý nhiều hồ sơ bệnh nhân (cho bản thân và người thân trong gia đình).

#### 2.1. Thêm mới Hồ sơ "Bản thân" và Cơ chế Reactive Lock với CCCD
1. Tại Màn hình chính hoặc tab **Hồ sơ**, chọn mục **Hồ sơ bệnh nhân** -> Nhấn **Thêm mới hồ sơ**.
2. Hộp thoại lựa chọn đối tượng hiển thị: Chọn **Bản thân**.
   * *Ràng buộc độc bản:* Mỗi tài khoản chỉ được phép sở hữu duy nhất **01 hồ sơ Bản thân**. Nếu đã tồn tại, tùy chọn này sẽ tự động bị ẩn đi.
3. Nhập Họ và tên: `Nguyễn Văn Thử Nghiệm`.
4. Nhập số **Căn cước công dân (CCCD)**: Nhập chuỗi 12 chữ số hợp lệ (Ví dụ: `079095012345`).
   * *Giải thuật phân tích CCCD tự động:*
     - Ký tự thứ 4 đại diện cho thế kỷ và giới tính (Số `0`: Nam sinh thế kỷ 20; Số `1`: Nữ sinh thế kỷ 20; Số `2`: Nam sinh thế kỷ 21,...).
     - Ký tự thứ 5 và 6 đại diện cho 2 số cuối năm sinh (Ví dụ `95` -> Năm sinh `1995`).
   * *Cơ chế Reactive Lock:* Ngay khi nhập đủ 12 chữ số hợp lệ, hệ thống sẽ tự động suy luận: **Giới tính: Nam**, **Năm sinh: 1995**, đồng thời **khóa cứng (disabled)** trường chọn Giới tính và giới hạn năm sinh trên bộ chọn ngày để ngăn chặn dữ liệu mâu thuẫn nhân thân.
5. Nhập địa chỉ, tỉnh/thành phố, quận/huyện, nghề nghiệp, dân tộc.
6. Nhấn **Lưu hồ sơ**. Hệ thống lưu hồ sơ và tự động kích hoạt làm hồ sơ mặc định.

#### 2.2. Kiểm tra tính hợp lệ và Đối soát chéo Thẻ Bảo hiểm Y tế (BHYT)
1. Trong màn hình tạo/chỉnh sửa hồ sơ, tích chọn **Có thẻ Bảo hiểm Y tế**.
2. Nhập mã thẻ BHYT gồm 15 ký tự (Ví dụ: `GD4797912345678`).
3. Quy tắc kiểm tra định dạng và nhóm đối tượng:
   - 2 ký tự đầu: Mã đối tượng tham gia BHYT (Ví dụ: `TE`: Trẻ em; `HS`: Học sinh; `SV`: Sinh viên; `HT`: Hưu trí; `GD`: Hộ gia đình,...).
   - 1 ký tự số tiếp theo: Mức hưởng BHYT (từ 1 đến 5).
   - 2 ký tự số tiếp theo: Mã tỉnh/thành phố cấp thẻ (từ 01 đến 99).
   - 10 ký tự số cuối: Mã định danh cá nhân tham gia BHYT.
4. *Cơ chế đối soát chéo theo độ tuổi (Cross-check Validation):*
   - Nếu mã thẻ là `TE` nhưng ngày sinh lớn hơn hoặc bằng 6 tuổi -> Báo lỗi: *"Thẻ BHYT diện Trẻ em chỉ áp dụng cho người dưới 6 tuổi"*.
   - Nếu mã thẻ là `HT` nhưng độ tuổi dưới 50 -> Báo lỗi: *"Thẻ BHYT diện Hưu trí chỉ áp dụng cho người từ 50 tuổi trở lên"*.
5. Chỉ khi mã thẻ hợp lệ và thỏa mãn ma trận đối soát tuổi, hệ thống mới chấp thuận lưu hồ sơ.

#### 2.3. Tạo hồ sơ Người thân (Trẻ em dưới 14 tuổi)
1. Nhấn **Thêm mới hồ sơ** -> Chọn đối tượng: **Con**.
2. Nhập thông tin ngày sinh của trẻ nhỏ hơn 14 tuổi.
3. *Quy định pháp lý:* Với trẻ em dưới 14 tuổi chưa đến độ tuổi cấp CCCD, trường CCCD không bắt buộc nhập. Hệ thống cho phép sử dụng mã định danh cá nhân trên Giấy khai sinh hoặc thẻ BHYT trẻ em (mã `TE`).

---

### CHỨC NĂNG 3: QUY TRÌNH ĐẶT LỊCH KHÁM BỆNH ĐA CHUYÊN KHOA

Quy trình đặt lịch được thiết kế tối ưu theo 6 bước nghiệp vụ tuần tự:

1. **Bước 1 - Lựa chọn Chuyên khoa:**
   - Tại Màn hình chính, nhấn chọn **Đặt khám theo chuyên khoa**.
   - Danh sách chuyên khoa hiển thị (Nội tổng quát, Tim mạch, Tai Mũi Họng, Nhi khoa, Da liễu, Mắt,...).
   - Nhấn chọn chuyên khoa mong muốn (Ví dụ: *Nội tổng quát*).

2. **Bước 2 - Lựa chọn Bác sĩ phụ trách:**
   - Hệ thống hiển thị danh sách các Bác sĩ thuộc chuyên khoa đã chọn kèm học hàm, học vị, kinh nghiệm và giá dịch vụ khám.
   - Nhấn chọn Bác sĩ mong muốn (hoặc chọn *Bác sĩ chỉ định ngẫu nhiên/Bất kỳ*).

3. **Bước 3 - Chọn Ngày khám và Khung giờ tiếp nhận:**
   - Chọn ngày khám trên lịch (từ ngày hiện tại đến tối đa 30 ngày tới). Các ngày nghỉ hoặc bác sĩ không có lịch trực sẽ tự động bị ẩn.
   - Lựa chọn ca khám: **Ca sáng** (07:30 - 11:30) hoặc **Ca chiều** (13:30 - 16:30).
   - Chọn khung giờ (Slot) tiếp nhận cụ thể (mỗi slot tương ứng khoảng thời gian 15-30 phút). Các khung giờ đã đủ số lượng bệnh nhân tối đa sẽ bị làm mờ và không thể nhấn chọn.

4. **Bước 4 - Chọn Hình thức khám và Kiểm soát Giới hạn BHYT:**
   - Chọn hình thức: **Khám dịch vụ** hoặc **Khám BHYT**.
   - *Ràng buộc chống trục lợi BHYT:* Trường hợp người dùng chọn Khám BHYT, hệ thống kiểm tra lịch sử đặt khám trong ngày. Nếu bệnh nhân này đã đặt đủ **02 chuyên khoa BHYT** trong cùng một ngày, hệ thống sẽ phát sinh cảnh báo vi phạm quy chế bảo hiểm và ngăn chặn thao tác đặt thêm.
   - *Cơ chế Anti-ghost accumulation:* Nếu người dùng nhấn nút Quay lại (Back) để đổi bác sĩ hoặc đổi giờ khám trong cùng một lượt đặt, hệ thống sẽ tự động cập nhật giỏ hàng thay vì cộng dồn số lượt khám ảo.

5. **Bước 5 - Chọn Hồ sơ bệnh nhân tiếp nhận:**
   - Chọn một trong các hồ sơ bệnh nhân đã lưu trong tài khoản để gán cho lượt khám.
   - Người dùng có thể nhanh chóng bổ sung hồ sơ mới ngay tại bước này nếu cần.

6. **Bước 6 - Xác nhận Phiếu đặt khám:**
   - Ứng dụng hiển thị bản tổng hợp chi tiết: Tên bệnh nhân, Chuyên khoa, Bác sĩ phụ trách, Ngày giờ khám, Địa điểm phòng khám và Số tiền dự kiến thanh toán.
   - Nhấn **Xác nhận đặt lịch**.

---

### CHỨC NĂNG 4: THANH TOÁN TRỰC TUYẾN QUA CỔNG VNPAY SANDBOX

1. Sau khi xác nhận đặt lịch, ứng dụng điều hướng sang màn hình thanh toán.
2. Nhấn chọn phương thức **Thanh toán qua Cổng VNPay**.
3. Ứng dụng tự động tạo chữ ký bảo mật HMAC-SHA512 và mở giao diện cổng thanh toán VNPay Sandbox trên trình duyệt tích hợp.
4. Chọn hình thức: **Thẻ nội địa và tài khoản ngân hàng**.
5. Nhập thông tin thẻ kiểm thử NCB:
   - Ngân hàng: `NCB`
   - Số thẻ: `9704198526191432198`
   - Tên chủ thẻ: `NGUYEN VAN A`
   - Ngày phát hành: `07/15`
6. Nhấn **Tiếp tục**. Màn hình yêu cầu OTP xuất hiện.
7. Nhập mã OTP: `123456` và nhấn **Thanh toán**.
8. Cổng thanh toán xử lý thành công và chuyển hướng phản hồi về hệ thống (Return URL / IPN). Trạng thái lượt khám trong cơ sở dữ liệu tự động chuyển từ `cho_thanh_toan` sang `da_thanh_toan`.
9. Ứng dụng điều hướng về màn hình **Thanh toán thành công** và cấp phát Phiếu tiếp nhận điện tử.

---

### CHỨC NĂNG 5: PHIẾU TIẾP NHẬN ĐIỆN TỬ (E-TICKET) VÀ CHECK-IN QR

1. Sau khi đặt lịch thành công, phiếu khám được lưu tại mục **Lịch khám của tôi**.
2. Mở chi tiết phiếu khám để xem **Phiếu tiếp nhận điện tử (E-Ticket)**:
   - **Mã số lượt khám (Booking ID)** và Mã bệnh nhân.
   - **Số thứ tự tiếp nhận** tại phòng khám.
   - **Mã QR Code động:** Chứa chuỗi dữ liệu mã hóa chuẩn hóa của lượt khám.
3. *Quy trình Check-in thực tế:* Khi đến phòng khám, bệnh nhân đưa mã QR này trước máy quét Kiosk tự động hoặc quầy tiếp đón. Hệ thống sẽ nhận diện ngay lập tức mà không cần in phiếu giấy truyền thống.
4. *Chức năng Hủy lịch khám:* Nếu có nhu cầu thay đổi, bệnh nhân có thể nhấn nút **Hủy lịch khám** (hệ thống cho phép hủy khi lịch khám đang ở trạng thái chờ và trước giờ khám tối thiểu 02 giờ).

---

### CHỨC NĂNG 6: THEO DÕI HÀNG ĐỢI THỜI GIAN THỰC (LIVE QUEUE TRACKER)

1. Vào ngày diễn ra lịch khám, tại trang chủ ứng dụng sẽ kích hoạt tiện ích **Theo dõi hàng đợi trực tiếp**.
2. Nhấn vào để mở màn hình giám sát tiến độ phòng khám:
   - Hiển thị **Số thứ tự hiện tại đang được bác sĩ thăm khám**.
   - Hiển thị **Số thứ tự của bệnh nhân**.
   - Tính toán và hiển thị **Số lượng bệnh nhân đang chờ phía trước**.
3. *Hệ thống thông báo đẩy (FCM Push Notification):*
   - Khi bác sĩ gọi số thứ tự kế tiếp, hệ thống gửi thông báo nền tới điện thoại.
   - Khi chỉ còn 03 người chờ phía trước lượt khám của mình, hệ thống phát thông báo cảnh báo để người bệnh kịp thời di chuyển đến cửa phòng khám.

---

### CHỨC NĂNG 7: TRA CỨU HỒ SƠ BỆNH ÁN ĐIỆN TỬ (EMR) VÀ KẾT QUẢ KHÁM

1. Chọn tab **Hồ sơ** -> Chọn mục **Hồ sơ bệnh án điện tử (EMR)**.
2. Chọn hồ sơ bệnh nhân cần xem (Ví dụ: Hồ sơ `Nguyễn Văn A` hoặc tài khoản SĐT `0374244315`).
3. Danh sách các đợt khám bệnh trong quá khứ được liệt kê theo thứ tự thời gian gần nhất:
   - Ngày khám, Bác sĩ chủ trì, Chuyên khoa điều trị.
   - **Chẩn đoán bệnh học:** Mã bệnh quốc tế ICD-10 và kết luận lâm sàng của bác sĩ.
4. Nhấn vào đợt khám cụ thể để xem chi tiết:
   - **Đơn thuốc điện tử:** Tên từng loại thuốc, hoạt chất, liều lượng, quy cách sử dụng (uống trước/sau ăn), số lượng cấp phát và lời dặn của bác sĩ.
   - **Kết quả Cận lâm sàng / Xét nghiệm:** Bảng tra cứu các chỉ số xét nghiệm huyết học, sinh hóa (ví dụ: Glucose máu, Ure, Creatinine, AST, ALT), chỉ số tham chiếu bình thường và cảnh báo chỉ số bất thường.

---

### CHỨC NĂNG 8: TRỢ LÝ Y TẾ THÔNG MINH ỨNG DỤNG TRÍ TUỆ NHÂN TẠO (AI)

Ứng dụng tích hợp hai giải pháp ứng dụng mô hình ngôn ngữ lớn (Google Gemini LLM):

#### 8.1. Trợ lý Ảo Tư vấn Triệu chứng Sức khỏe 24/7 (AI Chatbot)
1. Tại Màn hình chính, nhấn vào biểu tượng **Trợ lý Sức khỏe AI**.
2. Giao diện hội thoại thông minh hiển thị.
3. Người dùng nhập câu hỏi hoặc mô tả triệu chứng gặp phải.
   * *Ví dụ kiểm thử:* *"Tôi bị đau âm ỉ vùng thượng vị kèm ợ chua sau khi ăn 2 ngày nay thì nên đi khám khoa nào và cần chuẩn bị gì?"*
4. Trợ lý AI thực hiện phân tích ngữ nghĩa y khoa, đưa ra nhận định sơ bộ mang tính tham khảo, giải thích nguyên nhân có thể xảy ra và hướng dẫn người dùng lựa chọn đúng chuyên khoa (ở ví dụ trên: Chuyên khoa *Tiêu hóa* hoặc *Nội tổng quát*).

#### 8.2. Trợ lý Giải thích Kết quả Xét nghiệm Y khoa (AI Lab Explainer)
1. Tại màn hình chi tiết kết quả xét nghiệm trong mục **Hồ sơ bệnh án**, nhấn nút **Giải thích bằng AI**.
2. Hệ thống tổng hợp các chỉ số cận lâm sàng và gửi truy vấn dạng Streaming thời gian thực tới mô hình Gemini.
3. Trợ lý AI phân tích các thông số có dấu hiệu bất thường (vượt ngưỡng tham chiếu cao hoặc thấp), chuyển ngữ các thuật ngữ y học phức tạp sang ngôn ngữ phổ thông dễ hiểu, giải thích ý nghĩa bệnh học tương ứng và đưa ra lời khuyên về chế độ dinh dưỡng, vận động hỗ trợ người bệnh an tâm điều trị.

---

## 5. BẢNG TỔNG HỢP CÁC KỊCH BẢN KIỂM THỬ KHUYẾN NGHỊ CHO HỘI ĐỒNG CHẤM

Để tiết kiệm thời gian đánh giá, Hội đồng chấm có thể thực hiện tuần tự các kịch bản kiểm thử sau:

| Mã kịch bản | Tên kịch bản kiểm thử | Dữ liệu đầu vào sử dụng | Thao tác thực hiện | Kết quả mong đợi đạt chuẩn |
|---|---|---|---|---|
| **TC-01** | Kiểm thử Đăng nhập tài khoản có sẵn | SĐT: `0374244315`<br>Pass: `DLakaH@k4i` | Nhập SĐT, mật khẩu -> Nhấn Đăng nhập | Đăng nhập thành công vào Home Screen. Hiển thị đúng tên bệnh nhân và hồ sơ. |
| **TC-02** | Kiểm thử Đăng ký xác thực Firebase OTP | SĐT: `0375135605`<br>OTP: `123456` | Nhập SĐT -> Gửi OTP -> Nhập mã 123456 -> Thiết lập mật khẩu mới | Firebase xác minh thành công. Lưu tài khoản mới vào cơ sở dữ liệu. |
| **TC-03** | Kiểm thử Định dạng số điện thoại | SĐT: `0123456789` hoặc `024123456` | Nhập số điện thoại sai định dạng mạng VN | Hệ thống chặn tại chỗ, hiển thị cảnh báo: *"Số điện thoại phải bắt đầu bằng 03, 05, 07, 08, 09 và gồm 10 chữ số"*. |
| **TC-04** | Kiểm thử Cơ chế Reactive Lock với CCCD | CCCD: `079095012345` | Nhập 12 số CCCD vào form tạo hồ sơ | Tự động điền Giới tính: Nam, Năm sinh: 1995. Khóa không cho phép sửa Giới tính và Năm sinh. |
| **TC-05** | Kiểm thử Đối soát chéo Thẻ BHYT & Độ tuổi | Mã thẻ: `TE1010123456789`<br>Tuổi: 25 tuổi (Sinh năm 2001) | Nhập mã thẻ BHYT TE cho hồ sơ người lớn | Hệ thống từ chối lưu, hiển thị lỗi đối soát chéo: Thẻ TE chỉ dành cho trẻ em dưới 6 tuổi. |
| **TC-06** | Kiểm thử Ràng buộc độc bản Hồ sơ Bản thân | Tài khoản đã có hồ sơ Bản thân | Bấm Thêm mới hồ sơ -> Xem danh sách loại quan hệ | Tùy chọn "Bản thân" tự động ẩn đi, chỉ cho phép tạo hồ sơ Người thân (Con, Vợ, Bố mẹ,...). |
| **TC-07** | Kiểm thử Giới hạn tối đa 2 chuyên khoa BHYT/ngày | Đặt 2 lượt khám BHYT cùng 1 ngày, sau đó thử đặt lượt thứ 3 | Đặt khám Chuyên khoa 1 (BHYT) -> Chuyên khoa 2 (BHYT) -> Chọn Chuyên khoa 3 (BHYT) | Hệ thống phát hiện vi phạm quy định, hiển thị thông báo chặn không cho đặt quá 2 chuyên khoa BHYT trong một ngày. |
| **TC-08** | Kiểm thử Toàn trình Thanh toán VNPay Sandbox | Thẻ NCB: `9704198526191432198`<br>OTP: `123456` | Chọn thanh toán VNPay -> Nhập thông tin thẻ -> Xác thực OTP giao dịch | Trình duyệt chuyển hướng về ứng dụng báo thành công. Lượt khám chuyển sang trạng thái "Đã thanh toán" và sinh E-Ticket QR Code. |
| **TC-09** | Kiểm thử Trợ lý Y tế AI Chatbot & AI Explainer | Câu hỏi: *"Bị đau bao tử nên kiêng gì và khám khoa nào?"* | Gửi tin nhắn trong AI Chatbot | Nhận câu trả lời phân tích y khoa chuẩn mực, định hướng đúng chuyên khoa Nội tiêu hóa. |

---

## 6. THÔNG TIN HỖ TRỢ KỸ THUẬT VÀ LIÊN HỆ

Trong quá trình cài đặt và kiểm thử, nếu Hội đồng chấm hoặc Giảng viên hướng dẫn gặp bất kỳ sự cố kỹ thuật nào liên quan đến môi trường kết nối, cấu hình máy chủ hoặc tài khoản thử nghiệm, vui lòng liên hệ:

- **Sinh viên thực hiện:** Đặng Duy Lợi
- **Đề tài:** Xây dựng Hệ thống Quản lý Phòng khám Đa khoa (Clinic Management System) - Phân hệ Bệnh nhân Di động (Patient Mobile App).
- **Email:** dloi7249@gmail.com
- **Số điện thoại hỗ trợ kỹ thuật:** 0374 244 315

