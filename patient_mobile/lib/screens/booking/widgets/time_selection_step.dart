import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class TimeSelectionStep extends StatelessWidget {
  const TimeSelectionStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = ['Th 2\n12', 'Th 3\n13', 'Th 4\n14', 'Th 5\n15', 'Th 6\n16'];
    final timeSlots = [
      {'time': '07:30 - 08:30', 'available': true},
      {'time': '08:30 - 09:30', 'available': false},
      {'time': '09:30 - 10:30', 'available': true},
      {'time': '10:30 - 11:30', 'available': true},
      {'time': '13:30 - 14:30', 'available': true},
      {'time': '14:30 - 15:30', 'available': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn ngày', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              final isSelected = index == 1; // Giả sử chọn ngày thứ 2
              return Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  days[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Text('Chọn giờ khám', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: timeSlots.map((slot) {
            final available = slot['available'] as bool;
            final isSelected = slot['time'] == '09:30 - 10:30';
            
            return ChoiceChip(
              label: Text(slot['time'] as String),
              selected: isSelected,
              onSelected: available ? (bool selected) {} : null,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              disabledColor: AppColors.disabled,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (available ? Colors.black87 : Colors.grey),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
