import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    // NOTE: Use 10.0.2.2 for Android emulator or localhost for iOS/Web.
    baseUrl: 'http://127.0.0.1:8000/api', 
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

  Future<void> login(String phoneNumber, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'phone_number': phoneNumber,
        'password': password,
      });
      
      final token = response.data['token'];
      if (token != null) {
        await _storage.write(key: tokenKey, value: token);
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Invalid credentials');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: tokenKey);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: tokenKey);
  }
}
