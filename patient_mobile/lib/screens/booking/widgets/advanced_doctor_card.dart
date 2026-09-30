import 'package:flutter/material.dart';

class AdvancedDoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onSelect; // Will be called when a specific shift is selected, or we can pass the shift.

  const AdvancedDoctorCard({
    super.key,
    required this.doctor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final availableShifts = doctor['available_shifts'] as List<String>? ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER (Image + Info)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Portrait
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 100,
                    color: Colors.grey.shade200,
                    child: Image.network(
                      doctor['avatarUrl'] ?? 'https://i.pravatar.cc/150',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Doctor Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1FE), // Light blue
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          doctor['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF0056D2), // Darker blue
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Gender Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              doctor['gender'] == 'Male' ? 'Nam' : 'Nữ',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Info Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Thông tin bác sĩ',
                              style: TextStyle(color: Colors.blue, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 16, color: Colors.blue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Dotted Line
            _buildDottedLine(),
            const SizedBox(height: 16),
            
            // DETAILS TABLE
            _buildDetailRow(
              label: 'Chuyên khoa',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor['specialty'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333)),
                  ),
                  if (doctor['specialtyDesc'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        doctor['specialtyDesc'],
                        style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text(
                        'Xem thông tin khoa',
                        style: TextStyle(color: Colors.blue, fontSize: 13),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDetailRow(
              label: 'Giá khám',
              child: Text(
                doctor['price'] ?? '150.000đ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            
            // SHIFTS
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    'Buổi khám',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: availableShifts.map((shift) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              shift,
                              style: const TextStyle(
                                color: Colors.green, // Green color for shift
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Can pass selected shift back
                                  onSelect();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D6EFD), // Solid Blue
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text('Chọn', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildDottedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 4.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey)),
            );
          }),
        );
      },
    );
  }
}
