import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import 'package:intl/intl.dart';
import 'insurance_screen.dart';
import '../../home/home_screen.dart';

class TimeSlotScreen extends StatelessWidget {
  final BookingController controller = Get.find<BookingController>();

  TimeSlotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final morningSlots = [
      '08:00:00', '08:30:00', '09:00:00', '09:30:00',
      '10:00:00', '10:30:00', '11:00:00', '11:30:00'
    ];
    
    final afternoonSlots = [
      '13:00:00', '13:30:00', '14:00:00', '14:30:00',
      '15:00:00', '15:30:00', '16:00:00', '16:30:00'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text('Chọn giờ khám', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.blue, size: 28),
            onPressed: () => Get.offAll(() => const HomeScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingSlots.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header (Doctor & Date)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Obx(() {
                        final date = controller.selectedDate.value;
                        final dateStr = date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Chưa chọn ngày';
                        return Text('Ngày khám: $dateStr', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final doctor = controller.selectedDoctor.value;
                    if (doctor == null) return const SizedBox.shrink();
                    return Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Bác sĩ: ${doctor['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Buổi sáng'),
                    const SizedBox(height: 12),
                    _buildSlotGrid(morningSlots),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Buổi chiều'),
                    const SizedBox(height: 12),
                    _buildSlotGrid(afternoonSlots),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        const Icon(Icons.wb_sunny_outlined, color: Colors.orange, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSlotGrid(List<String> slots) {
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
        final isAvailable = controller.availableTimeSlots.contains(slot);
        final isDisabled = !isAvailable;
        
        return Obx(() {
          final isSelected = controller.selectedTimeSlot.value?['time'] == slot;
          
          return GestureDetector(
            onTap: isDisabled
                ? null
                : () {
                    controller.selectedTimeSlot.value = {'time': slot};
                    // Chuyển tới bước tiếp theo (Bảo hiểm)
                    Get.to(() => const InsuranceScreen());
                  },
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey.shade200
                    : (isSelected ? Colors.blue : Colors.white),
                border: Border.all(
                  color: isDisabled
                      ? Colors.transparent
                      : (isSelected ? Colors.blue : Colors.blue.shade200),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                slot.substring(0, 5), // Chỉ hiện 08:00
                style: TextStyle(
                  color: isDisabled
                      ? Colors.grey.shade500
                      : (isSelected ? Colors.white : Colors.blue.shade700),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
