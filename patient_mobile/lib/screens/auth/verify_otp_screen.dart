import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // added for kIsWeb
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'set_password_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final ConfirmationResult? confirmationResult; // added for web

  const VerifyOtpScreen({
    super.key, 
    required this.phoneNumber,
    required this.verificationId,
    this.confirmationResult,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Mã OTP phải gồm 6 chữ số');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kIsWeb && widget.confirmationResult != null) {
        // Web flow
        await widget.confirmationResult!.confirm(otp);
      } else {
        // Mobile flow
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId,
          smsCode: otp,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SetPasswordScreen(
              phoneNumber: widget.phoneNumber, 
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message ?? 'Xác thực OTP thất bại');
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
      appBar: AppBar(title: const Text('Xác thực OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nhập mã OTP 6 số được gửi tới\n${widget.phoneNumber}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                labelText: 'Mã OTP',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading 
                  ? const CircularProgressIndicator() 
                  : const Text('Xác thực', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
