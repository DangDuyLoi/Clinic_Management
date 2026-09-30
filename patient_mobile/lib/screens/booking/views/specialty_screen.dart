import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import 'doctor_list_screen.dart';

class SpecialtyScreen extends StatelessWidget {
  final BookingController controller = Get.find<BookingController>();

  SpecialtyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data based on the UI design
    final specialties = [
      {
        'id': 'S1',
        'name': 'BỆNH LÝ CỘT SỐNG',
        'price': '150.000đ',
        'desc': 'Khám, tư vấn, điều trị: Bệnh lý về đau thần kinh cổ, thần kinh tọa (bệnh rễ thắt lưng)...',
      },
      {
        'id': 'S2',
        'name': 'BỆNH LÝ HUYẾT HỌC',
        'price': '150.000đ',
        'desc': 'Khám, tư vấn, điều trị: các bệnh lý liên quan đến máu...',
      },
      {
        'id': 'S3',
        'name': 'CHĂM SÓC GIẢM NHẸ',
        'price': '150.000đ',
        'desc': '(Chỉ nhận người bệnh tái khám hoặc được giới thiệu khám bởi BS Chuyên khoa)\nKhám, tư vấn và điều trị: Người bệnh tái khám sau xuất viện Khoa chăm sóc giảm nhẹ...',
      },
      {
        'id': 'S4',
        'name': 'DA LIỄU',
        'price': '150.000đ',
        'desc': '(Chỉ nhận người bệnh từ 3 tuổi)\nKhám, tư vấn, điều trị: Các bệnh về da, lông, tóc, móng...',
      },
      {
        'id': 'S5',
        'name': 'ĐAU MẠN TÍNH',
        'price': '150.000đ',
        'desc': '(Chỉ nhận người bệnh từ 15 tuổi)\nKhám, tư vấn, điều trị: Người bệnh có vấn đề đau mạn tính...',
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text('Chọn chuyên khoa', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm nhanh chuyên khoa',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          
          // List of Specialties
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: specialties.length,
              itemBuilder: (context, index) {
                final item = specialties[index];
                return GestureDetector(
                  onTap: () {
                    // Cập nhật state chuyên khoa đã chọn
                    controller.selectedSpecialty.value = item;
                    Get.to(() => DoctorListScreen());
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                ),
                              ),
                            ),
                            Text(
                              item['price']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                                  children: [
                                    TextSpan(text: item['desc']),
                                    const TextSpan(
                                      text: '...xem thêm',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ],
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
}
