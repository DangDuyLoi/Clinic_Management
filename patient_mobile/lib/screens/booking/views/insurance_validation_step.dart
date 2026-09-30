import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';

class InsuranceValidationStep extends StatelessWidget {
  final BookingController controller = Get.find();

  InsuranceValidationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin & Bảo hiểm')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. SUMMARY NHANH BÊN TRÊN
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  _SummaryRow(icon: Icons.person, text: 'ThS.BS Nguyễn Đình Luân'),
                  SizedBox(height: 8),
                  _SummaryRow(icon: Icons.medical_services, text: 'Khoa Nội Tim Mạch'),
                  SizedBox(height: 8),
                  _SummaryRow(icon: Icons.calendar_today, text: 'Sáng Thứ 4 - 07/10/2026'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. KHỐI RADIO BẢO HIỂM BẮT BUỘC
            const Text('Bảo hiểm Y tế (Bắt buộc chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Obx(() => Column(
              children: [
                RadioListTile<bool>(
                  title: const Text('Có sử dụng BHYT'),
                  value: true,
                  groupValue: controller.hasHealthInsurance.value,
                  onChanged: (val) => controller.hasHealthInsurance.value = val!,
                ),
                if (controller.hasHealthInsurance.value)
                  Padding(
                    padding: const EdgeInsets.only(left: 32, right: 16),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('Chọn tuyến BHYT'),
                      value: controller.healthInsuranceType.value,
                      items: const [
                        DropdownMenuItem(value: 'Đúng tuyến', child: Text('Đúng tuyến')),
                        DropdownMenuItem(value: 'Trái tuyến', child: Text('Trái tuyến')),
                        DropdownMenuItem(value: 'Có giấy chuyển viện', child: Text('Có giấy chuyển viện')),
                      ],
                      onChanged: (val) => controller.healthInsuranceType.value = val,
                    ),
                  ),
                RadioListTile<bool>(
                  title: const Text('Không sử dụng BHYT'),
                  value: false,
                  groupValue: controller.hasHealthInsurance.value,
                  onChanged: (val) {
                    controller.hasHealthInsurance.value = val!;
                    controller.healthInsuranceType.value = null; // reset
                  },
                ),
              ],
            )),
            
            const Divider(height: 32),
            const Text('Bảo hiểm tư nhân / Bảo lãnh viện phí', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Obx(() => SwitchListTile(
              title: const Text('Sử dụng bảo hiểm tư nhân'),
              value: controller.hasPrivateInsurance.value,
              onChanged: (val) => controller.hasPrivateInsurance.value = val,
            )),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng tiền', style: TextStyle(color: Colors.grey)),
                    Text('150.000đ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: controller.validateInsuranceStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Tiếp tục'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SummaryRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}
