import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/auth_service.dart';
import '../../../services/vnpay_service.dart';

/// Controller quản lý nghiệp vụ và trạng thái Thanh toán viện phí
class PaymentTabController extends GetxController {
  // ================= 1. OBSERVABLE STATE =================
  /// Trạng thái đang tải dữ liệu
  final isLoading = false.obs;

  /// Danh sách phiếu viện phí chờ thanh toán
  final pendingBills = <Map<String, dynamic>>[].obs;

  /// Danh sách lịch sử giao dịch đã thanh toán
  final paymentHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Tự động tải dữ liệu sau khi build frame kết thúc để tránh lỗi setState trong lúc build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPaymentData();
    });
  }

  // ================= 2. FETCH DATA LOGIC =================
  /// Lấy đồng thời danh sách phiếu chờ thanh toán và lịch sử giao dịch đồng bộ từ Database
  Future<void> fetchPaymentData() async {
    try {
      isLoading.value = true;

      final authService = AuthService();
      final phone = await authService.getUserPhone() ?? '0374244315';

      final url = Uri.parse('${ApiConstants.baseUrl}/payment/bills?phone=$phone');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 7));

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        final data = resData['data'];
        if (data != null) {
          final List<dynamic> pendingRaw = data['pending_bills'] ?? [];
          final List<dynamic> historyRaw = data['payment_history'] ?? [];

          final pending = pendingRaw.map((e) => Map<String, dynamic>.from(e)).toList();
          final history = historyRaw.map((e) => Map<String, dynamic>.from(e)).toList();

          pendingBills.assignAll(pending);
          paymentHistory.assignAll(history);
          return;
        }
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu thanh toán: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ================= 3. PAYMENT LOGIC =================
  /// Khởi tạo và mở giao diện thanh toán VNPay theo mã lượt khám
  Future<void> payBill(int maLuotKham) async {
    try {
      // Tìm phiếu viện phí tương ứng
      final bill = pendingBills.firstWhereOrNull(
        (b) => b['ma_luot_kham'] == maLuotKham,
      );

      final double amount = bill != null
          ? (bill['tong_tien'] as num).toDouble()
          : 150000.0;

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

      // Sau khi thanh toán xong, gọi lại fetchPaymentData() để cập nhật UI
      await fetchPaymentData();
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
