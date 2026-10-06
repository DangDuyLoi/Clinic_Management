import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/booking_controller.dart';
import 'insurance_screen.dart';

class DoctorListScreen extends StatelessWidget {
  final BookingController controller = Get.find<BookingController>();

  DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data
    final doctors = [
      {
        'id': '1',
        'name': 'BSCKII. Lê Tường Viễn',
        'room': 'Phòng 66 - Lầu 1 Khu B',
        'avatarUrl': 'https://i.pravatar.cc/150?img=11',
      },
      {
        'id': '2',
        'name': 'BSCKII. Nguyễn Thành Nhân',
        'room': 'Phòng 66 - Lầu 1 Khu B',
        'avatarUrl': 'https://i.pravatar.cc/150?img=12',
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FA),
      appBar: AppBar(
        title: const Text('Chọn buổi khám', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Column(
        children: [
          // Header Note
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 4, height: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('CHỌN KHUNG GIỜ KHÁM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black54, fontSize: 14, fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'Vui lòng bấm chọn khung giờ '),
                      TextSpan(text: 'màu xanh dương', style: TextStyle(color: Colors.blue)),
                      TextSpan(text: ' để đặt khám'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Doctor List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return DoctorBookingCard(
                  doctor: doctors[index],
                  controller: controller,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorBookingCard extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final BookingController controller;

  const DoctorBookingCard({super.key, required this.doctor, required this.controller});

  @override
  State<DoctorBookingCard> createState() => _DoctorBookingCardState();
}

class _DoctorBookingCardState extends State<DoctorBookingCard> {
  DateTime? selectedDate;

  // Mock dates: today and next few days
  final List<DateTime> dates = List.generate(5, (index) => DateTime.now().add(Duration(days: index)));

  // Mock time slots
  final List<String> timeSlots = [
    '06:30 - 07:30', '07:30 - 08:30', '08:30 - 09:30', '09:30 - 10:30', '10:30 - 11:30'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.doctor['avatarUrl'],
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0056D2)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.doctor['room'],
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F5FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Thông tin bác sĩ', style: TextStyle(color: Colors.blue, fontSize: 12)),
                            SizedBox(width: 4),
                            Icon(Icons.chevron_right, size: 14, color: Colors.blue),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
          
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
          ),
          
          // Dates List
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = selectedDate != null && 
                      date.year == selectedDate!.year && 
                      date.month == selectedDate!.month && 
                      date.day == selectedDate!.day;
                  
                  final isToday = index == 0;
                  final dayName = isToday ? 'Hôm nay' : 'Thứ ${date.weekday == 7 ? 'CN' : date.weekday + 1}';
                  final dateStr = DateFormat('dd/MM\nyyyy').format(date);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedDate = null;
                        } else {
                          selectedDate = date;
                        }
                      });
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0056D2) : const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSelected ? const Color(0xFF0056D2) : Colors.transparent),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected ? Colors.white : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateStr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 10, color: Color(0xFF0056D2)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Expanded Time Slots
          if (selectedDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8FAFC),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormat('dd/MM/yyyy').format(selectedDate!)} - Buổi sáng (Thứ ${selectedDate!.weekday == 7 ? 'CN' : selectedDate!.weekday + 1})',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5B46), fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = timeSlots[index];
                      // Mock "Hết số" for first slot
                      final isFull = index == 0; 
                      
                      return GestureDetector(
                        onTap: isFull ? null : () {
                          // Select doctor, date, and slot then move to next screen
                          widget.controller.selectedDoctor.value = widget.doctor;
                          widget.controller.selectedDate.value = selectedDate;
                          widget.controller.selectedTimeSlot.value = {'time': slot};
                          Get.to(() => const InsuranceScreen());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isFull ? const Color(0xFFF0F0F0) : const Color(0xFFE8F1FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slot,
                                style: TextStyle(
                                  color: isFull ? Colors.black54 : const Color(0xFF0056D2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (isFull)
                                const Text(
                                  'Hết số',
                                  style: TextStyle(color: Colors.black54, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
          // Helper text if no date selected
          if (selectedDate == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 1, width: 30, color: Colors.grey.shade300),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Vui lòng chọn buổi khám khác hoặc ngày khác', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
                  Container(height: 1, width: 30, color: Colors.grey.shade300),
                ],
              ),
            )
        ],
      ),
    );
  }
}
