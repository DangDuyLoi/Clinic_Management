import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/custom_header.dart';
import 'widgets/patient_id_card.dart';
import 'widgets/upcoming_appointment_card.dart';
import 'widgets/feature_grid.dart';
import 'controllers/home_controller.dart';
import '../booking/views/select_profile_screen.dart';
import '../emr/emr_screen.dart';
import '../profile/profile_empty_screen.dart';
import '../../services/patient_profile_service.dart';
import '../booking/views/e_ticket_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF0F5FA,
      ), // Light background for the area below
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.blue.shade50,
              ), // Fallback if image not found
            ),
          ),

          // Scrollable Content
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const CustomHeader(patientName: 'Đặng Duy Lợi'),

                  // The Scrollable White Box
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FA),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 16,
                      right: 16,
                      bottom: 60,
                    ),
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          160, // approximate header height
                    ),
                    child: Column(
                      children: [
                        Obx(() {
                          final homeController = Get.put(HomeController());
                          if (homeController.isLoading.value) {
                            return const Padding(
                              padding: EdgeInsets.only(bottom: 24.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final upcoming = homeController.upcomingAppointment.value;
                          if (upcoming == null) {
                            return const SizedBox.shrink(); // Hide card if no upcoming appointment
                          }

                          // Parse time
                          final aptDate = DateTime.parse(upcoming['thoi_gian_den_kham']);
                          final dateStr = "${aptDate.day.toString().padLeft(2, '0')}/${aptDate.month.toString().padLeft(2, '0')}/${aptDate.year}";
                          final timeStr = "${aptDate.hour.toString().padLeft(2, '0')}:${aptDate.minute.toString().padLeft(2, '0')}";

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: UpcomingAppointmentCard(
                              date: dateStr,
                              time: timeStr,
                              doctorName: upcoming['ten_bac_si'] ?? 'Bác sĩ',
                              specialty: upcoming['khoa'] ?? 'Khoa Khám Bệnh', // Thêm khoa nếu backend có trả về
                              patientName: upcoming['ten_benh_nhan'] ?? 'Bệnh nhân',
                              onTap: () {
                                Get.to(() => ETicketScreen(appointmentData: upcoming));
                              },
                            ),
                          );
                        }),
                        FeatureGrid(
                          onBookAppointment: () {
                            // LOGIC KIỂM TRA HỒ SƠ
                            if (PatientProfileService.cachedProfiles.isEmpty) {
                              // Chưa có hồ sơ => Chuyển đến màn hình tạo hồ sơ (Empty Screen)
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileEmptyScreen(),
                                ),
                              );
                            } else {
                              // Đã có hồ sơ => Chuyển đến màn hình Chọn Hồ Sơ Booking
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectProfileScreen(),
                                ),
                              );
                            }
                          },
                          onEmr: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EmrScreen(),
                              ),
                            );
                          },
                          onProfile: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileEmptyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
