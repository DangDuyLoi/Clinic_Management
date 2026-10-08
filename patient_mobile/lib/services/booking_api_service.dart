import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingApiService {
  static const String baseUrl = 'http://192.168.1.84:8000/api';

  // Lấy giờ trống của bác sĩ
  static Future<List<String>> getAvailableTimeSlots(int doctorId, String dateStr) async {
    final response = await http.get(Uri.parse('$baseUrl/luot-kham/gio-trong?ma_bac_si=$doctorId&ngay_kham=$dateStr'));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['danh_sach_gio_trong']);
    } else {
      throw Exception('Failed to load available time slots');
    }
  }

  // Đặt lịch khám
  static Future<Map<String, dynamic>> createBooking({
    required int maHoSo,
    required int maBacSi,
    required String thoiGianDenKham, // format: Y-m-d H:i:s
  }) async {
    print("DEBUG: Sending createBooking request with thoiGianDenKham = '$thoiGianDenKham'");
    final response = await http.post(
      Uri.parse('$baseUrl/luot-kham/dat-lich'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'ma_ho_so': maHoSo,
        'ma_bac_si': maBacSi,
        'thoi_gian_den_kham': thoiGianDenKham,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorData = jsonDecode(response.body);
      String errorMessage = errorData['message'] ?? 'Failed to create booking';
      if (errorData['errors'] != null) {
        errorMessage += '\n' + errorData['errors'].toString();
      }
      throw Exception(errorMessage);
    }
  }

  // Lấy danh sách lượt khám theo danh sách mã hồ sơ
  static Future<List<Map<String, dynamic>>> fetchAppointments(List<int> maHoSoList) async {
    final response = await http.post(
      Uri.parse('$baseUrl/luot-kham/danh-sach'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'danh_sach_ma_ho_so': maHoSoList,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to load appointments');
    }
  }
}
