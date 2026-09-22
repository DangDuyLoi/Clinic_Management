import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class ConfirmationStep extends StatelessWidget {
  const ConfirmationStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thông tin đặt khám', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3), style: BorderStyle.solid), // Thay nét đứt bằng border thường cho đơn giản hoặc dùng thư viện doted_border
          ),
          child: Column(
            children: [
              _buildInfoRow('Bác sĩ', 'ThS.BS Trần Thị B'),
              const Divider(),
              _buildInfoRow('Chuyên khoa', 'Ngoại Thần Kinh'),
              const Divider(),
              _buildInfoRow('Thời gian', '09:30 - 10:30\nThứ 3, 13/05/2024'),
              const Divider(),
              _buildInfoRow('Phí khám', '150,000 đ', isPrice: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text('Lý do khám / Triệu chứng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Nhập triệu chứng của bạn...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPrice ? Colors.red : Colors.black87,
              fontSize: isPrice ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
