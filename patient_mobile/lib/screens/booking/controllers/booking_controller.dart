import 'package:get/get.dart';
import '../views/specialty_screen.dart';
import '../views/date_selection_screen.dart';
import '../views/doctor_list_screen.dart';
import '../views/time_slot_screen.dart';
import '../../../services/booking_api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum BookingMethod { bySpecialty, byDoctor, byDate }

/// Enum mô tả loại BHYT bệnh nhân lựa chọn (bắt buộc chọn 1 trong 3)
enum InsuranceOption {
  /// Khám đúng tuyến / Cấp cứu / Có giấy chuyển viện → BHYT chi trả 80%
  dungTuyen,

  /// Khám trái tuyến → BHYT chi trả 60%
  traiTuyen,

  /// Không có BHYT → Bệnh nhân trả 100%
  khongCoBHYT,
}

class BookingController extends GetxController {
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
  
  // ================= THÔNG TIN BẢO HIỂM (Bắt buộc chọn) =================
  
  /// Lựa chọn BHYT bắt buộc: Đúng tuyến / Trái tuyến / Không có BHYT
  /// null = chưa chọn (sẽ bị validate)
  final selectedInsurance = Rxn<InsuranceOption>();
  
  // Giữ lại state cũ để tương thích với code hiện tại
  final hasHealthInsurance = false.obs;       // BHYT
  final healthInsuranceType = RxnString();    // Đúng tuyến, Trái tuyến...
  final hasPrivateInsurance = false.obs;      // BH Tư nhân
  
  // Phương thức thanh toán
  final paymentMethod = RxnString(); // Thẻ khám bệnh, MoMo, Mobile Banking

  // ================= LOGIC BHYT THEO LUẬT VIỆT NAM =================
  
  /// Tỷ lệ BHYT chi trả theo luật BHYT Việt Nam (Luật sửa đổi 2024)
  /// - Đúng tuyến / Cấp cứu / Giấy chuyển viện: BHYT chi trả 80%
  /// - Trái tuyến: BHYT chi trả 60%
  /// - Không có BHYT: 0%
  double get insuranceRate {
    switch (selectedInsurance.value) {
      case InsuranceOption.dungTuyen:
        return 0.80; // 80%
      case InsuranceOption.traiTuyen:
        return 0.60; // 60%
      case InsuranceOption.khongCoBHYT:
      case null:
        return 0.0;  // 0%
    }
  }

  /// Label hiển thị trên UI cho lựa chọn BHYT hiện tại
  String get insuranceLabel {
    switch (selectedInsurance.value) {
      case InsuranceOption.dungTuyen:
        return 'Đúng tuyến (BHYT trả 80%)';
      case InsuranceOption.traiTuyen:
        return 'Trái tuyến (BHYT trả 60%)';
      case InsuranceOption.khongCoBHYT:
        return 'Không có BHYT (Trả 100%)';
      case null:
        return 'Chưa chọn';
    }
  }

  /// Cập nhật lựa chọn BHYT (đồng bộ cả state cũ để tương thích)
  void setInsuranceOption(InsuranceOption option) {
    selectedInsurance.value = option;
    // Đồng bộ state cũ
    switch (option) {
      case InsuranceOption.dungTuyen:
        hasHealthInsurance.value = true;
        healthInsuranceType.value = 'Đúng tuyến';
        break;
      case InsuranceOption.traiTuyen:
        hasHealthInsurance.value = true;
        healthInsuranceType.value = 'Trái tuyến';
        break;
      case InsuranceOption.khongCoBHYT:
        hasHealthInsurance.value = false;
        healthInsuranceType.value = null;
        break;
    }
  }

  /// Thêm chuyên khoa vừa chọn vào danh sách giỏ khám
  void addCurrentBookingToItems() {
    if (selectedDate.value == null || selectedTimeSlot.value == null || selectedDoctor.value == null) {
      return;
    }

    // Lấy giá khám thực tế từ chuyên khoa (nếu có), fallback 150.000đ
    final int giaKham = selectedSpecialty.value?['gia_kham'] as int? ?? 150000;

    final newItem = {
      'specialty': selectedSpecialty.value,
      'doctor': selectedDoctor.value,
      'date': selectedDate.value,
      'timeSlot': selectedTimeSlot.value,
      'price': giaKham,
      'hasHealthInsurance': hasHealthInsurance.value,
      'healthInsuranceType': healthInsuranceType.value,
      'insuranceOption': selectedInsurance.value,
    };

    final doc2 = selectedDoctor.value;
    final docId2 = doc2?['id'] ?? doc2?['ma_bac_si'];

    // Kiểm tra xem đã có bác sĩ / chuyên khoa này trong giỏ chưa
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

  // ================= TÍNH PHÍ THEO BHYT =================

  /// Tổng tiền khám gốc (chưa trừ BHYT) của tất cả chuyên khoa đã chọn
  int get totalOriginalCost {
    if (bookedItems.isEmpty) return selectedSpecialty.value?['gia_kham'] as int? ?? 150000;
    return bookedItems.fold<int>(0, (sum, item) => sum + (item['price'] as int? ?? 150000));
  }

  /// Số tiền BHYT chi trả (giảm giá)
  int get insuranceDiscount => (totalOriginalCost * insuranceRate).round();

  /// Tổng tiền BN phải thanh toán thực tế (sau khi trừ BHYT)
  int get totalBookingCost => totalOriginalCost - insuranceDiscount;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo data giả lập
    selectedProfile.value = {'id': '1', 'name': 'Nguyễn Văn A', 'phone': '0901234567'};
  }

  // ================= ĐIỀU HƯỚNG THEO NHÁNH =================
  void setBookingMethod(BookingMethod method) {
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
    // Nếu đi từ nhánh "Khám theo Ngày", bước tiếp là Chọn Bác sĩ
    if (bookingMethod.value == BookingMethod.byDate) {
      Get.to(() => DoctorListScreen());
    } else {
      fetchAvailableTimeSlots();
      Get.to(() => TimeSlotScreen());
    }
  }

  // ================= VALIDATION BƯỚC 6 =================
  bool validateInsuranceStep() {
    if (selectedInsurance.value == null) {
      Get.defaultDialog(
        title: "Thiếu thông tin",
        middleText: "Vui lòng chọn thông tin bảo hiểm y tế (Đúng tuyến / Trái tuyến / Không có BHYT) để tiếp tục.",
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
        throw Exception("Vui lòng hoàn tất việc chọn Lịch khám và Bác sĩ trước khi thanh toán.");
      }

      final maHoSoStr = (selectedProfile.value!['ma_ho_so'] ?? selectedProfile.value!['id']).toString();
      final maHoSo = int.parse(maHoSoStr);

      Map<String, dynamic>? lastResult;

      // Duyệt qua tất cả chuyên khoa đã chọn để tạo lịch khám
      for (final item in bookedItems) {
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

        final result = await BookingApiService.createBooking(
          maHoSo: maHoSo,
          maBacSi: maBacSi,
          thoiGianDenKham: thoiGian,
        );
        lastResult = result;
      }

      isLoading.value = false;
      return lastResult;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Lỗi Đặt Khám', e.toString(), backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5), snackPosition: SnackPosition.TOP);
      return null;
    }
  }

  Future<void> fetchAvailableTimeSlots() async {
    if (selectedDoctor.value == null || selectedDate.value == null) return;
    
    isLoadingSlots.value = true;
    try {
      final doctorId = int.parse(selectedDoctor.value!['id'].toString());
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value!);
      
      final slots = await BookingApiService.getAvailableTimeSlots(doctorId, dateStr);
      availableTimeSlots.value = slots;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải giờ trống: $e');
    } finally {
      isLoadingSlots.value = false;
    }
  }
}
