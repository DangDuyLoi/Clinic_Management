import 'package:flutter/material.dart';
import 'visit_timeline_item.dart';

class VisitHistoryTab extends StatelessWidget {
  const VisitHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả định
    final visits = [
      {
        'date': '15/04/2024',
        'department': 'Khám Nội Tổng Quát',
        'diagnosis': 'Viêm dạ dày cấp',
        'note': 'Hạn chế ăn đồ chua cay, kiêng rượu bia và chất kích thích. Uống nhiều nước và nghỉ ngơi điều độ. Tái khám sau 1 tuần nếu triệu chứng không thuyên giảm.',
        'medications': [
          {'name': 'Omeprazole 20mg', 'dosage': 'Uống 1 viên/ngày trước ăn 30 phút', 'quantity': '14 viên'},
          {'name': 'Phosphalugel', 'dosage': 'Uống 1 gói x 2 lần/ngày sau ăn', 'quantity': '28 gói'},
        ],
      },
      {
        'date': '10/01/2024',
        'department': 'Khoa Tai Mũi Họng',
        'diagnosis': 'Viêm họng hạt cấp tính',
        'note': 'Súc miệng nước muối sinh lý hàng ngày, hạn chế nói to, tránh uống nước đá. Tránh nơi có nhiều khói bụi.',
        'medications': [
          {'name': 'Amoxicillin 500mg', 'dosage': 'Uống 1 viên x 2 lần/ngày', 'quantity': '10 viên'},
          {'name': 'Alpha Choay', 'dosage': 'Ngậm 2 viên/lần x 3 lần/ngày', 'quantity': '30 viên'},
        ],
      },
      {
        'date': '05/09/2023',
        'department': 'Khám Mắt',
        'diagnosis': 'Cận thị nhẹ',
        'note': 'Nên đeo kính chống cận, hạn chế tiếp xúc màn hình máy tính điện thoại quá lâu. Cho mắt nghỉ ngơi mỗi 45 phút.',
        'medications': [
          {'name': 'V Rohto Vitamin', 'dosage': 'Nhỏ 2-3 giọt x 3 lần/ngày', 'quantity': '1 lọ'},
        ],
      }
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visits.length,
      itemBuilder: (context, index) {
        final visit = visits[index];
        return VisitTimelineItem(
          date: visit['date'] as String,
          department: visit['department'] as String,
          diagnosis: visit['diagnosis'] as String,
          note: visit['note'] as String?,
          medications: visit['medications'] as List<Map<String, String>>,
          isLast: index == visits.length - 1,
        );
      },
    );
  }
}
