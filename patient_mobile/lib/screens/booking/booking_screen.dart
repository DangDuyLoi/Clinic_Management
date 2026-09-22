import 'package:flutter/material.dart';
import 'widgets/step_indicator.dart';
import 'widgets/doctor_selection_step.dart';
import 'widgets/time_selection_step.dart';
import 'widgets/confirmation_step.dart';
import '../../core/app_colors.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _currentStep = 0;
  final List<String> _steps = ['Bác sĩ', 'Giờ khám', 'Xác nhận'];

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return const DoctorSelectionStep();
      case 1:
        return const TimeSelectionStep();
      case 2:
        return const ConfirmationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt Lịch Khám'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: StepIndicator(
                currentStep: _currentStep,
                steps: _steps,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < _steps.length - 1) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  // Hiển thị thông báo hoặc chuyển trang thanh toán
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chuyển sang cổng thanh toán Momo/VNPay...')),
                  );
                }
              },
              child: Text(
                _currentStep == _steps.length - 1 ? 'Thanh toán qua Momo/VNPay' : 'Tiếp tục',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
