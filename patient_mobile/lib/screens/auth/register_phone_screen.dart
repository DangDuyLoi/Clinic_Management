import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // added for kIsWeb
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../profile/controllers/patient_profile_controller.dart';
import 'verify_otp_screen.dart';
import 'login_screen.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({super.key});

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  final _phoneController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendOtp() async {
    final rawPhone = _phoneController.text.trim();

    // 1. Kiểm tra tính hợp lệ của số điện thoại theo chuẩn viễn thông Việt Nam
    final phoneValidationError = MedicalValidators.validatePhone(rawPhone, isRequired: true);
    if (phoneValidationError != null) {
      setState(() => _errorMessage = phoneValidationError);
      return;
    }

    String phone = rawPhone;
    // Format to E.164 if starts with 0
    if (phone.startsWith('0')) {
      phone = '+84${phone.substring(1)}';
    } else if (!phone.startsWith('+')) {
      phone = '+$phone';
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb) {
        // Web flow
        ConfirmationResult result = await FirebaseAuth.instance.signInWithPhoneNumber(phone);
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyOtpScreen(
                phoneNumber: phone,
                verificationId: '',
                confirmationResult: result,
              ),
            ),
          );
        }
      } else {
        // Mobile flow
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credential) {
            // Auto-resolution on Android
          },
          verificationFailed: (FirebaseAuthException e) {
            if (mounted) {
              setState(() {
                _errorMessage = e.message ?? 'Gửi OTP thất bại';
                _isLoading = false;
              });
            }
          },
          codeSent: (String verificationId, int? resendToken) {
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VerifyOtpScreen(
                    phoneNumber: phone,
                    verificationId: verificationId,
                  ),
                ),
              );
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Nhập số điện thoại của bạn để bắt đầu',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              decoration: InputDecoration(
                labelText: 'Số điện thoại',
                errorText: _errorMessage,
                errorMaxLines: 3,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Gửi mã OTP', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('Đã có tài khoản? Đăng nhập tại đây'),
            )
          ],
        ),
      ),
    );
  }
}
