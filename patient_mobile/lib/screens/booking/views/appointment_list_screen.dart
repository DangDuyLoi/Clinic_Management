import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'e_ticket_screen.dart';
import '../../../services/booking_api_service.dart';
import '../../../services/patient_profile_service.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Lấy danh sách mã hồ sơ của người dùng hiện tại
      final profileIds = PatientProfileService.cachedProfiles
          .map((p) => p['ma_ho_so'] as int)
          .toList();

      if (profileIds.isEmpty) {
        setState(() {
          _appointments = [];
          _isLoading = false;
        });
        return;
      }

      final data = await BookingApiService.fetchAppointments(profileIds);
      
      setState(() {
        _appointments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải danh sách lịch khám. Vui lòng thử lại sau.\nLỗi: $e';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String datetimeStr) {
    try {
      final dt = DateTime.parse(datetimeStr);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return datetimeStr;
    }
  }

  String _formatTime(String datetimeStr) {
    try {
      final dt = DateTime.parse(datetimeStr);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return datetimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Lịch khám của tôi', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text('Thử lại'),
              )
            ],
          ),
        ),
      );
    }

    if (_appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, color: Colors.black26, size: 64),
            SizedBox(height: 16),
            Text(
              'Bạn chưa có lịch khám nào',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final apt = _appointments[index];
          final isPaid = apt['trang_thai_thanh_toan'] == 'DaThanhToan';
          final statusText = isPaid ? 'Đã thanh toán' : 'Chưa thanh toán';
          
          // Chuyển đổi dữ liệu để truyền vào ETicketScreen
          final formattedApt = {
            'ma_luot_kham': apt['ma_luot_kham']?.toString() ?? '',
            'date': _formatDate(apt['thoi_gian_den_kham'] ?? ''),
            'time': _formatTime(apt['thoi_gian_den_kham'] ?? ''),
            'doctor': apt['ten_bac_si'] ?? 'Đang cập nhật',
            'specialty': 'Khám Bệnh', // Backend chưa trả về chuyên khoa
            'room': 'Đang sắp xếp', 
          };

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isPaid ? const Color(0xFF0056D2).withOpacity(0.05) : Colors.orange.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedApt['date']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPaid ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: isPaid ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0056D2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.access_time, color: Color(0xFF0056D2), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formattedApt['time']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.black54, size: 20),
                          const SizedBox(width: 8),
                          Text(formattedApt['doctor']!, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, color: Colors.black54, size: 20),
                          const SizedBox(width: 8),
                          Text('Bệnh nhân: ${apt['ten_benh_nhan'] ?? ''}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (isPaid) ...[
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.to(() => ETicketScreen(appointmentData: formattedApt));
                            },
                            icon: const Icon(Icons.qr_code),
                            label: const Text('Xem mã QR Check-in'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0056D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ] else ...[
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              // Chuyển tới màn hình thanh toán
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Thanh toán ngay'),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
