import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import '../../profile/create_profile_screen.dart';
import '../../../services/patient_profile_service.dart';

class SelectProfileScreen extends StatelessWidget {
  final BookingController controller = Get.put(BookingController());

  SelectProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng data thực tế từ Cache của PatientProfileService
    final profiles = PatientProfileService.cachedProfiles;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text('Đặt khám', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.blue, size: 28),
            onPressed: () => Get.offAllNamed('/home'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chọn hồ sơ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Chuyển sang màn hình tạo hồ sơ mới
                    Get.to(() => const CreateProfileScreen());
                  },
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Thêm mới hồ sơ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          
          // Current selected quick avatar (From user's screenshot)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue, size: 30),
                  ),
                ),
                const SizedBox(height: 4),
                const Text('LỢI', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const Text('W26-0452260', style: TextStyle(color: Colors.blue, fontSize: 10)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Danh sách hồ sơ dạng Card
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return GestureDetector(
                  onTap: () {
                    // Lưu profile vào state
                    controller.selectedProfile.value = profile;
                    // Hiển thị Bottom Sheet chọn hình thức khám
                    _showBookingMethodBottomSheet(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.qr_code, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${profile['ho_chu_lot']?.toString() ?? ''} ${profile['ten']?.toString() ?? ''}'.trim().toUpperCase(),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.badge, size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(profile['ma_ho_so']?.toString() ?? 'Chưa cấp', style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.phone, size: 16, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(profile['so_dien_thoai']?.toString() ?? '', style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(profile['quan_he']?.toString() ?? 'Tôi', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingMethodBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 32),
          decoration: const BoxDecoration(
            color: Color(0xFF333333), // Màu tối như thiết kế của user
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Text(
                'Chọn hình thức đặt khám',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildMethodCard(
                iconUrl: 'assets/images/specialty_icon.png', // Thay bằng icon hợp lý hoặc emoji
                fallbackIcon: Icons.medical_services,
                title: 'Khám theo chuyên khoa',
                subtitle: 'Chọn chuyên khoa theo bệnh lý',
                onTap: () {
                  Get.back();
                  controller.setBookingMethod(BookingMethod.bySpecialty);
                },
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                iconUrl: 'assets/images/calendar_icon.png',
                fallbackIcon: Icons.calendar_month,
                title: 'Khám theo ngày',
                subtitle: 'Chọn ngày khám mong muốn',
                onTap: () {
                  Get.back();
                  controller.setBookingMethod(BookingMethod.byDate);
                },
              ),
              const SizedBox(height: 12),
              _buildMethodCard(
                iconUrl: 'assets/images/doctor_icon.png',
                fallbackIcon: Icons.person,
                title: 'Khám theo bác sĩ',
                subtitle: 'Chọn bác sĩ mong muốn',
                onTap: () {
                  Get.back();
                  controller.setBookingMethod(BookingMethod.byDoctor);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMethodCard({
    required String iconUrl,
    required IconData fallbackIcon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(fallbackIcon, size: 30, color: Colors.blue[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
