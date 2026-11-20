import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

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
    final response = await http
        .get(
          Uri.parse('$baseUrl/chuyen-khoa'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

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
  static Future<List<Map<String, dynamic>>> fetchDoctors({
    int? maChuyenKhoa,
  }) async {
    String url = '$baseUrl/bac-si';
    if (maChuyenKhoa != null) {
      url += '?ma_chuyen_khoa=$maChuyenKhoa';
    }
    final response = await http
        .get(Uri.parse(url), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));

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
    final response = await http
        .get(
          Uri.parse('$baseUrl/khung-gio'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final list = (json['data'] ?? []) as List;
      return List<Map<String, dynamic>>.from(list);
    } else {
      throw Exception('Không thể tải khung giờ');
    }
  }

  // Lấy giờ trống của bác sĩ
  static Future<List<String>> getAvailableTimeSlots(
    int doctorId,
    String dateStr,
  ) async {
    final url =
        '$baseUrl/luot-kham/gio-trong?ma_bac_si=$doctorId&ngay_kham=$dateStr';
    print('🔵 [DEBUG] Gọi API gio-trong: $url');

    try {
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('🟢 [DEBUG] Response status: ${response.statusCode}');
      print('🟢 [DEBUG] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = List<String>.from(data['danh_sach_gio_trong'] ?? []);
        print('✅ [DEBUG] Số giờ trống nhận được: ${list.length}');
        return list;
      } else {
        print('❌ [DEBUG] API trả lỗi: ${response.statusCode}');
        throw Exception('Failed: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 [DEBUG] Exception: $e');
      rethrow;
    }
  }

  // Đặt lịch khám
  static Future<Map<String, dynamic>> createBooking({
    required int maHoSo,
    required int maBacSi,
    required String thoiGianDenKham, // format: Y-m-d H:i:s
    int priorityLevel = 4,
    String? trangThai,
    num? soTien,
    String? maTheBhyt,
    bool isBhyt = false,
  }) async {
    final bodyData = <String, dynamic>{
      'ma_ho_so': maHoSo,
      'ma_bac_si': maBacSi,
      'thoi_gian_den_kham': thoiGianDenKham,
      'priority_level': priorityLevel,
    };
    if (trangThai != null) bodyData['trang_thai'] = trangThai;
    if (soTien != null) bodyData['so_tien'] = soTien;
    if (maTheBhyt != null && maTheBhyt.isNotEmpty)
      bodyData['ma_the_bhyt'] = maTheBhyt;
    if (isBhyt) bodyData['is_bhyt'] = true;

    final response = await http
        .post(
          Uri.parse('$baseUrl/luot-kham/dat-lich'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
          },
          body: jsonEncode(bodyData),
        )
        .timeout(const Duration(seconds: 10));

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

  /// Tra cứu thẻ BHYT & Giám định phòng chống trục lợi gom thuốc
  static Future<Map<String, dynamic>> checkBhytFraudWarning({
    required String maThe,
    int? maHoSo,
  }) async {
    try {
      String url =
          '$baseUrl/bhxh/tra-cuu-the?ma_the=${Uri.encodeComponent(maThe)}';
      if (maHoSo != null) {
        url += '&ma_ho_so=$maHoSo';
      }
      final response = await http
          .get(Uri.parse(url), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {'status': 'unknown', 'is_blacklisted': false};
  }

  // Hủy giữ chỗ lượt khám (khi chưa thanh toán)
  static Future<bool> cancelBooking(int maLuotKham) async {
    try {
      final token = await AuthService().getToken();
      final response = await http
          .post(
            Uri.parse('$baseUrl/luot-kham/$maLuotKham/huy'),
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> fetchPaymentBills() async {
    final token = await AuthService().getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/payment/bills'),
          headers: <String, String>{
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Không thể tải danh sách viện phí (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['status'] != 'success' ||
        decoded['data'] is! Map<String, dynamic>) {
      throw const FormatException('Dữ liệu viện phí từ máy chủ không hợp lệ.');
    }

    final data = decoded['data'] as Map<String, dynamic>;
    final pendingBills = data['pending_bills'];
    final paymentHistory = data['payment_history'];
    if (pendingBills is! List || paymentHistory is! List) {
      throw const FormatException('Danh sách hóa đơn từ máy chủ không hợp lệ.');
    }

    return <String, dynamic>{
      'pending_bills': List<Map<String, dynamic>>.from(pendingBills),
      'payment_history': List<Map<String, dynamic>>.from(paymentHistory),
    };
  }

  // Lấy danh sách lượt khám theo danh sách mã hồ sơ
  static Future<List<Map<String, dynamic>>> fetchAppointments(
    List<int> maHoSoList,
  ) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/luot-kham/danh-sach'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{'danh_sach_ma_ho_so': maHoSoList}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      print("Lỗi API danh-sach: ${response.statusCode} - ${response.body}");
      throw Exception('Failed to load appointments');
    }
  }

  // Kiểm tra trạng thái lượt khám (dùng cho polling thanh toán và check-in)
  static Future<Map<String, dynamic>> checkStatus(int maLuotKham) async {
    final token = await AuthService().getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/luot-kham/$maLuotKham/check-status'),
          headers: <String, String>{
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Không thể kiểm tra trạng thái lượt khám #$maLuotKham');
    }
  }

  static Future<String> getCheckinQrData(int maLuotKham) async {
    final token = await AuthService().getToken();
    final response = await http
        .get(
          Uri.parse('$baseUrl/luot-kham/$maLuotKham/qr'),
          headers: <String, String>{
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) {
      throw Exception(
        'Không thể tải mã QR check-in cho lượt khám #$maLuotKham',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['status'] != 'success' ||
        decoded['data'] is! Map<String, dynamic>) {
      throw Exception('Dữ liệu mã QR check-in không hợp lệ');
    }

    final qrToken = decoded['data']['qr_token'];
    if (qrToken is! String || qrToken.isEmpty) {
      throw Exception(
        'Máy chủ chưa cấp mã QR check-in cho lượt khám #$maLuotKham',
      );
    }

    return 'LICHKHAM:$qrToken';
  }

  // Check-in lượt khám (tiếp nhận)
  static Future<Map<String, dynamic>> checkIn(int maLuotKham) async {
    final token = await AuthService().getToken();
    final response = await http
        .put(
          Uri.parse('$baseUrl/luot-kham/$maLuotKham/tiep-nhan'),
          headers: <String, String>{
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 5));

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
    final token = await AuthService().getToken();
    final response = await http
        .get(
          Uri.parse(url),
          headers: <String, String>{
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Không thể tải tiến trình hàng đợi của lượt khám #$maLuotKham',
      );
    }
  }

  /// Kích hoạt thông báo đẩy FCM khi sắp đến lượt khám
  static Future<Map<String, dynamic>> triggerQueueNotification(
    int maLuotKham, {
    int stt = 18,
    int dangPhucVu = 15,
  }) async {
    final token = await AuthService().getToken();
    final response = await http
        .post(
          Uri.parse('$baseUrl/luot-kham/$maLuotKham/thong-bao-sap-den-luot'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, dynamic>{
            'stt': stt,
            'dang_phuc_vu': dangPhucVu,
          }),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gửi thông báo đẩy thất bại');
    }
  }
}
