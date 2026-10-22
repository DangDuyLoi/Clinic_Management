import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class BookingApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  /// Format giá tiền Việt Nam: 150000 → "150.000", 200000 → "200.000"
  static String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  // Lấy danh sách chuyên khoa từ MySQL
  static Future<List<Map<String, dynamic>>> fetchSpecialties() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chuyen-khoa'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = (json['data'] ?? []) as List;
      return list.map<Map<String, dynamic>>((item) {
        final giaKham = (item['gia_kham'] != null)
            ? double.tryParse(item['gia_kham'].toString()) ?? 150000
            : 150000.0;
        final giaKhamInt = giaKham.round();
        // Format giá: 150000 → "150.000đ", 200000 → "200.000đ"
        final priceStr = '${_formatPrice(giaKhamInt)}đ';
        return {
          'id': item['ma_chuyen_khoa'].toString(),
          'ma_chuyen_khoa': item['ma_chuyen_khoa'],
          'name': (item['ten_chuyen_khoa'] ?? '').toString().toUpperCase(),
          'price': priceStr,
          'gia_kham': giaKhamInt, // Giá số nguyên (int) để tính toán BHYT
          'desc': item['mo_ta'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Không thể tải danh sách chuyên khoa');
    }
  }

  // Lấy danh sách bác sĩ từ MySQL (có thể lọc theo chuyên khoa)
  static Future<List<Map<String, dynamic>>> fetchDoctors({int? maChuyenKhoa}) async {
    String url = '$baseUrl/bac-si';
    if (maChuyenKhoa != null) {
      url += '?ma_chuyen_khoa=$maChuyenKhoa';
    }
    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = (json['data'] ?? []) as List;
      return List<Map<String, dynamic>>.from(list);
    } else {
      throw Exception('Không thể tải danh sách bác sĩ');
    }
  }

  // Lấy danh sách khung giờ từ MySQL
  static Future<List<Map<String, dynamic>>> fetchKhungGio() async {
    final response = await http.get(
      Uri.parse('$baseUrl/khung-gio'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = (json['data'] ?? []) as List;
      return List<Map<String, dynamic>>.from(list);
    } else {
      throw Exception('Không thể tải khung giờ');
    }
  }

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
        'Accept': 'application/json',
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
        'Accept': 'application/json',
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

  // Kiểm tra trạng thái lượt khám (dùng cho polling thanh toán và check-in)
  static Future<Map<String, dynamic>> checkStatus(int maLuotKham) async {
    final response = await http.get(
      Uri.parse('$baseUrl/luot-kham/$maLuotKham/check-status'),
      headers: <String, String>{
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể kiểm tra trạng thái lượt khám #$maLuotKham');
    }
  }

  // Check-in lượt khám (tiếp nhận)
  static Future<Map<String, dynamic>> checkIn(int maLuotKham) async {
    final response = await http.put(
      Uri.parse('$baseUrl/luot-kham/$maLuotKham/tiep-nhan'),
      headers: <String, String>{
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Check-in thất bại');
    }
  }

  /// Theo dõi tiến trình hàng đợi khám theo thời gian thực (Live Queue Tracker)
  static Future<Map<String, dynamic>> getQueueStatus(
    int maLuotKham, {
    int? stt,
    int? dangPhucVu,
    bool triggerPush = false,
  }) async {
    String url = '$baseUrl/luot-kham/$maLuotKham/hang-doi';
    final queryParams = <String>[];
    if (stt != null) queryParams.add('stt=$stt');
    if (dangPhucVu != null) queryParams.add('dang_phuc_vu=$dangPhucVu');
    if (triggerPush) queryParams.add('trigger_push=true');
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể tải tiến trình hàng đợi của lượt khám #$maLuotKham');
    }
  }

  /// Kích hoạt thông báo đẩy FCM khi sắp đến lượt khám
  static Future<Map<String, dynamic>> triggerQueueNotification(
    int maLuotKham, {
    int stt = 18,
    int dangPhucVu = 15,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/luot-kham/$maLuotKham/thong-bao-sap-den-luot'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'stt': stt,
        'dang_phuc_vu': dangPhucVu,
      }),
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gửi thông báo đẩy thất bại');
    }
  }
}
