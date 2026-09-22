import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class VisitTimelineItem extends StatelessWidget {
  final String date;
  final String department;
  final String diagnosis;
  final List<Map<String, String>> medications;
  final bool isLast;

  const VisitTimelineItem({
    Key? key,
    required this.date,
    required this.department,
    required this.diagnosis,
    required this.medications,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cột trái: Timeline (Đường thẳng và chấm tròn)
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey[300],
                    ),
                  ),
              ],
            ),
          ),
          // Cột phải: Nội dung thẻ (Card)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Card(
                elevation: 1,
                margin: const EdgeInsets.only(left: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          department,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'CĐ: $diagnosis',
                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                      ),
                    ),
                    children: [
                      const Divider(height: 1, color: Colors.black12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey[50],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Đơn thuốc',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            const SizedBox(height: 8),
                            ...medications.map((med) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.medication, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(med['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('${med['dosage']} - SL: ${med['quantity']}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
