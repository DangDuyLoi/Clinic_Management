import 'package:flutter/material.dart';

class InsuranceValidation extends StatelessWidget {
  final String? selectedInsurance;
  final Function(String) onChanged;

  const InsuranceValidation({
    super.key,
    required this.selectedInsurance,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Thông tin bảo hiểm (Bắt buộc)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRadioOption('Bảo hiểm Y tế (BHYT)'),
            _buildRadioOption('Bảo hiểm Tư nhân / Bảo lãnh viện phí'),
            _buildRadioOption('Không sử dụng bảo hiểm'),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: title,
      groupValue: selectedInsurance,
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: Colors.blue,
    );
  }
}
