import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/api_constants.dart';
import 'auth_service.dart';

class PatientProfileService {
  static const String baseUrl = ApiConstants.baseUrl; 

  // In-memory cache for demo purposes
  static final List<Map<String, dynamic>> cachedProfiles = [];

  /// Tải danh sách hồ sơ cho tài khoản người dùng đang đăng nhập
  static Future<void> loadProfiles() async {
    final phone = await AuthService().getUserPhone();
    
    // Nếu chưa đăng nhập hoặc không có số điện thoại, làm rỗng cache
    if (phone == null || phone.isEmpty) {
      cachedProfiles.clear();
      return;
    }

    try {
      // 1. Ưu tiên đồng bộ từ Backend theo số điện thoại người dùng
      final url = Uri.parse('$baseUrl/patient-profiles/by-phone?phone=$phone');
      final response = await http.get(url, headers: {'Accept': 'application/json'}).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final list = decoded['data'];
        cachedProfiles.clear();
        if (list != null && list is List) {
          for (var item in list) {
            cachedProfiles.add(Map<String, dynamic>.from(item));
          }
        }
        await _saveProfilesToLocal();
        return;
      }
    } catch (e) {
      print('Lỗi đồng bộ hồ sơ từ Backend: $e');
    }

    // 2. Fallback: Nếu mất mạng, đọc từ SharedPreferences theo số điện thoại riêng
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('cachedProfiles_$phone');
    cachedProfiles.clear();
    if (profilesJson != null) {
      final List<dynamic> decoded = json.decode(profilesJson);
      for (var item in decoded) {
        cachedProfiles.add(Map<String, dynamic>.from(item));
      }
    }
  }

  static Future<void> _saveProfilesToLocal() async {
    final phone = await AuthService().getUserPhone();
    if (phone == null || phone.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedProfiles_$phone', json.encode(cachedProfiles));
  }

  /// Xóa sạch bộ nhớ đệm khi người dùng đăng xuất
  static Future<void> clearCache() async {
    cachedProfiles.clear();
    final prefs = await SharedPreferences.getInstance();
    // Xóa legacy key cũ nếu có
    await prefs.remove('cachedProfiles');
    final phone = await AuthService().getUserPhone();
    if (phone != null && phone.isNotEmpty) {
      await prefs.remove('cachedProfiles_$phone');
    }
  }

  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/patient-profiles'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['data'] != null) {
        cachedProfiles.add(responseData['data']);
        await _saveProfilesToLocal(); // Save to local storage
      }
      return responseData;
    } else {
      throw Exception('Failed to create profile: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateProfile(dynamic id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/patient-profiles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final updatedItem = responseData['data'];
      if (updatedItem != null) {
        final index = cachedProfiles.indexWhere((p) => (p['ma_ho_so'] ?? p['id']).toString() == id.toString());
        if (index != -1) {
          cachedProfiles[index] = Map<String, dynamic>.from(updatedItem);
        } else {
          cachedProfiles.add(Map<String, dynamic>.from(updatedItem));
        }
        await _saveProfilesToLocal();
      }
      return responseData;
    } else {
      try {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Không thể cập nhật hồ sơ');
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Lỗi khi cập nhật hồ sơ: ${response.statusCode}');
      }
    }
  }

  Future<void> deleteProfile(dynamic id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/patient-profiles/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      cachedProfiles.removeWhere((p) => (p['ma_ho_so'] ?? p['id']).toString() == id.toString());
      await _saveProfilesToLocal();
    } else {
      try {
        final decoded = json.decode(response.body);
        throw Exception(decoded['message'] ?? 'Không thể xóa hồ sơ');
      } catch (e) {
        if (e is Exception && !e.toString().contains('FormatException')) {
          rethrow;
        }
        throw Exception('Lỗi khi xóa hồ sơ: ${response.statusCode}');
      }
    }
  }

  Future<Map<String, dynamic>> findByCode(String code) async {
    final response = await http.get(
      Uri.parse('$baseUrl/patient-profiles/search-by-code?code=$code'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Profile not found');
    }
  }

  Future<Map<String, dynamic>> findByInfo(Map<String, dynamic> info) async {
    final uri = Uri.parse('$baseUrl/patient-profiles/search-by-info').replace(queryParameters: info);
    final response = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Profile not found');
    }
  }
}
