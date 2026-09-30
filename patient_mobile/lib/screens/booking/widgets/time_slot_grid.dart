import 'package:flutter/material.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<Map<String, dynamic>> slots;
  final Map<String, dynamic>? selectedSlot;
  final Function(Map<String, dynamic>) onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, 
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final isFull = slot['isFull'] == true;
        final isSelected = selectedSlot?['id'] == slot['id'];

        return InkWell(
          onTap: isFull ? null : () => onSlotSelected(slot),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isFull
                  ? Colors.grey[300] 
                  : isSelected
                      ? Colors.blue 
                      : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              slot['time'] ?? '',
              style: TextStyle(
                color: isFull
                    ? Colors.grey[500] 
                    : isSelected
                        ? Colors.white
                        : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}
