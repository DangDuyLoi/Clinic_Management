import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ETicketScreen extends StatelessWidget {
  final Map<String, dynamic> appointmentData;

  const ETicketScreen({Key? key, required this.appointmentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String qrData = appointmentData['ma_luot_kham']?.toString() ?? 'TICKET_${DateTime.now().millisecondsSinceEpoch}';
    final String date = appointmentData['date'] ?? '15/04/2026';
    final String time = appointmentData['time'] ?? '08:30';
    final String doctor = appointmentData['doctor'] ?? 'ThS.BS Nguyễn Văn A';
    final String specialty = appointmentData['specialty'] ?? 'Chuyên khoa Tim mạch';
    final String room = appointmentData['room'] ?? 'Phòng 204 - Tầng 2';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Phiếu khám điện tử', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'PHÒNG KHÁM TÀI PHÚ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Phiếu check-in điện tử',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                  
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE), width: 2),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Quét mã này tại máy Kiosk hoặc Quầy tiếp đón',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.redAccent, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 16),
                  
                  const Divider(height: 32, thickness: 1, color: Color(0xFFEEEEEE)),
                  
                  // Appointment Details
                  _buildDetailRow(Icons.calendar_today, 'Ngày khám', date),
                  _buildDetailRow(Icons.access_time, 'Giờ khám', time),
                  _buildDetailRow(Icons.person, 'Bác sĩ', doctor),
                  _buildDetailRow(Icons.medical_services, 'Chuyên khoa', specialty),
                  _buildDetailRow(Icons.room, 'Phòng', room),
                  
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Đã thanh toán',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
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
