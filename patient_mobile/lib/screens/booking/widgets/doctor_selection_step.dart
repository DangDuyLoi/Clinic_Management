import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class DoctorSelectionStep extends StatelessWidget {
  const DoctorSelectionStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final doctors = [
      {'name': 'PGS.TS Nguyễn Văn A', 'specialty': 'Nội Tim Mạch', 'rating': '4.9'},
      {'name': 'ThS.BS Trần Thị B', 'specialty': 'Ngoại Thần Kinh', 'rating': '4.8'},
      {'name': 'BS.CKII Lê Văn C', 'specialty': 'Tiêu Hoá', 'rating': '4.7'},
    ];

    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bác sĩ, chuyên khoa...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.gradientStart,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(
                    doctor['name']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(doctor['specialty']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(doctor['rating']!),
                    ],
                  ),
                  onTap: () {
                    // Logic chọn bác sĩ
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
