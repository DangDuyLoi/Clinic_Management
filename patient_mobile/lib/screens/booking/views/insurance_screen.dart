import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import 'summary_screen.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text(
          'Thông tin bảo hiểm',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xác nhận thông tin BHYT',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng chọn loại thẻ bảo hiểm bạn đang sử dụng để chúng tôi chuẩn bị thủ tục thanh toán phù hợp.',
              style: TextStyle(color: Colors.black54, height: 1.5),
            ),
            const SizedBox(height: 24),
            
            // Bảo hiểm Y Tế Nhà Nước
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Obx(() => CheckboxListTile(
                        title: const Text('Có sử dụng Bảo hiểm Y tế', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('BHYT Nhà nước cấp'),
                        activeColor: Colors.blue,
                        value: controller.hasHealthInsurance.value,
                        onChanged: (value) {
                          controller.hasHealthInsurance.value = value ?? false;
                          if (!controller.hasHealthInsurance.value) {
                            controller.healthInsuranceType.value = null; // reset
                          }
                        },
                      )),
                  Obx(() {
                    if (controller.hasHealthInsurance.value) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text('Chọn tuyến khám BHYT:', style: TextStyle(fontWeight: FontWeight.w500)),
                            RadioListTile<String>(
                              title: const Text('Đúng tuyến / Cấp cứu / Giấy chuyển viện'),
                              value: 'Đúng tuyến',
                              groupValue: controller.healthInsuranceType.value,
                              onChanged: (val) => controller.healthInsuranceType.value = val,
                              contentPadding: EdgeInsets.zero,
                              activeColor: Colors.blue,
                            ),
                            RadioListTile<String>(
                              title: const Text('Trái tuyến'),
                              value: 'Trái tuyến',
                              groupValue: controller.healthInsuranceType.value,
                              onChanged: (val) => controller.healthInsuranceType.value = val,
                              contentPadding: EdgeInsets.zero,
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Bảo hiểm Tư Nhân
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Obx(() => CheckboxListTile(
                    title: const Text('Bảo hiểm bảo lãnh viện phí (Tư nhân)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Dai-ichi, Manulife, BaoViet...'),
                    activeColor: Colors.blue,
                    value: controller.hasPrivateInsurance.value,
                    onChanged: (value) {
                      controller.hasPrivateInsurance.value = value ?? false;
                    },
                  )),
            ),
            
            const SizedBox(height: 32),
            
            // Button Tiếp tục
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Gọi hàm validate
                  if (controller.hasHealthInsurance.value == false && controller.hasPrivateInsurance.value == false) {
                    Get.defaultDialog(
                      title: "Xác nhận",
                      middleText: "Bạn không sử dụng bảo hiểm y tế. Tiếp tục thanh toán 100% viện phí?",
                      textConfirm: "Đồng ý",
                      textCancel: "Chọn lại",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back(); // Đóng dialog
                        Get.to(() => const SummaryScreen());
                      },
                    );
                  } else if (controller.hasHealthInsurance.value == true && controller.healthInsuranceType.value == null) {
                    Get.snackbar('Cảnh báo', 'Vui lòng chọn loại tuyến BHYT (Đúng tuyến / Trái tuyến).');
                  } else {
                    Get.to(() => const SummaryScreen());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
