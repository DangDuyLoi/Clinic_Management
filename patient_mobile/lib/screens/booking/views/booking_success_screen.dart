import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/booking_api_service.dart';
import '../../../services/fcm_service.dart';
import '../../../widgets/live_queue_tracker_widget.dart';
import '../../main/main_screen.dart';

class BookingSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingSuccessScreen({super.key, required this.bookingData});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> {
  Timer? _pollTimer;
  bool _isCheckedIn = false;
  late String _maLuotKham;
  late String _qrUrl;

  @override
  void initState() {
    super.initState();
    // Trích xuất mã lượt khám từ các cấu trúc dữ liệu khác nhau
    if (widget.bookingData['data'] is Map && widget.bookingData['data']['ma_luot_kham'] != null) {
      _maLuotKham = widget.bookingData['data']['ma_luot_kham'].toString();
    } else if (widget.bookingData['ma_luot_kham'] != null) {
      _maLuotKham = widget.bookingData['ma_luot_kham'].toString();
    } else if (widget.bookingData['id'] != null) {
      _maLuotKham = widget.bookingData['id'].toString();
    } else {
      _maLuotKham = '1';
    }

    _qrUrl = '${ApiConstants.baseUrl}/luot-kham/$_maLuotKham/tiep-nhan';

    // Bắt đầu lắng nghe trạng thái check-in thời gian thực (Polling mỗi 3 giây)
    _startPollingCheckIn();
  }

  void _startPollingCheckIn() {
    final id = int.tryParse(_maLuotKham);
    if (id == null) return;

    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final res = await BookingApiService.checkStatus(id);
        final data = res['data'];
        if (data != null && mounted) {
          final bool checkedIn = data['is_checked_in'] == true ||
              ['cho_kham', 'dang_kham', 'hoan_thanh'].contains(data['trang_thai']);

          if (checkedIn && !_isCheckedIn) {
            timer.cancel();
            setState(() {
              _isCheckedIn = true;
            });

            // Hiển thị thông báo đẩy nổi (Snackbar)
            FCMService.showCheckinSuccessNotification(
              title: "🎉 Check-in thành công!",
              body: "Lễ tân đã tiếp nhận lượt khám #$_maLuotKham. Vui lòng ngồi chờ đến lượt khám.",
            );

            // Hiển thị hộp thoại chúc mừng
            Get.defaultDialog(
              title: "🎉 Tiếp nhận thành công!",
              titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 18),
              middleText: "Lễ tân đã check-in cho bạn thành công!\nVui lòng ngồi tại phòng chờ, bác sĩ sẽ sớm gọi tên bạn.",
              middleTextStyle: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
              textConfirm: "Đã hiểu",
              confirmTextColor: Colors.white,
              buttonColor: const Color(0xFF059669),
              onConfirm: () => Get.back(),
            );
          }
        }
      } catch (e) {
        // Im lặng khi poll gặp lỗi mạng tạm thời
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAll(() => const MainScreen());
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            _isCheckedIn ? 'Đã Tiếp Nhận Thành Công' : 'Mã QR Check-in',
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () => Get.offAll(() => const MainScreen()),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header trạng thái
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isCheckedIn ? const Color(0xFFDCFCE7) : const Color(0xFFE6F9F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCheckedIn ? const Color(0xFF22C55E) : const Color(0xFFA7F3D0),
                    width: _isCheckedIn ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCheckedIn ? Icons.verified : Icons.check_circle,
                      color: const Color(0xFF059669),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isCheckedIn ? 'Đã tiếp nhận vào phòng khám' : 'Đã thanh toán VNPay thành công',
                      style: const TextStyle(
                        color: Color(0xFF065F46),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                _isCheckedIn ? 'TIẾP NHẬN THÀNH CÔNG!' : 'Mã Tiếp Nhận Khám Bệnh',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _isCheckedIn ? const Color(0xFF059669) : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isCheckedIn
                    ? 'Bạn đã được hoàn tất thủ tục check-in. Vui lòng ngồi tại sảnh chờ, bác sĩ sẽ gọi tên bạn sớm.'
                    : 'Vui lòng đưa mã QR này cho Lễ tân quét để check-in khi bạn đến phòng khám.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
              ),

              const SizedBox(height: 24),

              // Thẻ hiển thị QR Code hoặc Huy hiệu Check-in thành công
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isCheckedIn) ...[
                      // Huy hiệu tiếp nhận thành công
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF86EFAC), width: 3),
                        ),
                        child: const Icon(
                          Icons.done_all_rounded,
                          size: 72,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ĐÃ CHECK-IN XONG',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF16A34A),
                          letterSpacing: 1,
                        ),
                      ),
                    ] else ...[
                      // QR Code để lễ tân quét
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: _qrUrl,
                          version: QrVersions.auto,
                          size: 220.0,
                          backgroundColor: Colors.white,
                          errorCorrectionLevel: QrErrorCorrectLevel.M,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Text(
                      'MÃ LƯỢT KHÁM: #$_maLuotKham',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0284C7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isCheckedIn
                          ? 'Trạng thái: Chờ khám bệnh (Đang chờ bác sĩ gọi)'
                          : 'Trạng thái: Đã thanh toán — Chờ tiếp nhận',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _isCheckedIn ? FontWeight.bold : FontWeight.normal,
                        color: _isCheckedIn ? const Color(0xFF15803D) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Thẻ thông báo trạng thái
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCheckedIn ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isCheckedIn ? const Color(0xFFBBF7D0) : const Color(0xFFBFDBFE),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCheckedIn ? Icons.how_to_reg : Icons.notifications_active_outlined,
                      color: _isCheckedIn ? const Color(0xFF16A34A) : const Color(0xFF1D4ED8),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isCheckedIn
                            ? 'Lượt khám của bạn đã được đưa vào danh sách chờ khám của bác sĩ.'
                            : 'Sau khi lễ tân quét mã, điện thoại sẽ tự động nhận thông báo xác nhận check-in ngay lập tức.',
                        style: TextStyle(
                          fontSize: 13,
                          color: _isCheckedIn ? const Color(0xFF15803D) : const Color(0xFF1E40AF),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tiến trình hàng đợi theo thời gian thực (Live Queue Tracker)
              if (int.tryParse(_maLuotKham) != null) ...[
                const SizedBox(height: 20),
                LiveQueueTrackerWidget(
                  maLuotKham: int.parse(_maLuotKham),
                  autoPoll: true,
                ),
              ],

              const SizedBox(height: 24),

              // Nút về trang chủ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => const MainScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Hoàn tất & Về trang chủ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
