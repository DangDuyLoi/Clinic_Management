import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import 'package:intl/intl.dart';
import '../../../services/vnpay_service.dart';
import '../../../services/fcm_service.dart';
import '../../../screens/home/controllers/notification_controller.dart';
import 'booking_success_screen.dart';
import 'payment_pending_screen.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  late final BookingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BookingController>();
    if (controller.bookedItems.isEmpty) {
      controller.addCurrentBookingToItems();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
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

                // Huy hiệu Diện ưu tiên trên màn hình tóm tắt
                Obx(() {
                  if (controller.hasPriority) {
                    return Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.priorityBadgeText,
                              style: const TextStyle(
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                const SizedBox(height: 24),
                
                Obx(() => Text(
                  'Chuyên khoa đã chọn (${controller.bookedItems.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2C3E50)),
                )),
                
                const SizedBox(height: 12),
                
                // Danh sách các chuyên khoa đã thêm
                Obx(() {
                  final items = controller.bookedItems;
                  if (items.isEmpty) {
                    return const Center(child: Text('Chưa có chuyên khoa nào được chọn.'));
                  }

                  return Column(
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final spec = item['specialty'] as Map<String, dynamic>?;
                      final doc = item['doctor'] as Map<String, dynamic>?;
                      final d = item['date'] as DateTime?;
                      final tSlot = item['timeSlot']?['time'] ?? 'Chưa rõ';

                      final dStr = d != null ? DateFormat('dd/MM/yyyy').format(d) : DateFormat('dd/MM/yyyy').format(DateTime.now());
                      final sName = spec?['name'] ?? spec?['ten_chuyen_khoa'] ?? doc?['chuyen_khoa'] ?? 'Khám chuyên khoa';
                      final rStr = doc?['room'] ?? doc?['phong_kham'] ?? 'Phòng Khám';
                      final dName = doc?['name'] ?? doc?['ho_ten'] ?? '';

                      String sStr = 'Buổi khám';
                      if (tSlot.startsWith('1') && tSlot.compareTo('12:00') > 0) {
                        sStr = 'Buổi chiều';
                      } else if (tSlot != 'Chưa rõ') {
                        sStr = 'Buổi sáng';
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sName,
                                          style: const TextStyle(
                                            color: Color(0xFF0056D2),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        if (dName.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Bác sĩ: $dName',
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Nút xóa chuyên khoa (chỉ khi có nhiều hơn 1 chuyên khoa)
                                  if (items.length > 1)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => controller.removeBookedItem(index),
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
                                            dStr,
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
                                            '$sStr, $rStr',
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
                              child: Builder(builder: (context) {
                                final breakdown = controller.itemCostBreakdown;
                                final itemBreakdown = (index < breakdown.length) ? breakdown[index] : null;
                                final int itemCost = itemBreakdown?['cost'] ?? ((item['price'] ?? 150000) * (index == 0 ? 1.0 : 0.3)).round();
                                final bool isCapped = itemBreakdown?['isCapped'] == true;
                                final String note = itemBreakdown?['capNote'] ?? (index == 0 ? 'Khoa 1 (100% công khám)' : 'Khoa ${index + 1} (30% công khám)');

                                return Column(
                                  children: [
                                    _buildCostRow(
                                      'Tiền khám',
                                      '${NumberFormat('#,###', 'vi_VN').format(itemCost)}đ',
                                      isBoldValue: true,
                                      valueColor: isCapped ? Colors.red.shade700 : const Color(0xFF0056D2),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          isCapped ? Icons.warning_amber_rounded : Icons.info_outline,
                                          size: 13,
                                          color: isCapped ? Colors.red.shade700 : Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            note,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isCapped ? Colors.red.shade700 : Colors.grey.shade600,
                                              fontWeight: isCapped ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _buildCostRow(
                                      'Hình thức',
                                      controller.isBhyt
                                          ? 'BHYT (Mã: ${controller.bhytCardNumber.value})'
                                          : 'Khám Dịch vụ (Giá nội bộ)',
                                    ),
                                  ],
                                );
                              }),
                            ),
                            
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    }),
                  );
                }),
              ],
            ),
          ),
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      
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
              // Chi tiết chi phí BHYT
              Obx(() {
                final formatter = NumberFormat('#,###', 'vi_VN');
                final originalCost = controller.totalOriginalCost;
                final discount = controller.insuranceDiscount;
                final payable = controller.totalBookingCost;

                return Column(
                  children: [
                    // Cảnh báo chạm hoặc vượt trần BHYT 2 lần tiền công khám
                    if (controller.hasExceededBhytCap) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                controller.bhytCapWarningText,
                                style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 11.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Tiền gốc
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tiền khám gốc', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('${formatter.format(originalCost)}đ', style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                    // BHYT chi trả (nếu có)
                    if (discount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.isSmallInvoice
                                ? 'BHYT chi trả (100% - Hóa đơn nhỏ)'
                                : 'BHYT chi trả (${(controller.insuranceRate * 100).round()}%)',
                            style: const TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '- ${formatter.format(discount)}đ',
                            style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Dòng phân cách
                    Container(height: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 8),
                    // Tổng thanh toán
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tổng thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(
                          '${formatter.format(payable)}đ',
                          style: const TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Kích hoạt chức năng thêm chuyên khoa mới thực thụ
                        controller.startAddingNewSpecialty();
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
                      onPressed: () async {
                        // Nếu được miễn đồng chi trả (0đ), xác nhận đặt khám ngay
                        if (controller.totalBookingCost == 0) {
                          controller.paymentMethod.value = 'bhyt_free';
                          var result = await controller.submitBooking();
                          if (result != null) {
                            FCMService.showPaymentSuccessNotification(
                              title: '🎉 Đặt khám BHYT thành công!',
                              body: 'Đặt khám BHYT thành công (Miễn đồng chi trả 0đ). Mã QR check-in đã sẵn sàng.',
                            );
                            Get.offAll(() => BookingSuccessScreen(bookingData: result));
                          }
                          return;
                        }

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
                                    var result = await controller.submitBooking();
                                    if (result != null) {
                                      try {
                                        final notifController = Get.isRegistered<NotificationController>()
                                            ? Get.find<NotificationController>()
                                            : Get.put(NotificationController());
                                        notifController.addNotificationItem(
                                          title: '📅 Đặt khám thành công!',
                                          body: 'Lịch khám của bạn đã được ghi nhận. Vui lòng thanh toán tại quầy khi đến khám.',
                                        );
                                      } catch (_) {}
                                      Get.snackbar('Thành công', 'Đặt khám thành công. Vui lòng thanh toán tại quầy.', backgroundColor: Colors.green, colorText: Colors.white);
                                      Get.offAll(() => BookingSuccessScreen(bookingData: result));
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
                                     
                                     var result = await controller.submitBooking();
                                     if (result == null) return; // Stop if booking failed

                                     final List<dynamic> idList = (result['danh_sach_ma_luot_kham'] is List)
                                         ? (result['danh_sach_ma_luot_kham'] as List)
                                         : [];

                                     String maLuotKhamParam;
                                     int firstId;
                                     if (idList.isNotEmpty) {
                                       maLuotKhamParam = idList.map((e) => e.toString()).join('-');
                                       firstId = int.tryParse(idList.first.toString()) ?? 0;
                                     } else {
                                       int? singleId;
                                       if (result['data'] is Map && result['data']['ma_luot_kham'] != null) {
                                         singleId = int.tryParse(result['data']['ma_luot_kham'].toString());
                                       } else if (result['ma_luot_kham'] != null) {
                                         singleId = int.tryParse(result['ma_luot_kham'].toString());
                                       } else if (result['id'] != null) {
                                         singleId = int.tryParse(result['id'].toString());
                                       }

                                       if (singleId == null) {
                                         Get.snackbar('Lỗi', 'Không lấy được mã lượt khám từ phản hồi của máy chủ.');
                                         return;
                                       }
                                       maLuotKhamParam = singleId.toString();
                                       firstId = singleId;
                                     }

                                     // Tổng tiền theo số lượng chuyên khoa đã đặt
                                     final double amount = controller.totalBookingCost.toDouble();

                                     Get.defaultDialog(
                                       title: 'Đang xử lý',
                                       middleText: 'Đang chuyển đến cổng thanh toán VNPay...',
                                       barrierDismissible: false,
                                     );
                                     
                                     try {
                                       await VNPayService.openPayment(
                                         maLuotKham: maLuotKhamParam,
                                         amount: amount,
                                         orderInfo: 'Thanh toan phi kham luot #$maLuotKhamParam',
                                       );
                                       if (Get.isDialogOpen ?? false) Get.back(); // Đóng dialog

                                       // Chuyển sang màn hình chờ thanh toán (chưa xuất QR)
                                       Get.to(() => PaymentPendingScreen(
                                         maLuotKham: firstId,
                                         maLuotKhamParam: maLuotKhamParam,
                                         bookingData: result,
                                         amount: amount,
                                       ));
                                    } catch (e) {
                                      if (Get.isDialogOpen ?? false) Get.back(); // Đóng dialog
                                      Get.snackbar('Lỗi Thanh Toán', 'Không thể mở VNPay: $e',
                                          backgroundColor: Colors.red, colorText: Colors.white, duration: const Duration(seconds: 5));
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
