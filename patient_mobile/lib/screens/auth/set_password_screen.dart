import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class SetPasswordScreen extends StatefulWidget {
  final String phoneNumber;

  const SetPasswordScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Phải chứa ít nhất 1 chữ cái in thường';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Phải chứa ít nhất 1 chữ cái in hoa';
    }
    if (!RegExp(r'[@$!%*#?&]').hasMatch(value)) {
      return 'Phải chứa ít nhất 1 ký tự đặc biệt (!@#\$%^&*)';
    }
    return null;
  }

  Future<void> _submit() async {
    // Validate triggers the realtime red error text on TextFormFields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      setState(() => _errorMessage = 'Mật khẩu không khớp');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.setPassword(
        widget.phoneNumber, 
        _passwordController.text
      );
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Thành công'),
            content: const Text('Đăng ký tài khoản thành công!'),
            actions: [
              TextButton(
                onPressed: () {
                  // Navigate to login screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false
                  );
                },
                child: const Text('ĐĂNG NHẬP NGAY'),
              )
            ],
          )
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt mật khẩu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          // autovalidateMode allows realtime validation as user types
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              const Text(
                'Tạo một mật khẩu mạnh để bảo vệ tài khoản',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200)
                ),
                child: const Text(
                  'Yêu cầu mật khẩu:\n'
                  '• Ít nhất 8 ký tự\n'
                  '• Có ít nhất 1 chữ cái in hoa (A-Z)\n'
                  '• Có ít nhất 1 chữ cái in thường (a-z)\n'
                  '• Có ít nhất 1 ký tự đặc biệt (!@#\$%^&*)',
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                validator: _validatePassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Mật khẩu không khớp';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator() 
                    : const Text('Hoàn tất đăng ký', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
