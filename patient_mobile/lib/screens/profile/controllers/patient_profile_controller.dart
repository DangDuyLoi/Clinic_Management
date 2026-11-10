import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Bộ Regex & Validator nghiệp vụ Y tế (HIS/EMR) dùng cho các TextFormField
class MedicalValidators {
  /// Danh sách mã đối tượng tham gia BHYT hợp lệ theo chuẩn BHXH Việt Nam (QĐ 1666/QĐ-BHXH)
  static const Set<String> validBhytPrefixes = {
    'DN', 'HX', 'CH', 'NN', 'TK', 'HC', 'XK',
    'HT', 'TB', 'NO',
    'QN', 'CA', 'CY', 'CB', 'KC', 'TE', 'BT', 'HN', 'DT', 'DK', 'XD', 'TS', 'TC',
    'CN', 'HS', 'SV', 'GB',
    'GD', 'PV'
  };

  /// Regex số điện thoại di động Việt Nam (đầu 0 hoặc +84 kết hợp với 3, 5, 7, 8, 9 và 8 chữ số tiếp theo)
  static final RegExp vietnamesePhoneRegex = RegExp(r'^(0|\+84)(3|5|7|8|9)[0-9]{8}$');

  /// 1. Kiểm tra mã thẻ Bảo hiểm Y tế (BHYT) 15 ký tự chuẩn BHXH & Kiểm tra chéo độ tuổi
  static String? validateBhyt(String? value, {int? patientAge, int? birthYear}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Không bắt buộc, nhưng nếu có nhập thì phải chuẩn
    }

    final code = value.trim().toUpperCase();

    if (code.length != 15) {
      return 'Mã thẻ BHYT phải có chính xác 15 ký tự.';
    }

    // 2 ký tự đầu: Mã đối tượng
    final prefix = code.substring(0, 2);
    if (!validBhytPrefixes.contains(prefix)) {
      return 'Mã đối tượng BHYT ("$prefix") không thuộc danh mục hợp lệ của BHXH.';
    }

    // Ký tự thứ 3: Mức hưởng (1-5)
    final benefitLevel = code.substring(2, 3);
    if (!RegExp(r'^[1-5]$').hasMatch(benefitLevel)) {
      return 'Ký tự thứ 3 biểu thị mức hưởng, phải là số từ 1 đến 5.';
    }

    // Ký tự 4-5: Mã tỉnh (01-96)
    final provinceCode = int.tryParse(code.substring(3, 5));
    if (provinceCode == null || provinceCode < 1 || provinceCode > 96) {
      return 'Ký tự 4 và 5 biểu thị mã tỉnh cấp thẻ, phải từ 01 đến 96.';
    }

    // 10 ký tự cuối: Mã số định danh BHXH
    final personalId = code.substring(5, 15);
    if (!RegExp(r'^[0-9]{10}$').hasMatch(personalId)) {
      return '10 ký tự cuối phải là số định danh BHXH gồm 10 chữ số.';
    }

    // KIỂM TRA CHÉO ĐỘ TUỔI VÀ MÃ ĐỐI TƯỢNG BHYT (Cross-check Age vs BHYT Subject Code)
    if (patientAge != null) {
      if (prefix == 'TE' && patientAge >= 6) {
        return 'Mã BHYT "TE" chỉ dành cho trẻ em dưới 6 tuổi (bệnh nhân hiện tại $patientAge tuổi).';
      }
      if (prefix == 'HS' && (patientAge < 6 || patientAge > 18)) {
        final yearNote = birthYear != null ? ' (sinh năm $birthYear)' : '';
        return 'Mã BHYT "HS" chỉ áp dụng cho học sinh từ 6 đến 18 tuổi$yearNote. Bệnh nhân $patientAge tuổi không thể dùng mã này.';
      }
      if (prefix == 'SV' && (patientAge < 18 || patientAge > 30)) {
        final yearNote = birthYear != null ? ' (sinh năm $birthYear)' : '';
        return 'Mã BHYT "SV" chỉ áp dụng cho sinh viên từ 18 đến 30 tuổi$yearNote (hiện tại $patientAge tuổi).';
      }
      if (prefix == 'HT' && patientAge < 50) {
        return 'Mã BHYT "HT" (Hưu trí) chỉ áp dụng cho người đến tuổi nghỉ hưu (bệnh nhân hiện tại $patientAge tuổi).';
      }
    }

    return null;
  }

  /// 2. Kiểm tra số điện thoại di động Việt Nam
  static String? validatePhone(String? value, {bool isRequired = true, String fieldName = 'Số điện thoại'}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      return isRequired ? 'Vui lòng nhập $fieldName.' : null;
    }

    // Bắt đầu bằng 01 -> Báo lỗi cụ thể về lịch sử đổi đầu số viễn thông
    if (text.startsWith('01') || text.startsWith('+841')) {
      return 'Đầu số 01 đã ngừng hoạt động từ năm 2018. Vui lòng nhập đầu số 10 số (03, 05, 07, 08, 09).';
    }

    if (!vietnamesePhoneRegex.hasMatch(text)) {
      return '$fieldName không đúng định dạng di động Việt Nam (ví dụ: 0901234567 hoặc +84901234567).';
    }

    return null;
  }

  /// 3. Kiểm tra số Căn cước công dân (CCCD) 12 số
  static String? validateCccd(String? value, {bool isUnder14 = false}) {
    final text = value?.trim() ?? '';

    if (text.isEmpty) {
      if (isUnder14) {
        return null; // Trẻ em dưới 14 tuổi: CCCD được phép để trống
      }
      return 'Bệnh nhân từ 14 tuổi trở lên bắt buộc phải nhập số CCCD.';
    }

    if (!RegExp(r'^[0-9]{12}$').hasMatch(text)) {
      return 'Số CCCD phải bao gồm đúng 12 chữ số.';
    }

    final provinceCode = int.tryParse(text.substring(0, 3));
    if (provinceCode == null || provinceCode < 1 || provinceCode > 96) {
      return 'Mã tỉnh trên CCCD (3 số đầu) không nằm trong dải 001-096 hợp lệ.';
    }

    return null;
  }
}

/// Controller quản lý nghiệp vụ Hồ sơ Bệnh nhân (GetX State Management)
class PatientProfileController extends GetxController {
  // --- Các biến trạng thái Reactive ---
  final cccd = ''.obs;
  final birthDate = Rxn<DateTime>();
  final birthDateText = ''.obs; // Chuỗi hiển thị DD/MM/YYYY
  final birthYear = RxnInt();
  final gender = RxnInt(); // 1: Nam, 0: Nữ
  final isCccdLocked = false.obs; // Khóa (Disable) ô Ngày sinh và Giới tính khi CCCD hợp lệ
  final isUnder14 = false.obs; // Cờ nhận diện bệnh nhi dưới 14 tuổi
  final patientAge = RxnInt(); // Tuổi tính toán chính xác
  final emergencyPhone = ''.obs; // SĐT người giám hộ / cha mẹ (cho trẻ em)
  final bhytCard = ''.obs; // Mã thẻ BHYT

  // Text thông báo gợi ý/lỗi trực quan ngay dưới ô CCCD
  final cccdHelperText = ''.obs;
  final cccdErrorText = RxnString();

  /// Lắng nghe và bóc tách thông tin khi người dùng gõ vào ô CCCD
  ///
  /// Cấu trúc CCCD 12 số:
  /// - 3 số đầu: Mã tỉnh/thành phố khai sinh (001 - 096)
  /// - Số thứ 4: Thế kỷ sinh & Giới tính
  ///   + TK 20 (1900-1999): Nam = 0, Nữ = 1
  ///   + TK 21 (2000-2099): Nam = 2, Nữ = 3
  ///   + TK 22 (2100-2199): Nam = 4, Nữ = 5
  /// - Số thứ 5-6: 2 số cuối của năm sinh
  void parseCccdInfo(String rawCccd) {
    final input = rawCccd.trim();
    cccd.value = input;

    // Nếu người dùng xóa bớt (< 12 số) hoặc xóa sạch -> MỞ KHÓA lại cho phép chọn tự do
    if (input.length < 12) {
      isCccdLocked.value = false;
      cccdHelperText.value = '';
      cccdErrorText.value = null;
      return;
    }

    // Nếu nhập đủ 12 ký tự
    if (input.length == 12) {
      if (!RegExp(r'^[0-9]{12}$').hasMatch(input)) {
        cccdErrorText.value = 'CCCD phải bao gồm toàn chữ số.';
        isCccdLocked.value = false;
        return;
      }

      // 1. Kiểm tra mã tỉnh (3 số đầu: 001 - 096)
      final provinceCode = int.tryParse(input.substring(0, 3)) ?? 0;
      if (provinceCode < 1 || provinceCode > 96) {
        cccdErrorText.value = 'Mã tỉnh (3 số đầu: ${input.substring(0, 3)}) không hợp lệ (001-096).';
        isCccdLocked.value = false;
        return;
      }

      // 2. Bóc tách Ký tự thứ 4: Mã thế kỷ và Giới tính
      final genderCenturyCode = int.parse(input[3]);
      // Số chẵn là Nam (1), số lẻ là Nữ (0)
      final extractedGender = (genderCenturyCode % 2 == 0) ? 1 : 0;
      // Tính mốc thế kỷ
      final centuryBase = 1900 + ((genderCenturyCode ~/ 2) * 100);

      // 3. Bóc tách Ký tự 5-6: 2 số cuối năm sinh
      final yearLast2Digits = int.parse(input.substring(4, 6));
      final extractedYear = centuryBase + yearLast2Digits;

      // Cập nhật State phản ứng (Reactive)
      birthYear.value = extractedYear;
      gender.value = extractedGender;

      // Cập nhật hoặc điều chỉnh ngày sinh cho khớp với Năm bóc tách từ CCCD
      if (birthDate.value != null) {
        // Giữ nguyên ngày và tháng đã chọn, chỉ thay thế đúng Năm sinh
        birthDate.value = DateTime(extractedYear, birthDate.value!.month, birthDate.value!.day);
      } else {
        // Mặc định gán đầu năm nếu trước đó chưa chọn ngày
        birthDate.value = DateTime(extractedYear, 1, 1);
      }

      _updateBirthDateDisplay();
      _recalculateAge();

      // KHÓA các trường lại (Single Source of Truth)
      isCccdLocked.value = true;
      cccdErrorText.value = null;
      cccdHelperText.value =
          'Đã trích xuất từ CCCD: ${extractedGender == 1 ? "Nam" : "Nữ"}, Năm sinh $extractedYear (Đã khóa trường Ngày sinh & Giới tính).';
    }
  }

  /// Cập nhật Ngày sinh khi người dùng chọn DatePicker
  void setBirthDate(DateTime pickedDate) {
    if (isCccdLocked.value && birthYear.value != null) {
      // Nếu CCCD đang khóa, cưỡng chế giữ đúng Năm sinh bóc tách từ CCCD
      birthDate.value = DateTime(birthYear.value!, pickedDate.month, pickedDate.day);
    } else {
      birthDate.value = pickedDate;
      birthYear.value = pickedDate.year;
    }

    _updateBirthDateDisplay();
    _recalculateAge();
  }

  /// Cập nhật Giới tính (1: Nam, 0: Nữ)
  void setGender(int? newGender) {
    if (isCccdLocked.value) {
      // Khi đã có CCCD hợp lệ, không cho phép đổi giới tính
      return;
    }
    gender.value = newGender;
  }

  /// Tính tuổi chính xác dựa trên ngày/tháng/năm sinh so với ngày hiện tại
  void _recalculateAge() {
    if (birthDate.value == null) {
      patientAge.value = null;
      isUnder14.value = false;
      return;
    }

    final now = DateTime.now();
    final date = birthDate.value!;

    int age = now.year - date.year;
    if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
      age--;
    }

    patientAge.value = age;
    isUnder14.value = (age < 14);
  }

  /// Cập nhật chuỗi hiển thị DD/MM/YYYY
  void _updateBirthDateDisplay() {
    if (birthDate.value == null) {
      birthDateText.value = '';
      return;
    }
    final d = birthDate.value!;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    birthDateText.value = '$day/$month/${d.year}';
  }

  /// Khởi tạo dữ liệu khi mở form Chỉnh sửa hồ sơ cũ
  void initFromExisting(Map<String, dynamic> initialProfile) {
    if (initialProfile['cccd'] != null && initialProfile['cccd'].toString().isNotEmpty) {
      cccd.value = initialProfile['cccd'].toString();
    }
    if (initialProfile['ngay_sinh'] != null) {
      final parsed = DateTime.tryParse(initialProfile['ngay_sinh'].toString());
      if (parsed != null) {
        birthDate.value = parsed;
        birthYear.value = parsed.year;
        _updateBirthDateDisplay();
        _recalculateAge();
      }
    }
    if (initialProfile['gioi_tinh'] != null) {
      gender.value = int.tryParse(initialProfile['gioi_tinh'].toString());
    }
    if (initialProfile['so_the_bhyt'] != null) {
      bhytCard.value = initialProfile['so_the_bhyt'].toString();
    }
    if (initialProfile['nguoi_lien_he_khan_cap'] != null) {
      emergencyPhone.value = initialProfile['nguoi_lien_he_khan_cap'].toString();
    }

    // Nếu đã có sẵn CCCD hợp lệ 12 số, tự động bóc tách và khóa
    if (cccd.value.length == 12) {
      parseCccdInfo(cccd.value);
    }
  }

  /// Mở khóa thủ công nếu người dùng muốn xóa bỏ CCCD
  void unlockCccd() {
    isCccdLocked.value = false;
    cccd.value = '';
    cccdHelperText.value = '';
    cccdErrorText.value = null;
  }
}

