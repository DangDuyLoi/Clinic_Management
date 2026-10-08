import 'package:flutter/material.dart';

class TestResultsTab extends StatelessWidget {
  const TestResultsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.biotech, size: 64, color: Colors.blue[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có dữ liệu cận lâm sàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kết quả xét nghiệm, X-Quang, siêu âm sẽ\nhiển thị tại đây sau khi bạn khám.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
