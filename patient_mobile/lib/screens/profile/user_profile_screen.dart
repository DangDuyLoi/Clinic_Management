import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'personal_info_screen.dart';
import 'change_password_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  String _userName = 'ĐẶNG DUY LỢI';
  String _userPhone = '037****315';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserHeader();
    _loadNotificationSetting();
  }

  Future<void> _loadUserHeader() async {
    try {
      final phone = await _authService.getUserPhone() ?? '0374244315';
      final masked = phone.length >= 7
          ? '${phone.substring(0, 3)}****${phone.substring(phone.length - 3)}'
          : phone;
      setState(() => _userPhone = masked);

      final url = Uri.parse('${ApiConstants.baseUrl}/user-info?phone=$phone');
      final res = await http.get(url, headers: {'Accept': 'application/json'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        if (data != null && data['name'] != null && mounted) {
          setState(() {
            _userName = data['name'].toString().toUpperCase();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);

    if (value) {
      Get.snackbar(
        'Thông báo',
        'Đã bật nhận thông báo lịch khám & kết quả CLS',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'Thông báo',
        'Đã tắt nhận thông báo',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Tài khoản'),
                  _buildMenuContainer(
                    children: [
                      _buildMenuItem(
                        Icons.person,
                        'Thông tin cá nhân',
                        onTap: () async {
                          await Get.to(() => const PersonalInfoScreen());
                          _loadUserHeader();
                        },
                      ),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(
                        Icons.vpn_key,
                        'Thay đổi mật khẩu',
                        onTap: () => Get.to(() => const ChangePasswordScreen()),
                      ),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(
                        Icons.lock,
                        'Passcode',
                        onTap: () {
                          Get.snackbar(
                            'Passcode',
                            'Tính năng khóa bằng mã PIN / Passcode đang được phát triển',
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Cài đặt'),
                  _buildMenuContainer(
                    children: [
                      _buildSwitchMenuItem(
                        Icons.notifications,
                        'Nhận thông báo',
                        _notificationsEnabled,
                        onChanged: _toggleNotification,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Thông tin pháp lý'),
                  _buildMenuContainer(
                    children: [
                      _buildMenuItem(
                        Icons.description,
                        'Điều khoản dịch vụ',
                        onTap: () {
                          Get.snackbar('Điều khoản', 'Phòng khám đa khoa HUIT Care cam kết bảo vệ thông tin người dùng.');
                        },
                      ),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(
                        Icons.privacy_tip,
                        'Chính sách bảo mật',
                        onTap: () {
                          Get.snackbar('Chính sách', 'Dữ liệu y tế được mã hóa và bảo mật theo chuẩn y khoa.');
                        },
                      ),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(
                        Icons.rule,
                        'Quy định sử dụng',
                        onTap: () {
                          Get.snackbar('Quy định', 'Quy định đặt khám và hủy lịch trước 24 giờ.');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildMenuContainer(
                    children: [
                      _buildLogoutItem(context),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Footer with Logo and Version
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.verified_user, color: Colors.blue, size: 48),
                        SizedBox(height: 8),
                        Text('HUIT Care v3.5.7', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        SizedBox(height: 40),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(Icons.medical_services, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userPhone,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildMenuContainer({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchMenuItem(
    IconData icon,
    String title,
    bool value, {
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
      ),
      title: const Text('Đăng xuất', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () async {
        await _authService.logout();
        Get.offAll(() => const LoginScreen());
      },
    );
  }
}
