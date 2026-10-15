import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class EmrService {
  static const String baseUrl = ApiConstants.baseUrl;
  final AuthService _authService = AuthService();

  /// Lấy lịch sử khám bệnh từ MySQL EMR
  Future<List<Map<String, dynamic>>> fetchVisitHistory() async {
    try {
      final phone = await _authService.getUserPhone() ?? '0374244315';
      final url = Uri.parse('$baseUrl/emr/lich-su-kham?phone=$phone');
      
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final list = (json['data'] ?? []) as List;
        return list.map<Map<String, dynamic>>((item) {
          final medsRaw = item['medications'] as List? ?? [];
          final medications = medsRaw.map<Map<String, String>>((m) {
            return {
              'name': (m['name'] ?? '').toString(),
              'quantity': (m['quantity'] ?? '').toString(),
              'dosage': (m['dosage'] ?? '').toString(),
            };
          }).toList();

          return {
            'id': item['id'],
            'date': item['date'] ?? '',
            'department': item['department'] ?? '',
            'doctor': item['doctor'] ?? '',
            'room': item['room'] ?? '',
            'diagnosis': item['diagnosis'] ?? '',
            'note': item['note'],
            'medications': medications,
          };
        }).toList();
      } else {
        throw Exception('Không thể tải lịch sử khám (Mã lỗi ${response.statusCode})');
      }
    } catch (e) {
      print('EmrService.fetchVisitHistory error: $e');
      rethrow;
    }
  }

  /// Lấy kết quả cận lâm sàng (xét nghiệm, CĐHA, nội soi) từ MySQL EMR
  Future<List<Map<String, dynamic>>> fetchTestResults() async {
    try {
      final phone = await _authService.getUserPhone() ?? '0374244315';
      final url = Uri.parse('$baseUrl/emr/ket-qua-cls?phone=$phone');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final list = (json['data'] ?? []) as List;
        return list.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'date': item['date'] ?? '',
            'test_name': item['test_name'] ?? '',
            'department': item['department'] ?? '',
            'doctor': item['doctor'] ?? '',
            'result': item['result'] ?? '',
            'status': item['status'] ?? 'Đã có kết quả',
            'price': item['price'] ?? '',
          };
        }).toList();
      } else {
        throw Exception('Không thể tải kết quả cận lâm sàng (Mã lỗi ${response.statusCode})');
      }
    } catch (e) {
      print('EmrService.fetchTestResults error: $e');
      rethrow;
    }
  }
}
