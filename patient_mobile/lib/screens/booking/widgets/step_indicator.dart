import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.steps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index % 2 == 0) {
          int stepIndex = index ~/ 2;
          bool isActive = stepIndex <= currentStep;
          return Column(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? AppColors.primary : Colors.grey,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${stepIndex + 1}',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? AppColors.primary : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        } else {
          int stepIndex = index ~/ 2;
          bool isLineActive = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: isLineActive ? AppColors.primary : Colors.grey[300],
              margin: const EdgeInsets.only(bottom: 20, left: 4, right: 4), // Căn lên trên để ngang với vòng tròn
            ),
          );
        }
      }),
    );
  }
}
