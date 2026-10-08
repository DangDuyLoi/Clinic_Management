import 'package:get/get.dart';
import '../views/specialty_screen.dart';
import '../views/date_selection_screen.dart';
import '../views/doctor_list_screen.dart';
import '../views/time_slot_screen.dart';
import '../../../services/booking_api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum BookingMethod { bySpecialty, byDoctor, byDate }

class BookingController extends GetxController {
  // ================= STATE (BookingState) =================
  final selectedProfile = Rxn<Map<String, dynamic>>();
  final bookingMethod = Rxn<BookingMethod>();
  
  // Dữ liệu đặt khám
  final selectedSpecialty = Rxn<Map<String, dynamic>>();
  final selectedDoctor = Rxn<Map<String, dynamic>>();
  final selectedDate = Rxn<DateTime>();
  final selectedTimeSlot = Rxn<Map<String, dynamic>>();
  
  final availableTimeSlots = <String>[].obs;
  final isLoadingSlots = false.obs;
  
  var isLoading = false.obs;
  
  // Thông tin Bảo hiểm
  final hasHealthInsurance = false.obs; // BHYT
  final healthInsuranceType = RxnString(); // Đúng tuyến, Trái tuyến...
  final hasPrivateInsurance = false.obs; // BH Tư nhân
  
  // Phương thức thanh toán
  final paymentMethod = RxnString(); // Thẻ khám bệnh, MoMo, Mobile Banking

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
    if (hasHealthInsurance.value == false && hasPrivateInsurance.value == false) {
      Get.defaultDialog(
        title: "Thiếu thông tin",
        middleText: "Vui lòng chọn thông tin bảo hiểm y tế để tiếp tục.",
        textConfirm: "Đóng",
        onConfirm: () => Get.back(),
      );
      return false;
    }
    
    if (hasHealthInsurance.value == true && healthInsuranceType.value == null) {
      Get.snackbar('Cảnh báo', 'Vui lòng chọn loại Bảo hiểm Y tế (Đúng tuyến/Trái tuyến).');
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

      // Ensure we have data
      if (selectedDate.value == null || selectedTimeSlot.value == null || selectedDoctor.value == null || selectedProfile.value == null) {
        throw Exception("Vui lòng hoàn tất việc chọn Lịch khám và Bác sĩ trước khi thanh toán.");
      }

      String timeStr = selectedTimeSlot.value!['time'];
      
      // If it's a range like '06:30 - 07:30', take the start time
      if (timeStr.contains(' - ')) {
        timeStr = timeStr.split(' - ')[0].trim();
      }
      
      // Ensure time string has seconds for Laravel 'H:i:s' validation
      if (timeStr.length == 5) {
        timeStr += ':00';
      }

      final thoiGian = '${DateFormat('yyyy-MM-dd').format(selectedDate.value!)} $timeStr';
      
      final maHoSoStr = (selectedProfile.value!['ma_ho_so'] ?? selectedProfile.value!['id']).toString();
      final maBacSiStr = (selectedDoctor.value!['ma_bac_si'] ?? selectedDoctor.value!['id']).toString();
      
      final result = await BookingApiService.createBooking(
        maHoSo: int.parse(maHoSoStr),
        maBacSi: int.parse(maBacSiStr),
        thoiGianDenKham: thoiGian,
      );

      isLoading.value = false;
      return result;
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
