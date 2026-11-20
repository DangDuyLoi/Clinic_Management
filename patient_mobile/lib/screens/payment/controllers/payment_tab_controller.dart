import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../services/booking_api_service.dart';
import '../../../services/vnpay_service.dart';

typedef PaymentDataLoader = Future<Map<String, dynamic>> Function();

/// Controller quản lý nghiệp vụ và trạng thái Thanh toán viện phí
class PaymentTabController extends GetxController {
  PaymentTabController({PaymentDataLoader? paymentDataLoader})
    : _paymentDataLoader =
          paymentDataLoader ?? BookingApiService.fetchPaymentBills;

  final PaymentDataLoader _paymentDataLoader;

  // ================= 1. OBSERVABLE STATE =================
  /// Trạng thái đang tải dữ liệu
  final isLoading = true.obs;

  final errorMessage = RxnString();

  /// Danh sách phiếu viện phí chờ thanh toán
  final pendingBills = <Map<String, dynamic>>[].obs;

  /// Danh sách lịch sử giao dịch đã thanh toán
  final paymentHistory = <Map<String, dynamic>>[].obs;

  // ================= 2. FETCH DATA LOGIC =================
  /// Lấy đồng thời danh sách phiếu chờ thanh toán và lịch sử giao dịch đồng bộ từ Database
  Future<void> fetchPaymentData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      final data = await _paymentDataLoader();
      final pending = _parseBills(
        data['pending_bills'],
        'hóa đơn chờ thanh toán',
      );
      final history = _parseBills(
        data['payment_history'],
        'lịch sử thanh toán',
      );
      pendingBills.assignAll(pending);
      paymentHistory.assignAll(history);
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu thanh toán: $e');
      pendingBills.clear();
      paymentHistory.clear();
      errorMessage.value =
          'Không thể tải dữ liệu viện phí. Vui lòng thử lại. ($e)';
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _parseBills(dynamic value, String label) {
    if (value is! List) {
      throw FormatException('Dữ liệu $label không hợp lệ.');
    }
    return value.map((item) {
      if (item is! Map) {
        throw FormatException('Một mục trong $label không hợp lệ.');
      }
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  void clearData() {
    pendingBills.clear();
    paymentHistory.clear();
    errorMessage.value = null;
  }

  // ================= 3. PAYMENT LOGIC =================
  /// Khởi tạo và mở giao diện thanh toán VNPay theo mã lượt khám
  Future<void> payBill(int maLuotKham) async {
    try {
      // Tìm phiếu viện phí tương ứng
      final bill = pendingBills.firstWhereOrNull(
        (b) => b['ma_luot_kham'] == maLuotKham,
      );
      if (bill == null) {
        throw Exception('Không tìm thấy hóa đơn. Vui lòng tải lại danh sách.');
      }
      final amountValue = bill['tong_tien'];
      if (amountValue is! num || amountValue <= 0) {
        throw Exception(
          'Số tiền hóa đơn không hợp lệ. Vui lòng tải lại danh sách.',
        );
      }
      final amount = amountValue.toDouble();

      // Hiển thị dialog đang kết nối cổng VNPay
      Get.dialog(
        const Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Đang kết nối cổng thanh toán VNPay...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Gọi đến VNPayService.openPayment()
      await VNPayService.openPayment(
        maLuotKham: maLuotKham,
        amount: amount,
        orderInfo: 'Thanh toan vien phi ma luot kham $maLuotKham',
      );

      // Đóng dialog loading
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Cổng thanh toán VNPay',
        'Đã mở liên kết thanh toán trên trình duyệt. Vui lòng hoàn tất thanh toán.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0056A6),
        colorText: Colors.white,
        icon: const Icon(Icons.payment, color: Colors.white),
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        'Lỗi thanh toán',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // ================= 4. UTILS =================
  /// Định dạng số tiền sang định dạng tiền tệ Việt Nam (VNĐ)
  String formatCurrency(num amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} đ';
  }
}
