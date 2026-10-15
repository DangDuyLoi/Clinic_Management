import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../core/app_colors.dart';
import '../../core/constants/api_constants.dart';
import '../../services/auth_service.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key}) : super(key: key);

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cccdController = TextEditingController();
  String _gender = 'Nam';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cccdController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final phone = await _authService.getUserPhone() ?? '0374244315';
      final url = Uri.parse('${ApiConstants.baseUrl}/user-info?phone=$phone');
      final res = await http.get(url, headers: {'Accept': 'application/json'});

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        setState(() {
          _nameController.text = data['name'] ?? '';
          _phoneController.text = data['phone'] ?? phone;
          _emailController.text = data['email'] ?? '';
          _dobController.text = data['dob'] ?? '2000-01-01';
          _gender = (data['gender'] == 'Nữ' || data['gender'] == 'Nu') ? 'Nữ' : 'Nam';
          _addressController.text = data['address'] ?? '';
          _cccdController.text = data['cccd'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserInfo() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập họ và tên',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);
    try {
      final phone = await _authService.getUserPhone() ?? '0374244315';
      final url = Uri.parse('${ApiConstants.baseUrl}/update-user-info');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phone,
          'name': _nameController.text.trim(),
          'dob': _dobController.text.trim(),
          'gender': _gender,
          'address': _addressController.text.trim(),
          'cccd': _cccdController.text.trim(),
        }),
      );

      setState(() => _isSaving = false);
      if (res.statusCode == 200) {
        Get.snackbar(
          'Thành công',
          'Thông tin cá nhân đã được cập nhật thành công!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar('Lỗi', 'Không thể lưu thông tin. Vui lòng thử lại.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      Get.snackbar('Lỗi', 'Có lỗi xảy ra: $e',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> _selectDate() async {
    DateTime initial = DateTime.tryParse(_dobController.text) ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'CHỌN NGÀY SINH',
    );
    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Thông tin cá nhân',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Avatar Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(Icons.person, size: 54, color: AppColors.primary),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _nameController.text.isNotEmpty ? _nameController.text : 'Bệnh nhân',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _phoneController.text,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                          label: 'Họ và tên *',
                          controller: _nameController,
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Số điện thoại',
                          controller: _phoneController,
                          icon: Icons.phone_outlined,
                          readOnly: true,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _selectDate,
                          child: AbsorbPointer(
                            child: _buildTextField(
                              label: 'Ngày sinh',
                              controller: _dobController,
                              icon: Icons.calendar_today_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Giới tính
                        const Text(
                          'Giới tính',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Nam')),
                                selected: _gender == 'Nam',
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _gender == 'Nam' ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _gender = 'Nam');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Center(child: Text('Nữ')),
                                selected: _gender == 'Nữ',
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _gender == 'Nữ' ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (val) {
                                  if (val) setState(() => _gender = 'Nữ');
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'CCCD / CMND / Mã định danh',
                          controller: _cccdController,
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Địa chỉ',
                          controller: _addressController,
                          icon: Icons.location_on_outlined,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Button Lưu
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveUserInfo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'Lưu thay đổi',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
