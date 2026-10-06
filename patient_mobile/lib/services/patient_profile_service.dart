import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatientProfileService {
  // Replace with actual API base URL
  static const String baseUrl = 'http://localhost:8000/api'; 

  // In-memory cache for demo purposes
  static final List<Map<String, dynamic>> cachedProfiles = [];

  static Future<void> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('cachedProfiles');
    if (profilesJson != null) {
      final List<dynamic> decoded = json.decode(profilesJson);
      cachedProfiles.clear();
      for (var item in decoded) {
        cachedProfiles.add(Map<String, dynamic>.from(item));
      }
    }
  }

  static Future<void> _saveProfilesToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedProfiles', json.encode(cachedProfiles));
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
