import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewSummaryScreen extends StatelessWidget {
  const ReviewSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông tin đặt khám')),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD TÓM TẮT ĐẶT KHÁM
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('HỒ SƠ BỆNH NHÂN', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {},
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('NGUYỄN VĂN A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    _SummaryDetailRow(label: 'Chuyên khoa', value: 'Nội Tim mạch', isBold: true),
                    const SizedBox(height: 12),
                    _SummaryDetailRow(label: 'Bác sĩ', value: 'ThS.BS Nguyễn Đình Luân'),
                    const SizedBox(height: 12),
                    _SummaryDetailRow(label: 'Ngày khám', value: 'Sáng Thứ 4 - 07/10/2026'),
                    const SizedBox(height: 12),
                    _SummaryDetailRow(label: 'Phòng khám', value: 'Phòng 204 - Tầng 2'),
                    const SizedBox(height: 12),
                    _SummaryDetailRow(label: 'Bảo hiểm Y tế', value: 'Đúng tuyến'),
                    const SizedBox(height: 12),
                    _SummaryDetailRow(label: 'Tiền khám', value: '150.000đ', isBold: true, valueColor: Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Thêm chuyên khoa khác'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Get.toNamed('/booking/specialty'); // Quay lại bước chọn chuyên khoa
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Get.toNamed('/booking/payment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Tiếp tục (Chọn Thanh toán)'),
          ),
        ),
      ),
    );
  }
}

class _SummaryDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryDetailRow({
    required this.label, 
    required this.value, 
    this.isBold = false, 
    this.valueColor
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(label, style: const TextStyle(color: Colors.grey)),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
