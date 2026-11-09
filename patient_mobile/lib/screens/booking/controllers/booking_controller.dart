import 'package:get/get.dart';
import '../views/specialty_screen.dart';
import '../views/date_selection_screen.dart';
import '../views/doctor_list_screen.dart';
import '../views/time_slot_screen.dart';
import '../../../services/booking_api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum BookingMethod { bySpecialty, byDoctor, byDate }

/// Loại hình đặt khám: Khám Dịch Vụ vs Khám BHYT
enum BookingType {
  /// Khám Dịch vụ (giá nội bộ phòng khám, thanh toán VNPay)
  dichVu,

  /// Khám BHYT (áp giá nhà nước, tính mức hưởng theo ký tự thứ 3 thẻ BHYT)
  bhyt,
}

/// Enum mô tả loại BHYT bệnh nhân lựa chọn (tương thích ngược)
enum InsuranceOption {
  /// Khám đúng tuyến / Cấp cứu / Có giấy chuyển viện → BHYT chi trả
  dungTuyen,

  /// Khám trái tuyến
  traiTuyen,

  /// Không có BHYT → Bệnh nhân trả 100%
  khongCoBHYT,
}

class BookingController extends GetxController {
  // ================= CÁC HẰNG SỐ ĐỊNH MỨC BHYT =================
  /// Giá khám nhà nước theo quy định BYT (Thông tư 22/2023 & 39/2024 TT-BYT)
  static const int GIA_KHAM_NHA_NUOC = 42100;

  /// Giới hạn số lượng chuyên khoa BHYT tối đa trên 1 ngày khám
  static const int MAX_BHYT_PER_DATE = 2;

  /// Giới hạn tối đa tiền công khám BHYT thanh toán trong 1 ngày (tương thích ngược)
  static const int MAX_BHYT_DAILY_CAP = 2 * GIA_KHAM_NHA_NUOC; // 84.200đ

  /// Ngưỡng hóa đơn nhỏ: Nếu tổng chi phí < 379.500đ (15% lương cơ sở) → Miễn đồng chi trả (BHYT trả 100%)
  static const int NGUONG_HOA_DON_NHO = 379500;

  // ================= CHỐNG TRỤC LỢI BHYT (HỆ THỐNG GIÁM ĐỊNH BHYT QUỐC GIA) =================
  /// Cờ cảnh báo thẻ BHYT bị đưa vào danh sách cảnh báo đen do gom thuốc / trục lợi
  final isBhytBlacklisted = false.obs;

  /// Lý do từ chối thanh toán của Hệ thống Giám định BHYT Quốc gia
  final bhytBlacklistReason = ''.obs;

  /// Chi tiết cảnh báo vi phạm trục lợi (số cơ sở đã khám, số lượt khám liên tục...)
  final bhytFraudDetails = Rxn<Map<String, dynamic>>();

  /// Trạng thái đang tra cứu với máy chủ Giám định BHYT
  final isCheckingBhytWithBhxh = false.obs;

  // ================= STATE (BookingState) =================
  final selectedProfile = Rxn<Map<String, dynamic>>();
  final bookingMethod = Rxn<BookingMethod>();

  // Dữ liệu đặt khám hiện tại (tạm thời)
  final selectedSpecialty = Rxn<Map<String, dynamic>>();
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  final selectedDate = Rxn<DateTime>();
  final selectedTimeSlot = Rxn<Map<String, dynamic>>();

  // Danh sách các chuyên khoa đã thêm (Giỏ đặt khám đa chuyên khoa)
  final bookedItems = <Map<String, dynamic>>[].obs;

  final availableTimeSlots = <String>[].obs;
  final isLoadingSlots = false.obs;

  var isLoading = false.obs;

  // ================= GIAI ĐOẠN 3: KHAI BÁO ƯU TIÊN THÔNG MINH =================
  /// Checkbox tự khai báo cho Thai phụ (nếu là Nữ 16-50 tuổi)
  final isPregnant = false.obs;

  /// Checkbox tự khai báo Người khuyết tật / Thương bệnh binh
  final isDisabledOrVeteran = false.obs;

  /// Tính tuổi hiện tại từ ngày sinh trong hồ sơ
  int? get patientAge {
    final profile = selectedProfile.value;
    if (profile == null) return null;
    final dobStr = profile['ngay_sinh']?.toString();
    if (dobStr == null || dobStr.isEmpty) return null;

    try {
      DateTime? dob;
      if (dobStr.contains('-')) {
        dob = DateTime.tryParse(dobStr);
      } else if (dobStr.contains('/')) {
        final parts = dobStr.split('/');
        if (parts.length == 3) {
          dob = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
      if (dob == null) return null;

      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  /// Kiểm tra xem hồ sơ là Nữ hay không
  bool get isFemale {
    final profile = selectedProfile.value;
    if (profile == null) return false;
    final gender = profile['gioi_tinh'];
    if (gender == 0 ||
        gender == '0' ||
        gender == 'Nữ' ||
        gender == 'Nu' ||
        gender == 'nu') {
      return true;
    }
    return false;
  }

  /// 3.1: Trẻ em (<6 tuổi)
  bool get isChild {
    final age = patientAge;
    return age != null && age < 6;
  }

  /// 3.1: Người cao tuổi (>= 75 tuổi)
  bool get isElderly {
    final age = patientAge;
    return age != null && age >= 75;
  }

  /// 3.2: Điều kiện hiển thị checkbox mang thai (Nữ và từ 16 - 50 tuổi)
  bool get canShowPregnancyOption {
    final age = patientAge;
    return isFemale && age != null && age >= 16 && age <= 50;
  }

  /// Tính toán priority_level (1: Cấp cứu, 2: Trẻ em/Người già, 3: Thai phụ/Khuyết tật, 4: Thường)
  int get calculatedPriorityLevel {
    if (isChild || isElderly) {
      return 2;
    }
    if (isPregnant.value || isDisabledOrVeteran.value) {
      return 3;
    }
    return 4;
  }

  /// Huy hiệu ưu tiên hiển thị trên E-Ticket & Queue Tracker
  String get priorityBadgeText {
    if (isChild) return 'Ưu tiên: Trẻ em (<6 tuổi)';
    if (isElderly) return 'Ưu tiên: Người cao tuổi (≥75 tuổi)';
    if (isPregnant.value) return 'Ưu tiên: Thai phụ';
    if (isDisabledOrVeteran.value)
      return 'Ưu tiên: Khuyết tật / Thương bệnh binh';
    return '';
  }

  bool get hasPriority => calculatedPriorityLevel < 4;

  // ================= PHÂN LUỒNG: KHÁM DỊCH VỤ vs KHÁM BHYT =================
  /// null = chưa chọn; dichVu = Khám Dịch vụ; bhyt = Khám BHYT
  final bookingType = Rxn<BookingType>();

  /// Mã thẻ BHYT (15 ký tự)
  final bhytCardNumber = ''.obs;

  /// Lỗi validate realtime của mã thẻ BHYT
  final bhytCardError = RxnString();

  /// Trạng thái mã thẻ có hợp lệ hay không (15 ký tự, đúng Regex)
  final isBhytCardValid = false.obs;

  bool get isBhyt => bookingType.value == BookingType.bhyt;
  bool get isDichVu => bookingType.value == BookingType.dichVu;

  // ================= THÔNG TIN BẢO HIỂM (TƯƠNG THÍCH NGƯỢC) =================
  final selectedInsurance = Rxn<InsuranceOption>();
  final hasHealthInsurance = false.obs; // BHYT
  final healthInsuranceType = RxnString(); // Đúng tuyến, Trái tuyến...
  final hasPrivateInsurance = false.obs; // BH Tư nhân

  // Phương thức thanh toán
  final paymentMethod = RxnString(); // VNPay, Tiền mặt, v.v.

  // ================= THUẬT TOÁN TÍNH PHÍ BHYT MỚI =================

  /// Tự động lấy mã BHYT từ hồ sơ bệnh nhân nếu đã có sẵn
  void autoFillBhytFromProfile() {
    final profile = selectedProfile.value;
    if (profile != null) {
      final potentialCodes = [
        profile['so_the_bhyt']?.toString(),
        profile['ma_bhyt']?.toString(),
        profile['so_dinh_danh']?.toString(),
      ];
      for (final code in potentialCodes) {
        if (code != null && code.trim().isNotEmpty) {
          final clean = code.trim().toUpperCase();
          if (clean.length == 15 &&
              RegExp(r'^[A-Z]{2}[1-5][0-9]{12}$').hasMatch(clean)) {
            validateBhytCard(clean);
            return;
          }
        }
      }
    }
  }

  /// Kiểm tra định dạng Regex 15 ký tự cho thẻ BHYT (realtime) & Chống trục lợi gom thuốc
  /// Cấu trúc: 2 chữ cái (đối tượng) + 1 chữ số (mức hưởng 1-5) + 12 chữ số
  bool validateBhytCard(String input) {
    final clean = input.trim().toUpperCase();
    bhytCardNumber.value = clean;
    isBhytBlacklisted.value = false;
    bhytBlacklistReason.value = '';
    bhytFraudDetails.value = null;

    if (clean.isEmpty) {
      bhytCardError.value = 'Vui lòng nhập mã thẻ BHYT (15 ký tự)';
      isBhytCardValid.value = false;
      return false;
    }

    if (clean.length != 15) {
      bhytCardError.value =
          'Mã thẻ BHYT phải đúng 15 ký tự (hiện có ${clean.length}/15)';
      isBhytCardValid.value = false;
      return false;
    }

    final regex = RegExp(r'^[A-Z]{2}[1-5][0-9]{12}$');
    if (!regex.hasMatch(clean)) {
      final prefix = clean.substring(0, 2);
      final char3 = clean[2];
      if (!RegExp(r'^[A-Z]{2}$').hasMatch(prefix)) {
        bhytCardError.value =
            '2 ký tự đầu phải là chữ cái (mã đối tượng: DN, TE, CN...)';
      } else if (!RegExp(r'^[1-5]$').hasMatch(char3)) {
        bhytCardError.value = 'Ký tự thứ 3 phải là mức hưởng từ 1 đến 5';
      } else {
        bhytCardError.value = '12 ký tự cuối phải là các chữ số';
      }
      isBhytCardValid.value = false;
      return false;
    }

    // ================= CHỐNG TRỤC LỢI GOM THUỐC BHYT =================
    // Nhận diện mã thẻ thuộc danh sách cảnh báo đen / dấu hiệu gom thuốc
    final blacklistedCodes = [
      'DN4010123456789',
      'DN4019999999999',
      'GD4019999999999',
      'TE1019999999999',
      'HN2019999999999',
    ];
    final prefix = clean.substring(0, 2);
    final tail4 = clean.substring(clean.length - 4);
    final isBlacklistedImmediate =
        ['CB', 'TL', 'BL'].contains(prefix) ||
        blacklistedCodes.contains(clean) ||
        tail4 == '9999' ||
        clean.contains('TRUCLOI');

    if (isBlacklistedImmediate) {
      isBhytBlacklisted.value = true;
      isBhytCardValid.value = false;
      bhytCardError.value =
          'Thẻ bị CẢNH BÁO ĐEN: Phát hiện trục lợi gom thuốc liên tục!';
      bhytBlacklistReason.value =
          'Hệ thống Giám định BHYT Quốc gia phát hiện bệnh nhân đi khám liên tục nhiều ngày tại nhiều cơ sở để gom thuốc. Thẻ BHYT bị đưa vào danh sách cảnh báo đen và TỪ CHỐI THANH TOÁN BHYT.';
      _showBlacklistWarningDialog();
      return false;
    }

    bhytCardError.value = null;
    isBhytCardValid.value = true;

    // Tra cứu đối soát bất đồng bộ với Cổng Giám định BHYT Quốc gia
    _verifyBhytWithBhxhServer(clean);
    return true;
  }

  /// Tra cứu đối soát với Hệ thống Giám định BHYT Quốc gia
  Future<void> _verifyBhytWithBhxhServer(String card) async {
    try {
      isCheckingBhytWithBhxh.value = true;
      final maHoSoStr =
          selectedProfile.value?['ma_ho_so'] ?? selectedProfile.value?['id'];
      final maHoSo = maHoSoStr != null
          ? int.tryParse(maHoSoStr.toString())
          : null;

      final res = await BookingApiService.checkBhytFraudWarning(
        maThe: card,
        maHoSo: maHoSo,
      );

      if (res['is_blacklisted'] == true || res['canh_bao_truc_loi'] == true) {
        isBhytBlacklisted.value = true;
        isBhytCardValid.value = false;
        bhytCardError.value =
            'Thẻ bị CẢNH BÁO ĐEN: Phát hiện trục lợi gom thuốc!';
        final data = res['data'] as Map<String, dynamic>?;
        bhytBlacklistReason.value =
            data?['ly_do_tu_choi'] ??
            res['message'] ??
            'Thẻ BHYT bị đưa vào danh sách cảnh báo đen do trục lợi gom thuốc liên tục.';
        bhytFraudDetails.value =
            data?['chi_tiet_canh_bao'] as Map<String, dynamic>?;
        _showBlacklistWarningDialog();
      }
    } catch (_) {
      // Bỏ qua lỗi kết nối mạng tạm thời
    } finally {
      isCheckingBhytWithBhxh.value = false;
    }
  }

  /// Hộp thoại Cảnh báo Đen từ Hệ thống Giám định BHYT Quốc gia
  void _showBlacklistWarningDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.gpp_bad_rounded,
                color: Color(0xFFDC2626),
                size: 28,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'CẢNH BÁO GIÁM ĐỊNH BHYT',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(
                bhytBlacklistReason.value.isNotEmpty
                    ? bhytBlacklistReason.value
                    : 'Hệ thống Giám định BHYT Quốc gia phát hiện bệnh nhân đi khám liên tục nhiều ngày tại nhiều cơ sở để gom thuốc. Thẻ BHYT bị đưa vào danh sách cảnh báo đen và TỪ CHỐI THANH TOÁN BHYT.',
                style: const TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '⚠️ Hệ thống tự động từ chối áp dụng quyền lợi BHYT. Quý khách vui lòng chuyển sang Khám Dịch Vụ hoặc liên hệ cơ quan BHXH địa phương.',
              style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Chuyển sang Khám Dịch Vụ ngay
              setBookingType(BookingType.dichVu);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Chuyển sang Khám Dịch Vụ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Đọc ký tự thứ 3 của mã thẻ để lấy mức hưởng gốc:
  /// - 1, 2 → 100%
  /// - 3 → 95%
  /// - 4 → 80%
  /// - 5 → 100%
  double get cardBenefitRate {
    final card = bhytCardNumber.value.trim().toUpperCase();
    if (card.length >= 3) {
      final char3 = card[2];
      if (char3 == '1' || char3 == '2' || char3 == '5') {
        return 1.0;
      } else if (char3 == '3') {
        return 0.95;
      } else if (char3 == '4') {
        return 0.80;
      }
    }
    return 0.80; // Mặc định 80% nếu chưa hoàn tất nhập
  }

  String get cardBenefitRateLabel {
    final rate = (cardBenefitRate * 100).round();
    return '$rate%';
  }

  /// Đếm số chuyên khoa BHYT đã thêm cho một ngày khám cụ thể (không tính theo thời gian thực)
  int bhytCountForDate(DateTime? date) {
    if (date == null) return 0;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return bookedItems.where((item) {
      if (item['isBhyt'] != true) return false;
      final itemDate = item['date'] as DateTime?;
      if (itemDate == null) return false;
      return DateFormat('yyyy-MM-dd').format(itemDate) == dateKey;
    }).length;
  }

  /// Kiểm tra xem một ngày khám đã đạt giới hạn tối đa 2 chuyên khoa BHYT chưa
  bool isBhytLimitReachedForDate(DateTime? date) {
    if (date == null) return false;
    final dateKey = DateFormat('yyyy-MM-dd').format(date);

    final doctor = selectedDoctor.value;
    final doctorId = doctor?['id'] ?? doctor?['ma_bac_si'];
    final replacingIndex = doctorId == null
        ? -1
        : bookedItems.indexWhere((item) {
            final itemDoctor = item['doctor'] as Map<String, dynamic>?;
            return (itemDoctor?['id'] ?? itemDoctor?['ma_bac_si']) == doctorId;
          });

    bool replacingSameDateBhyt = false;
    if (replacingIndex >= 0 && bookedItems[replacingIndex]['isBhyt'] == true) {
      final repDate = bookedItems[replacingIndex]['date'] as DateTime?;
      if (repDate != null &&
          DateFormat('yyyy-MM-dd').format(repDate) == dateKey) {
        replacingSameDateBhyt = true;
      }
    }

    final currentCount =
        bhytCountForDate(date) - (replacingSameDateBhyt ? 1 : 0);
    return currentCount >= MAX_BHYT_PER_DATE;
  }

  /// Kiểm tra có thể chọn BHYT cho chuyên khoa và ngày khám đang chọn hay không
  bool get canSelectBhytForCurrentItem {
    final targetDate = selectedDate.value;
    if (targetDate == null) {
      return bookedItems.where((item) => item['isBhyt'] == true).length < 2;
    }
    return !isBhytLimitReachedForDate(targetDate);
  }

  int get bhytBookingCount =>
      bookedItems.where((item) => item['isBhyt'] == true).length;

  bool get hasBhytBookings =>
      itemCostBreakdown.any((item) => item['isBhyt'] == true);

  bool get hasServiceBookings =>
      itemCostBreakdown.any((item) => item['isBhyt'] != true);

  /// Cập nhật loại hình khám: Dịch vụ hoặc BHYT
  void setBookingType(BookingType type) {
    if (type == BookingType.bhyt && !canSelectBhytForCurrentItem) {
      final dateStr = selectedDate.value != null
          ? 'ngày ${DateFormat('dd/MM/yyyy').format(selectedDate.value!)}'
          : 'ngày khám này';
      Get.defaultDialog(
        title: 'Đã đạt giới hạn BHYT trong ngày',
        middleText:
            'Bệnh nhân đã đăng ký tối đa 2 chuyên khoa BHYT trong $dateStr.\n\nTheo quy định BHYT, quý khách vui lòng chọn Khám Dịch Vụ cho chuyên khoa tiếp theo.',
        textConfirm: 'Chuyển sang Khám Dịch Vụ',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF0284C7),
        onConfirm: () {
          Get.back();
          setBookingType(BookingType.dichVu);
        },
      );
      return;
    }

    bookingType.value = type;
    if (type == BookingType.bhyt) {
      hasHealthInsurance.value = true;
      selectedInsurance.value = InsuranceOption.dungTuyen;
      healthInsuranceType.value = 'Khám BHYT (Giá nhà nước)';
      autoFillBhytFromProfile();
    } else {
      hasHealthInsurance.value = false;
      selectedInsurance.value = InsuranceOption.khongCoBHYT;
      healthInsuranceType.value = 'Khám Dịch vụ';
      bhytCardError.value = null;
      isBhytBlacklisted.value = false;
    }
  }

  List<Map<String, dynamic>> get _itemsForCost {
    final items = bookedItems.toList();
    final doctor = selectedDoctor.value;
    if (doctor == null ||
        selectedDate.value == null ||
        selectedTimeSlot.value == null ||
        bookingType.value == null) {
      if (items.isEmpty && selectedSpecialty.value != null) {
        return [
          {
            'specialty': selectedSpecialty.value,
            'isBhyt': isBhyt,
            'date': selectedDate.value,
            'price': isBhyt
                ? GIA_KHAM_NHA_NUOC
                : (selectedSpecialty.value?['gia_kham'] as int? ?? 150000),
          },
        ];
      }
      return items;
    }

    final doctorId = doctor['id'] ?? doctor['ma_bac_si'];
    final existingIndex = items.indexWhere((item) {
      final itemDoctor = item['doctor'] as Map<String, dynamic>?;
      return (itemDoctor?['id'] ?? itemDoctor?['ma_bac_si']) == doctorId;
    });
    final specialty = selectedSpecialty.value ??
        (doctor['chuyen_khoa'] is Map<String, dynamic>
            ? doctor['chuyen_khoa'] as Map<String, dynamic>
            : null);
    final draft = {
      'specialty': specialty,
      'doctor': doctor,
      'date': selectedDate.value,
      'timeSlot': selectedTimeSlot.value,
      'isBhyt': isBhyt,
      'price': isBhyt
          ? GIA_KHAM_NHA_NUOC
          : (specialty?['gia_kham'] as int? ?? 150000),
    };

    if (existingIndex >= 0) {
      items[existingIndex] = draft;
    } else {
      items.add(draft);
    }
    return items;
  }

  /// Bảng phân rã chi phí chi tiết từng chuyên khoa:
  /// - Khám Dịch Vụ: LUÔN tính 100% giá niêm yết phòng khám (KHÔNG giảm 30% ở bất kỳ lượt nào)
  /// - Khám BHYT: Tối đa 2 chuyên khoa / ngày khám (Lượt 1: 100% giá nhà nước 42.100đ, Lượt 2: 30% giá nhà nước 12.630đ)
  /// - Miễn đồng chi trả nếu tổng BHYT < 379.500đ
  List<Map<String, dynamic>> get itemCostBreakdown {
    final items = _itemsForCost;
    final result = <Map<String, dynamic>>[];

    // Đếm số lượt BHYT theo từng ngày khám cụ thể (dateKey -> count)
    final Map<String, int> bhytSlotByDate = {};
    int serviceIndex = 0;

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final spec = item['specialty'] as Map<String, dynamic>?;
      final name =
          spec?['name'] ?? spec?['ten_chuyen_khoa'] ?? 'Chuyên khoa ${i + 1}';
      final itemIsBhyt = item['isBhyt'] == true;
      final itemDate = item['date'] as DateTime? ?? selectedDate.value;
      final dateKey = itemDate != null
          ? DateFormat('yyyy-MM-dd').format(itemDate)
          : 'common';
      final dateStr = itemDate != null
          ? DateFormat('dd/MM/yyyy').format(itemDate)
          : '';

      if (!itemIsBhyt) {
        // --- KHÁM DỊCH VỤ ---
        // Người dùng yêu cầu: Lần 2 của khám dịch vụ KHÔNG tính 30% lần 1! LUÔN 100% giá niêm yết!
        serviceIndex++;
        final int basePrice =
            (spec?['gia_kham'] as int? ?? (item['price'] as int? ?? 150000));
        final double rate = 1.0;
        final int cost = basePrice;

        result.add({
          'index': i + 1,
          'name': name,
          'isBhyt': false,
          'date': itemDate,
          'dateStr': dateStr,
          'basePrice': basePrice,
          'rate': rate,
          'isFirst': serviceIndex == 1,
          'cost': cost,
          'patientPayable': cost,
          'isCapped': false,
          'capNote': 'Khám Dịch vụ (100% giá phòng khám)',
        });
      } else {
        // --- KHÁM BHYT (ÁP GIÁ NHÀ NƯỚC: 42.100đ THEO NGÀY KHÁM) ---
        // Chuyên khoa thứ 1: Quỹ BHYT thanh toán 100% mức giá khám bệnh (42.100đ).
        // Từ chuyên khoa thứ 2 trở đi: BHYT chỉ thanh toán bằng 30% mức giá 1 lần khám (12.630đ).
        // Tối đa 2 chuyên khoa BHYT / ngày khám.
        final currentSlot = (bhytSlotByDate[dateKey] ?? 0) + 1;
        bhytSlotByDate[dateKey] = currentSlot;

        final int basePrice = GIA_KHAM_NHA_NUOC;
        double rate;
        int approvedCost;
        bool isCapped = false;
        String capNote = '';

        if (currentSlot == 1) {
          rate = 1.0;
          approvedCost = basePrice; // 42.100đ
          capNote = dateStr.isNotEmpty
              ? 'BHYT - Lượt 1 ngày $dateStr (100% giá nhà nước: ${NumberFormat('#,###', 'vi_VN').format(approvedCost)}đ)'
              : 'BHYT - Lượt 1 (100% giá nhà nước: ${NumberFormat('#,###', 'vi_VN').format(approvedCost)}đ)';
        } else if (currentSlot == 2) {
          rate = 0.30;
          approvedCost = (basePrice * rate).round(); // 12.630đ
          capNote = dateStr.isNotEmpty
              ? 'BHYT - Lượt 2 ngày $dateStr (30% giá nhà nước: ${NumberFormat('#,###', 'vi_VN').format(approvedCost)}đ)'
              : 'BHYT - Lượt 2 (30% giá nhà nước: ${NumberFormat('#,###', 'vi_VN').format(approvedCost)}đ)';
        } else {
          rate = 0.0;
          approvedCost = 0;
          isCapped = true;
          capNote = dateStr.isNotEmpty
              ? 'Đã đủ 2 lượt BHYT ngày $dateStr (Tối đa theo quy định)'
              : 'Đã đủ 2 lượt BHYT trong ngày (Tối đa theo quy định)';
        }

        result.add({
          'index': i + 1,
          'name': name,
          'isBhyt': true,
          'date': itemDate,
          'dateStr': dateStr,
          'basePrice': basePrice,
          'rate': rate,
          'isFirst': currentSlot == 1,
          'bhytSlot': currentSlot,
          'cost': approvedCost,
          'patientPayable': 0, // Sẽ tính bên dưới sau khi xét tổng hóa đơn nhỏ
          'standardCost': approvedCost,
          'isCapped': isCapped,
          'capNote': capNote,
        });
      }
    }

    // Nhóm chi phí BHYT để xét miễn đồng chi trả (Hóa đơn nhỏ < 379.500đ)
    final bhytSubtotal = result
        .where((item) => item['isBhyt'] == true)
        .fold<int>(0, (sum, item) => sum + (item['cost'] as int));
    final bhytInvoiceIsSmall = bhytSubtotal < NGUONG_HOA_DON_NHO;

    for (final item in result.where((item) => item['isBhyt'] == true)) {
      final cost = item['cost'] as int;
      item['patientPayable'] = bhytInvoiceIsSmall
          ? 0
          : (cost * (1 - cardBenefitRate)).round();
    }

    return result;
  }

  /// Kiểm tra xem có chuyên khoa BHYT nào vượt trần 2 lượt/ngày khám không
  bool get hasExceededBhytCap {
    if (!hasBhytBookings) return false;
    return itemCostBreakdown.any((item) => item['isCapped'] == true);
  }

  /// Thông điệp cảnh báo trần BHYT hiển thị trên giao diện
  String get bhytCapWarningText {
    return 'Quy định BHYT (Thông tư 22/2023/TT-BYT): Bệnh nhân được hưởng BHYT tối đa 2 chuyên khoa trong cùng 1 ngày khám (lượt 1 hưởng 100%, lượt 2 hưởng 30% giá nhà nước). Các chuyên khoa thêm trong ngày sẽ được tính theo giá Khám Dịch Vụ.';
  }

  /// Tổng chi phí trước khi xét miễn đồng chi trả BHYT
  int get totalCostBeforeInsurance {
    final breakdown = itemCostBreakdown;
    if (breakdown.isEmpty && bookingType.value != null) {
      return isBhyt ? GIA_KHAM_NHA_NUOC : 150000;
    }
    return breakdown.fold<int>(
      0,
      (sum, item) => sum + (item['cost'] as int),
    );
  }

  int get bhytCostBeforeInsurance => itemCostBreakdown
      .where((item) => item['isBhyt'] == true)
      .fold<int>(0, (sum, item) => sum + (item['cost'] as int));

  int get serviceCostBeforeInsurance => itemCostBreakdown
      .where((item) => item['isBhyt'] != true)
      .fold<int>(0, (sum, item) => sum + (item['cost'] as int));

  bool get isSmallInvoice =>
      hasBhytBookings && bhytCostBeforeInsurance < NGUONG_HOA_DON_NHO;

  /// Tỷ lệ BHYT thực tế chi trả
  double get effectiveInsuranceRate {
    if (!hasBhytBookings) return 0.0;
    if (isSmallInvoice) return 1.0; // Miễn đồng chi trả
    return cardBenefitRate;
  }

  /// Số tiền BHYT chi trả
  int get insuranceDiscount {
    if (!hasBhytBookings) return 0;
    final bhytPayable = itemCostBreakdown
        .where((item) => item['isBhyt'] == true)
        .fold<int>(0, (sum, item) => sum + (item['patientPayable'] as int));
    return bhytCostBeforeInsurance - bhytPayable;
  }

  /// Tổng tiền BN phải thanh toán thực tế
  /// Khám Dịch vụ: trả 100% qua VNPay
  /// Khám BHYT: chỉ trả phần đồng chi trả (0đ nếu hóa đơn nhỏ < 379.500đ)
  int get totalBookingCost {
    return itemCostBreakdown.fold<int>(
      0,
      (sum, item) => sum + (item['patientPayable'] as int),
    );
  }

  /// Tương thích ngược với các getter cũ
  int get totalOriginalCost => totalCostBeforeInsurance;
  double get insuranceRate => effectiveInsuranceRate;

  /// Label hiển thị trên UI cho lựa chọn BHYT hiện tại
  String get insuranceLabel {
    if (hasBhytBookings) {
      if (isSmallInvoice) {
        return 'BHYT (Hóa đơn nhỏ: Miễn đồng chi trả 100%)';
      }
      return 'BHYT Mức hưởng $cardBenefitRateLabel';
    }
    return 'Khám Dịch vụ (Giá nội bộ)';
  }

  /// Cập nhật lựa chọn BHYT cũ (đồng bộ)
  void setInsuranceOption(InsuranceOption option) {
    selectedInsurance.value = option;
    if (option == InsuranceOption.khongCoBHYT) {
      setBookingType(BookingType.dichVu);
    } else {
      setBookingType(BookingType.bhyt);
    }
  }

  /// Thêm chuyên khoa vừa chọn vào danh sách giỏ khám
  void addCurrentBookingToItems() {
    if (selectedDate.value == null ||
        selectedTimeSlot.value == null ||
        selectedDoctor.value == null) {
      return;
    }

    if (bookingType.value == null) {
      Get.snackbar('Chưa chọn hình thức khám', 'Vui lòng chọn BHYT hoặc Khám Dịch vụ.');
      return;
    }

    bool itemIsBhyt = isBhyt;
    if (itemIsBhyt && !canSelectBhytForCurrentItem) {
      // Tự động chuyển thành Dịch vụ nếu ngày khám này đã đủ 2 lượt BHYT
      itemIsBhyt = false;
      bookingType.value = BookingType.dichVu;
      final dateStr = selectedDate.value != null
          ? 'ngày ${DateFormat('dd/MM/yyyy').format(selectedDate.value!)}'
          : 'ngày khám này';
      Get.snackbar(
        'Tự động chuyển Khám Dịch Vụ',
        'Đã đủ 2 chuyên khoa BHYT trong $dateStr. Chuyên khoa này được chuyển sang Khám Dịch Vụ.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }

    final int giaKham = itemIsBhyt
        ? GIA_KHAM_NHA_NUOC
        : (selectedSpecialty.value?['gia_kham'] as int? ?? 150000);

    final newItem = {
      'specialty': selectedSpecialty.value,
      'doctor': selectedDoctor.value,
      'date': selectedDate.value,
      'timeSlot': selectedTimeSlot.value,
      'price': giaKham,
      'isBhyt': itemIsBhyt,
      'bhytCardNumber': itemIsBhyt ? bhytCardNumber.value : null,
      'hasHealthInsurance': itemIsBhyt,
      'healthInsuranceType': itemIsBhyt
          ? 'Khám BHYT ($cardBenefitRateLabel)'
          : 'Khám Dịch vụ',
      'insuranceOption': itemIsBhyt ? selectedInsurance.value : InsuranceOption.khongCoBHYT,
      'priority_level': calculatedPriorityLevel,
      'priority_label': priorityBadgeText,
    };

    final doc2 = selectedDoctor.value;
    final docId2 = doc2?['id'] ?? doc2?['ma_bac_si'];

    final existingIndex = bookedItems.indexWhere((item) {
      final doc1 = item['doctor'] as Map<String, dynamic>?;
      final docId1 = doc1?['id'] ?? doc1?['ma_bac_si'];
      return docId1 != null && docId1 == docId2;
    });

    if (existingIndex >= 0) {
      bookedItems[existingIndex] = newItem;
    } else {
      bookedItems.add(newItem);
    }
  }

  /// Khởi tạo quá trình thêm chuyên khoa mới
  void startAddingNewSpecialty() {
    // Reset các biến tạm để chọn chuyên khoa tiếp theo
    selectedSpecialty.value = null;
    selectedDoctor.value = null;
    selectedDate.value = null;
    selectedTimeSlot.value = null;
    availableTimeSlots.clear();
    bookingType.value = null;

    // Mở màn hình chọn Chuyên khoa
    Get.to(() => const SpecialtyScreen());
  }

  /// Xóa bớt 1 chuyên khoa khỏi danh sách
  void removeBookedItem(int index) {
    if (bookedItems.length > 1) {
      bookedItems.removeAt(index);
      Get.snackbar(
        'Đã xóa',
        'Đã xóa chuyên khoa khỏi danh sách khám.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      Get.snackbar(
        'Thông báo',
        'Cần ít nhất 1 chuyên khoa để tiếp tục đặt khám.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe khi đổi hồ sơ để reset các lựa chọn ưu tiên & tự động lấy mã BHYT
    ever(selectedProfile, (_) {
      isPregnant.value = false;
      isDisabledOrVeteran.value = false;
      if (isBhyt) {
        autoFillBhytFromProfile();
      }
    });
  }

  /// Xóa sạch hoàn toàn giỏ khám và trạng thái phiên đặt khám (Chống rò rỉ sang phiên khám tiếp theo)
  void resetBookingSession() {
    _resetBookingDraft();
  }

  void _resetBookingDraft() {
    bookedItems.clear();
    bookingMethod.value = null;
    selectedSpecialty.value = null;
    selectedDoctor.value = null;
    selectedDate.value = null;
    selectedTimeSlot.value = null;
    availableTimeSlots.clear();
    isLoadingSlots.value = false;

    isPregnant.value = false;
    isDisabledOrVeteran.value = false;
    bookingType.value = null;
    bhytCardNumber.value = '';
    bhytCardError.value = null;
    isBhytCardValid.value = false;
    isBhytBlacklisted.value = false;
    bhytBlacklistReason.value = '';
    bhytFraudDetails.value = null;
    isCheckingBhytWithBhxh.value = false;

    selectedInsurance.value = null;
    hasHealthInsurance.value = false;
    healthInsuranceType.value = null;
    hasPrivateInsurance.value = false;
    paymentMethod.value = null;
  }

  // ================= ĐIỀU HƯỚNG THEO NHÁNH =================
  void setBookingMethod(BookingMethod method) {
    _resetBookingDraft();
    bookingMethod.value = method;
    switch (method) {
      case BookingMethod.bySpecialty:
        Get.to(() => SpecialtyScreen());
        break;
      case BookingMethod.byDoctor:
        Get.to(() => DoctorListScreen());
        break;
      case BookingMethod.byDate:
        Get.to(() => DateSelectionScreen());
        break;
    }
  }

  void onDoctorSelected(Map<String, dynamic> doctor) {
    selectedDoctor.value = doctor;
    // Nếu đi từ nhánh "Khám theo Bác sĩ", bước tiếp theo là Chọn Ngày
    if (bookingMethod.value == BookingMethod.byDoctor) {
      Get.to(() => DateSelectionScreen());
    } else {
      fetchAvailableTimeSlots();
      Get.to(() => TimeSlotScreen());
    }
  }

  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    // Nếu trước đó đang chọn BHYT nhưng ngày vừa chọn đã đạt tối đa 2 chuyên khoa BHYT
    if (isBhyt && isBhytLimitReachedForDate(date)) {
      setBookingType(BookingType.dichVu);
      Get.snackbar(
        'Đạt 2 lượt BHYT ngày ${DateFormat('dd/MM/yyyy').format(date)}',
        'Ngày khám này đã có đủ 2 chuyên khoa BHYT. Hệ thống tự động chuyển sang Khám Dịch Vụ.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }

    // Nếu đi từ nhánh "Khám theo Ngày", bước tiếp là Chọn Bác sĩ
    if (bookingMethod.value == BookingMethod.byDate) {
      Get.to(() => DoctorListScreen());
    } else {
      fetchAvailableTimeSlots();
      Get.to(() => TimeSlotScreen());
    }
  }

  // ================= VALIDATION BƯỚC BẢO HIỂM =================
  bool validateInsuranceStep() {
    if (bookingType.value == null) {
      Get.defaultDialog(
        title: "Chưa chọn hình thức khám",
        middleText: "Vui lòng chọn Khám Dịch vụ hoặc Khám BHYT để tiếp tục.",
        textConfirm: "Đóng",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return false;
    }

    if (isBhyt && !isBhytCardValid.value) {
      Get.defaultDialog(
        title: "Mã thẻ BHYT chưa hợp lệ",
        middleText:
            bhytCardError.value ??
            "Vui lòng nhập đúng mã thẻ BHYT 15 ký tự để hưởng quyền lợi BHYT.",
        textConfirm: "Đóng",
        confirmTextColor: Colors.white,
        onConfirm: () => Get.back(),
      );
      return false;
    }

    Get.toNamed('/booking/summary');
    return true;
  }

  // ================= SUBMIT BƯỚC CUỐI =================
  Future<Map<String, dynamic>?> submitBooking() async {
    if (paymentMethod.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn phương thức thanh toán');
      return null;
    }

    // Chặn nếu thẻ BHYT bị cảnh báo đen từ Hệ thống Giám định BHYT Quốc gia
    if (bookedItems.any((item) => item['isBhyt'] == true) &&
        isBhytBlacklisted.value) {
      _showBlacklistWarningDialog();
      Get.snackbar(
        'Từ chối BHYT',
        'Thẻ BHYT bị Hệ thống Giám định BHYT Quốc gia từ chối thanh toán do nằm trong danh sách cảnh báo đen (Trục lợi gom thuốc liên tục nhiều ngày). Vui lòng chuyển sang Khám Dịch Vụ.',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return null;
    }

    try {
      isLoading.value = true;

      if (selectedProfile.value == null) {
        throw Exception("Vui lòng chọn hồ sơ người bệnh.");
      }

      // Đảm bảo giỏ bookedItems có ít nhất thông tin hiện tại
      if (bookedItems.isEmpty) {
        addCurrentBookingToItems();
      }

      if (bookedItems.isEmpty) {
        throw Exception(
          "Vui lòng hoàn tất việc chọn Lịch khám và Bác sĩ trước khi thanh toán.",
        );
      }

      // Kiểm tra giới hạn BHYT: Tối đa 2 chuyên khoa BHYT trên cùng 1 ngày khám
      final Map<String, int> bhytCountByDate = {};
      for (final item in bookedItems) {
        if (item['isBhyt'] == true) {
          final d = item['date'] as DateTime?;
          final dateKey =
              d != null ? DateFormat('yyyy-MM-dd').format(d) : 'none';
          bhytCountByDate[dateKey] = (bhytCountByDate[dateKey] ?? 0) + 1;
          if (bhytCountByDate[dateKey]! > MAX_BHYT_PER_DATE) {
            final dateStr =
                d != null ? DateFormat('dd/MM/yyyy').format(d) : '';
            throw Exception(
              'Ngày khám $dateStr đã vượt quá 2 chuyên khoa BHYT. Vui lòng chuyển các chuyên khoa vượt quá sang Khám Dịch Vụ.',
            );
          }
        }
      }
      final bhytTotalCount =
          bookedItems.where((item) => item['isBhyt'] == true).length;
      if (bhytTotalCount > 0 && !isBhytCardValid.value) {
        throw Exception(
          'Vui lòng nhập mã thẻ BHYT hợp lệ cho các chuyên khoa đã chọn.',
        );
      }

      final maHoSoStr =
          (selectedProfile.value!['ma_ho_so'] ?? selectedProfile.value!['id'])
              .toString();
      final maHoSo = int.parse(maHoSoStr);

      List<int> createdIds = [];
      Map<String, dynamic>? lastResult;
      final breakdown = itemCostBreakdown;

      // Duyệt qua tất cả chuyên khoa đã chọn để tạo lịch khám
      for (int i = 0; i < bookedItems.length; i++) {
        final item = bookedItems[i];
        final doctor = item['doctor'] as Map<String, dynamic>;
        final date = item['date'] as DateTime;
        final timeSlot = item['timeSlot'] as Map<String, dynamic>;

        String timeStr = timeSlot['time'];
        if (timeStr.contains(' - ')) {
          timeStr = timeStr.split(' - ')[0].trim();
        }
        if (timeStr.length == 5) {
          timeStr += ':00';
        }

        final thoiGian = '${DateFormat('yyyy-MM-dd').format(date)} $timeStr';
        final maBacSiStr = (doctor['ma_bac_si'] ?? doctor['id']).toString();
        final maBacSi = int.parse(maBacSiStr);

        // Giá của từng chuyên khoa theo bảng tính chi phí (không gửi tổng gộp cho từng khoa)
        final int perItemCost = i < breakdown.length
            ? (breakdown[i]['patientPayable'] as int)
            : 150000;
        final bool itemIsBhyt = item['isBhyt'] == true;
        final String itemInitialStatus =
            perItemCost == 0 ? 'da_thanh_toan' : 'cho_thanh_toan';

        final result = await BookingApiService.createBooking(
          maHoSo: maHoSo,
          maBacSi: maBacSi,
          thoiGianDenKham: thoiGian,
          priorityLevel: calculatedPriorityLevel,
          trangThai: itemInitialStatus,
          soTien: perItemCost,
          maTheBhyt: itemIsBhyt ? bhytCardNumber.value : null,
          isBhyt: itemIsBhyt,
        );
        lastResult = result;

        int? id;
        if (result['data'] is Map && result['data']['ma_luot_kham'] != null) {
          id = int.tryParse(result['data']['ma_luot_kham'].toString());
        } else if (result['ma_luot_kham'] != null) {
          id = int.tryParse(result['ma_luot_kham'].toString());
        } else if (result['id'] != null) {
          id = int.tryParse(result['id'].toString());
        }
        if (id != null) {
          createdIds.add(id);
        }
      }

      if (lastResult != null) {
        lastResult['priority_level'] = calculatedPriorityLevel;
        lastResult['priority_label'] = priorityBadgeText;
        lastResult['tong_tien'] = totalBookingCost;
        lastResult['so_luong_khoa'] = bookedItems.length;
        lastResult['is_bhyt'] =
            bookedItems.every((item) => item['isBhyt'] == true);
        if (createdIds.isNotEmpty) {
          lastResult['danh_sach_ma_luot_kham'] = createdIds;
        }
        lastResult['danh_sach_chuyen_khoa'] = bookedItems.map((item) {
          final s = item['specialty'] as Map<String, dynamic>?;
          final d = item['doctor'] as Map<String, dynamic>?;
          return {
            'ten_chuyen_khoa':
                s?['name'] ??
                s?['ten_chuyen_khoa'] ??
                d?['chuyen_khoa'] ??
                'Khám chuyên khoa',
            'ten_bac_si': d?['name'] ?? d?['ho_ten'] ?? 'Bác sĩ chuyên khoa',
            'phong_kham': d?['room'] ?? d?['phong_kham'] ?? 'Phòng Khám',
          };
        }).toList();
      }

      isLoading.value = false;
      return lastResult;
    } catch (e) {
      isLoading.value = false;
      final cleanMsg = e.toString().replaceAll('Exception: ', '').trim();
      Get.snackbar(
        'Lỗi Đặt Khám',
        cleanMsg,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
      );
      return null;
    }
  }

  Future<void> fetchAvailableTimeSlots() async {
    if (selectedDoctor.value == null || selectedDate.value == null) return;

    isLoadingSlots.value = true;
    try {
      final docIdRaw =
          selectedDoctor.value!['id'] ?? selectedDoctor.value!['ma_bs'];
      final doctorId = int.parse(docIdRaw.toString());
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value!);

      final slots = await BookingApiService.getAvailableTimeSlots(
        doctorId,
        dateStr,
      );
      availableTimeSlots.value = slots;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải giờ trống: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }
}
