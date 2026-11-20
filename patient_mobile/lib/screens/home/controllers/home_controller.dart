import 'package:get/get.dart';
import '../../../services/booking_api_service.dart';
import '../../../services/patient_profile_service.dart';

class HomeController extends GetxController {
  var upcomingAppointment = Rxn<Map<String, dynamic>>();
  var isLoading = true.obs;
  var patientName = 'Quý khách'.obs;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => fetchUpcomingAppointment());
  }

  Future<void> fetchUpcomingAppointment() async {
    try {
      isLoading(true);
      // Nạp danh sách hồ sơ tương ứng của tài khoản hiện tại
      await PatientProfileService.loadProfiles();
      final profiles = PatientProfileService.cachedProfiles;
      
      if (profiles.isEmpty) {
        patientName.value = 'Quý khách';
        upcomingAppointment.value = null;
        return;
      }

      final ownerProfile = PatientProfileService.accountOwnerProfile;
      final hoTen = ownerProfile == null
          ? ''
          : PatientProfileService.profileFullName(ownerProfile);
      patientName.value = hoTen.isNotEmpty ? hoTen : 'Quý khách';

      final List<int> maHoSoList = profiles.map((p) => p['ma_ho_so'] as int).toList();
      final appointments = await BookingApiService.fetchAppointments(maHoSoList);

      // Lọc các lịch khám sắp tới (thoi_gian_den_kham > hiện tại và trang_thai_kham != 'huy'/'hoan_thanh')
      final now = DateTime.now();
      
      final upcomingList = appointments.where((apt) {
        final aptDate = DateTime.parse(apt['thoi_gian_den_kham']);
        final status = apt['trang_thai_kham'];
        return aptDate.isAfter(now) && status != 'huy' && status != 'hoan_thanh';
      }).toList();

      if (upcomingList.isNotEmpty) {
        // Sắp xếp tăng dần theo thời gian (cái nào gần nhất lên đầu)
        upcomingList.sort((a, b) {
          final dateA = DateTime.parse(a['thoi_gian_den_kham']);
          final dateB = DateTime.parse(b['thoi_gian_den_kham']);
          return dateA.compareTo(dateB);
        });

        upcomingAppointment.value = upcomingList.first;
      } else {
        upcomingAppointment.value = null;
      }
    } catch (e) {
      print('Error fetching upcoming appointment: $e');
      upcomingAppointment.value = null;
    } finally {
      isLoading(false);
    }
  }
}
