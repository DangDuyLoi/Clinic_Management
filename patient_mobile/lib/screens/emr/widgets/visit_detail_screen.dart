import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VisitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> visitData;

  const VisitDetailScreen({Key? key, required this.visitData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final medications = visitData['medications'] as List<Map<String, String>>;
    final doctor = visitData['doctor'] as String? ?? 'Bác sĩ chuyên khoa';
    final room = visitData['room'] as String? ?? 'Phòng Khám';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Chi tiết Hồ sơ khám', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin chung
            _buildSectionContainer(
              children: [
                _buildHeaderRow(Icons.calendar_today, 'Ngày khám', visitData['date']),
                const Divider(height: 24, color: Color(0xFFEEEEEE)),
                _buildInfoRow('Chuyên khoa', visitData['department']),
                const SizedBox(height: 12),
                _buildInfoRow('Bác sĩ điều trị', doctor),
                const SizedBox(height: 12),
                _buildInfoRow('Phòng khám', room),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Kết quả chẩn đoán
            _buildSectionContainer(
              children: [
                _buildHeaderRow(Icons.medical_services_outlined, 'Kết quả chẩn đoán', null),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          visitData['diagnosis'],
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (visitData['note'] != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Lời dặn của Bác sĩ:',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visitData['note'],
                    style: const TextStyle(fontSize: 14, color: Colors.black87, fontStyle: FontStyle.italic),
                  ),
                ]
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Đơn thuốc
            if (medications.isNotEmpty)
              _buildSectionContainer(
                children: [
                  _buildHeaderRow(Icons.medication_outlined, 'Đơn thuốc', '${medications.length} loại'),
                  const SizedBox(height: 16),
                  ...medications.asMap().entries.map((entry) {
                    final index = entry.key;
                    final med = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0056D2).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Color(0xFF0056D2),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        med['name']!,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'SL: ${med['quantity']}',
                                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Cách dùng: ${med['dosage']}',
                                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // Feature: Tải PDF hoặc xem bản in
                Get.snackbar('Đang phát triển', 'Tính năng in/tải PDF hồ sơ đang được cập nhật', 
                  snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
              },
              icon: const Icon(Icons.print),
              label: const Text('Xuất PDF / In hồ sơ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0056D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildHeaderRow(IconData icon, String title, String? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF0056D2), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2)),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
