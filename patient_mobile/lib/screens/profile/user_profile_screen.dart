import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/app_colors.dart';
import '../auth/login_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

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
                      _buildMenuItem(Icons.person, 'Thông tin cá nhân'),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(Icons.vpn_key, 'Thay đổi mật khẩu'),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(Icons.lock, 'Passcode'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Cài đặt'),
                  _buildMenuContainer(
                    children: [
                      _buildSwitchMenuItem(Icons.notifications, 'Nhận thông báo', true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Thông tin pháp lý'),
                  _buildMenuContainer(
                    children: [
                      _buildMenuItem(Icons.description, 'Điều khoản dịch vụ'),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(Icons.privacy_tip, 'Chính sách bảo mật'),
                      const Divider(height: 1, indent: 48, endIndent: 16),
                      _buildMenuItem(Icons.rule, 'Quy định sử dụng'),
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
                        Text('v3.5.7-518', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
          const Text(
            'ĐẶNG DUY LỢI',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '037****315',
            style: TextStyle(
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

  Widget _buildMenuItem(IconData icon, String title) {
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
      onTap: () {},
    );
  }

  Widget _buildSwitchMenuItem(IconData icon, String title, bool value) {
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
        onChanged: (bool newValue) {},
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
      onTap: () {
        // Thực hiện đăng xuất
        Get.offAll(() => const LoginScreen());
      },
    );
  }
}
