import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/api_constants.dart';
import '../../../services/booking_api_service.dart';
import '../../../services/fcm_service.dart';
import '../../../widgets/live_queue_tracker_widget.dart';

class ETicketScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;

  const ETicketScreen({Key? key, required this.appointmentData}) : super(key: key);

  @override
  State<ETicketScreen> createState() => _ETicketScreenState();
}

class _ETicketScreenState extends State<ETicketScreen> {
  Timer? _pollTimer;
  bool _isCheckedIn = false;
  late bool _isPaid;
  late String _maLuotKham;
  late String _qrData;

  @override
  void initState() {
    super.initState();
    _maLuotKham = widget.appointmentData['ma_luot_kham']?.toString() ?? '';
    _qrData = _maLuotKham.isNotEmpty
        ? '${ApiConstants.baseUrl}/luot-kham/$_maLuotKham/tiep-nhan'
        : 'TICKET_${DateTime.now().millisecondsSinceEpoch}';

    _isPaid = widget.appointmentData['trang_thai_thanh_toan'] == 'DaThanhToan' ||
        widget.appointmentData['is_paid'] == true ||
        ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh'].contains(widget.appointmentData['trang_thai_kham']) ||
        ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh'].contains(widget.appointmentData['trang_thai']);

    _isCheckedIn = ['cho_kham', 'dang_kham', 'hoan_thanh'].contains(widget.appointmentData['trang_thai_kham']) ||
        ['cho_kham', 'dang_kham', 'hoan_thanh'].contains(widget.appointmentData['trang_thai']) ||
        widget.appointmentData['is_checked_in'] == true;

    // Luôn truy vấn trạng thái mới nhất từ server ngay khi mở màn hình
    _fetchLatestStatus();
  }

  void _fetchLatestStatus() async {
    final id = int.tryParse(_maLuotKham);
    if (id == null) return;
    try {
      final res = await BookingApiService.checkStatus(id);
      final data = res['data'];
      if (data != null && mounted) {
        final bool isPaidServer = data['is_paid'] == true ||
            ['da_thanh_toan', 'cho_kham', 'dang_kham', 'hoan_thanh'].contains(data['trang_thai']);
        final bool isCheckedInServer = data['is_checked_in'] == true ||
            ['cho_kham', 'dang_kham', 'hoan_thanh'].contains(data['trang_thai']);

        setState(() {
          _isPaid = isPaidServer;
          _isCheckedIn = isCheckedInServer;
        });

        if (_isPaid && !_isCheckedIn && _pollTimer == null) {
          _startPollingCheckIn();
        }
      }
    } catch (_) {}
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

            FCMService.showCheckinSuccessNotification(
              title: "🎉 Check-in thành công!",
              body: "Lễ tân đã tiếp nhận phiếu khám #$_maLuotKham của bạn.",
            );
          }
        }
      } catch (e) {
        // Ignore network glitches
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
    final String date = widget.appointmentData['date'] ?? widget.appointmentData['thoi_gian_den_kham'] ?? '15/04/2026';
    final String time = widget.appointmentData['time'] ?? '';
    final String doctor = widget.appointmentData['doctor'] ?? widget.appointmentData['ten_bac_si'] ?? 'Bác sĩ chuyên khoa';
    final String specialty = widget.appointmentData['specialty'] ?? 'Khám Tổng Quát';
    final String room = widget.appointmentData['room'] ?? 'Phòng Khám - Tầng 1';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Phiếu khám điện tử', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'PHÒNG KHÁM HUIT CARE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCheckedIn ? 'Phiếu khám đã tiếp nhận' : 'Phiếu check-in điện tử',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                  
                  // QR Code (Chỉ hiển thị khi đã thanh toán)
                  if (_isPaid) ...[
                    if (_isCheckedIn) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF86EFAC), width: 3),
                        ),
                        child: const Icon(
                          Icons.done_all_rounded,
                          size: 64,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ĐÃ CHECK-IN TIẾP NHẬN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF16A34A)),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF0284C7), width: 2),
                        ),
                        child: QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'MÃ LƯỢT KHÁM: #$_maLuotKham',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Đưa mã này cho Lễ tân quét để check-in',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.payment_outlined, size: 50, color: Colors.amber),
                          SizedBox(height: 12),
                          Text(
                            'Chưa hoàn tất thanh toán',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Vui lòng thanh toán viện phí để nhận mã QR check-in.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                  
                  // Appointment Details
                  _buildDetailRow(Icons.calendar_today, 'Thời gian khám', '$date $time'),
                  _buildDetailRow(Icons.person, 'Bác sĩ', doctor),
                  _buildDetailRow(Icons.medical_services, 'Chuyên khoa', specialty),
                  _buildDetailRow(Icons.room, 'Phòng', room),
                  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isCheckedIn
                          ? Colors.blue.withValues(alpha: 0.1)
                          : (_isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isCheckedIn ? 'Đã tiếp nhận - Chờ khám' : (_isPaid ? 'Đã thanh toán - Chờ check-in' : 'Chờ thanh toán'),
                      style: TextStyle(
                        color: _isCheckedIn
                            ? Colors.blue.shade800
                            : (_isPaid ? Colors.green : Colors.orange.shade800),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tiến trình hàng đợi khám theo thời gian thực (Live Queue Tracker)
            if (_maLuotKham.isNotEmpty && int.tryParse(_maLuotKham) != null) ...[
              const SizedBox(height: 18),
              LiveQueueTrackerWidget(
                maLuotKham: int.parse(_maLuotKham),
                initialDoctorName: doctor,
                initialRoom: room,
                autoPoll: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0056D2)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
