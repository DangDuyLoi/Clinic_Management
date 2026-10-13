import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/api_constants.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl, 
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  static const String tokenKey = 'auth_token';

  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _dio.post('/send-otp', data: {
        'phone_number': phoneNumber,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> verifyOtp(String phoneNumber, String otp) async {
    try {
      await _dio.post('/verify-otp', data: {
        'phone_number': phoneNumber,
        'otp': otp,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Invalid or expired OTP');
    }
  }

  Future<void> setPassword(String phoneNumber, String password) async {
    try {
      final response = await _dio.post('/set-password', data: {
        'phone_number': phoneNumber,
        'password': password,
      });
      
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: tokenKey, value: token);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to set password');
    }
  }

  Future<void> login(String phoneNumber, String password, {String? fcmToken}) async {
    try {
      final Map<String, dynamic> data = {
        'phone_number': phoneNumber,
        'password': password,
      };
      if (fcmToken != null && fcmToken.isNotEmpty) {
        data['fcm_token'] = fcmToken;
      }

      final response = await _dio.post('/login', data: data);
      
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: tokenKey, value: token);
      }
      await _storage.write(key: 'user_phone', value: phoneNumber);
    } on DioException catch (e) {
      if (e.response == null) {
        throw Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra Server Backend.');
      }
      throw Exception(e.response?.data['message'] ?? 'Sai số điện thoại hoặc mật khẩu');
    }
  }

  Future<void> updateFcmToken(String phoneNumber, String fcmToken) async {
    try {
      await _dio.post('/update-fcm-token', data: {
        'phone_number': phoneNumber,
        'fcm_token': fcmToken,
      });
    } catch (e) {
      print('Update FCM token error: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: tokenKey);
    await _storage.delete(key: 'user_phone');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }

  Future<String?> getUserPhone() async {
    return await _storage.read(key: 'user_phone');
  }
}
