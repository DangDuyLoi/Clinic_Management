import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/booking_api_service.dart';
import '../../../services/vnpay_service.dart';
import '../../../services/fcm_service.dart';
import '../../main/main_screen.dart';
import 'booking_success_screen.dart';

class PaymentPendingScreen extends StatefulWidget {
  final int maLuotKham;
  final String? maLuotKhamParam;
  final Map<String, dynamic> bookingData;
  final double amount;

  const PaymentPendingScreen({
    super.key,
    required this.maLuotKham,
    this.maLuotKhamParam,
    required this.bookingData,
    this.amount = 150000,
  });

  @override
  State<PaymentPendingScreen> createState() => _PaymentPendingScreenState();
}

class _PaymentPendingScreenState extends State<PaymentPendingScreen>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;
  bool _isChecking = false;
  String _statusText = 'Đang chờ bạn hoàn tất thanh toán trên VNPay...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi người dùng quay lại từ trình duyệt web VNPay, kiểm tra ngay lập tức
      _checkPaymentStatus();
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final res = await BookingApiService.checkStatus(widget.maLuotKham);
      final data = res['data'];

      if (data != null && data['is_paid'] == true) {
        _pollingTimer?.cancel();
        
        setState(() {
          _statusText = 'Thanh toán thành công! Đang tạo mã QR...';
        });

        // Hợp nhất dữ liệu bookingData ban đầu với dữ liệu mới từ backend
        final mergedData = Map<String, dynamic>.from(widget.bookingData);
        if (mergedData['data'] is Map) {
          mergedData['data']['trang_thai'] = data['trang_thai'];
          mergedData['data']['is_paid'] = true;
        } else {
          mergedData['trang_thai'] = data['trang_thai'];
          mergedData['is_paid'] = true;
          mergedData['ma_luot_kham'] = widget.maLuotKham;
        }

        await Future.delayed(const Duration(milliseconds: 600));

        // Bắn thông báo thanh toán thành công và lưu vào tab Thông báo
        FCMService.showPaymentSuccessNotification(
          body: "Thanh toán thành công cho lượt khám #${widget.maLuotKham}. Mã QR check-in đã sẵn sàng.",
        );

        // Chuyển sang màn hình BookingSuccessScreen chứa QR Code
        Get.off(() => BookingSuccessScreen(bookingData: mergedData));
      }
    } catch (e) {
      print('Polling error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _reopenVNPay() async {
    try {
      final param = widget.maLuotKhamParam ?? widget.maLuotKham.toString();
      await VNPayService.openPayment(
        maLuotKham: param,
        amount: widget.amount,
        orderInfo: 'Thanh toan lai luot #$param',
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể mở VNPay: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hủy chờ thanh toán?'),
            content: const Text(
              'Lịch khám đã được tạo. Bạn có thể thanh toán sau trong mục lịch khám hoặc quay lại trang chủ.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Ở lại'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  Get.offAll(() => const MainScreen());
                },
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Thanh toán VNPay',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.offAll(() => const MainScreen()),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                
                // Animated pulse container
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Đang chờ xác nhận thanh toán',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Box thông tin
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow('Mã lượt khám:', '#${widget.maLuotKham}'),
                      const Divider(height: 20, thickness: 0.8),
                      _buildInfoRow(
                        'Số tiền cần thanh toán:',
                        '${widget.amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                        isHighlight: true,
                      ),
                      const Divider(height: 20, thickness: 0.8),
                      _buildInfoRow('Cổng thanh toán:', 'VNPay Sandbox'),
                      const Divider(height: 20, thickness: 0.8),
                      _buildInfoRow('Trạng thái:', 'Chờ thanh toán', statusColor: Colors.orange),
                    ],
                  ),
                ),
                
                const SizedBox(height: 36),
                
                // Nút kiểm tra ngay
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _checkPaymentStatus,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Tôi đã thanh toán xong',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Nút mở lại VNPay nếu bị tắt
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _reopenVNPay,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      '🌐 Mở lại trang thanh toán VNPay',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: () => Get.offAll(() => const MainScreen()),
                  child: const Text(
                    'Để sau, quay về trang chủ',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isHighlight = false, Color? statusColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: statusColor ??
                (isHighlight ? const Color(0xFF0284C7) : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
