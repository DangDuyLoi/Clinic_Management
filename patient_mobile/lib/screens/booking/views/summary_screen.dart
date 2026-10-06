import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import 'package:intl/intl.dart';
import '../../home/home_screen.dart';
import '../../../services/vnpay_service.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookingController controller = Get.find<BookingController>();
    
    // Fallbacks just in case
    final date = controller.selectedDate.value;
    final timeSlot = controller.selectedTimeSlot.value?['time'] ?? 'Chưa rõ';
    final doctor = controller.selectedDoctor.value;
    final specialty = controller.selectedSpecialty.value;

    final dateStr = date != null ? DateFormat('dd/MM/yyyy').format(date) : '30/09/2026';
    final specialtyName = specialty?['name'] ?? 'BỆNH LÝ CỘT SỐNG';
    final priceStr = specialty?['price'] ?? '150.000đ';
    final roomStr = doctor?['room'] ?? 'Phòng 66 - Lầu 1 Khu B';
    
    // Check if afternoon or morning
    String shiftStr = 'Buổi khám';
    if (timeSlot.startsWith('1') && timeSlot.compareTo('12:00') > 0) {
      shiftStr = 'Buổi chiều';
    } else if (timeSlot != 'Chưa rõ') {
      shiftStr = 'Buổi sáng';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Thông tin đặt khám',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Vui lòng kiểm tra thông tin đặt khám bên dưới.\nHoặc "Thêm chuyên khoa" mới.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Hồ sơ người bệnh dropdown-like button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.blue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Hồ sơ người bệnh',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Chuyên khoa đã chọn (1)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                ),
                
                const SizedBox(height: 12),
                
                // Specialty Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                specialtyName,
                                style: const TextStyle(
                                  color: Color(0xFF0056D2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                            ),
                          ],
                        ),
                      ),
                      
                      // Date and Time Box
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text('Ngày khám', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 40, color: Colors.grey.shade300),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                        const SizedBox(width: 4),
                                        Text('Phòng - Giờ khám', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$shiftStr, $roomStr',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Cost details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            _buildCostRow('Tiền khám', priceStr, isBoldValue: true, valueColor: const Color(0xFF0056D2)),
                            const SizedBox(height: 12),
                            _buildCostRow('BHYT', 'Không'),
                            const SizedBox(height: 12),
                            _buildCostRow('Bảo hiểm tư nhân', 'Không'),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (controller.isLoading.value)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )),
      
      // Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tổng tiền khám', style: TextStyle(color: Colors.grey, fontSize: 15)),
                  Text(
                    priceStr,
                    style: const TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Go back to add another specialty
                        Get.back(); 
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF0056D2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Color(0xFF0056D2), size: 18),
                          SizedBox(width: 4),
                          Text('Thêm chuyên khoa', style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Hiện BottomSheet chọn phương thức thanh toán
                        Get.bottomSheet(
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Chọn phương thức thanh toán',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                ListTile(
                                  leading: const Icon(Icons.money, color: Colors.green),
                                  title: const Text('Thanh toán tại quầy'),
                                  subtitle: const Text('Thanh toán tiền mặt khi đến khám'),
                                  onTap: () async {
                                    Get.back(); // Đóng bottom sheet
                                    await Future.delayed(const Duration(milliseconds: 300)); // Đợi bottom sheet đóng hẳn
                                    controller.paymentMethod.value = 'cash';
                                    bool success = await controller.submitBooking();
                                    if (success) {
                                      Get.snackbar('Thành công', 'Đặt khám thành công. Vui lòng thanh toán tại quầy.', backgroundColor: Colors.green, colorText: Colors.white);
                                      Get.offAll(() => const HomeScreen()); // Trở về trang chủ
                                    }
                                  },
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
                                  title: const Text('Thanh toán qua VNPay'),
                                  subtitle: const Text('Thanh toán online an toàn'),
                                  onTap: () async {
                                    Get.back(); // Đóng bottom sheet
                                    await Future.delayed(const Duration(milliseconds: 300)); // Đợi bottom sheet đóng hẳn
                                    controller.paymentMethod.value = 'vnpay';
                                    
                                    bool success = await controller.submitBooking();
                                    if (!success) return; // Stop if booking failed

                                    // Parse price string to double (ví dụ: '150.000đ' -> 150000)
                                    double amount = 150000;
                                    try {
                                      String numStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
                                      if (numStr.isNotEmpty) amount = double.parse(numStr);
                                    } catch (e) {}

                                    Get.defaultDialog(
                                      title: 'Đang xử lý',
                                      middleText: 'Đang tạo liên kết thanh toán VNPay...',
                                      barrierDismissible: false,
                                    );
                                    
                                    try {
                                      await VNPayService.openPayment(amount, 'Thanh toan vien phi');
                                      if (Get.isDialogOpen ?? false) Get.back(); // Đóng dialog
                                    } catch (e) {
                                      if (Get.isDialogOpen ?? false) Get.back(); // Đóng dialog
                                      Get.snackbar('Lỗi Thanh Toán', 'Không thể mở VNPay: $e', backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          isScrollControlled: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Tiếp tục', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isBoldValue = false, Color valueColor = Colors.black54}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            fontSize: isBoldValue ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
