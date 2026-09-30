import 'package:get/get.dart';
import '../views/specialty_screen.dart';
import '../views/date_selection_screen.dart';
import '../views/doctor_list_screen.dart';
import '../views/time_slot_screen.dart';

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
      Get.to(() => TimeSlotScreen());
    }
  }

  void onDateSelected(DateTime date) {
    selectedDate.value = date;
    // Nếu đi từ nhánh "Khám theo Ngày", bước tiếp là Chọn Bác sĩ
    if (bookingMethod.value == BookingMethod.byDate) {
      Get.to(() => DoctorListScreen());
    } else {
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
  Future<void> submitBooking() async {
    if (paymentMethod.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn phương thức thanh toán');
      return;
    }
    // Gọi API...
  }
}
