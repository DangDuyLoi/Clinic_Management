import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_controller.dart';
import 'package:intl/intl.dart';
import '../../main/main_screen.dart';

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  final BookingController controller = Get.find<BookingController>();
  DateTime _currentMonth = DateTime.now();
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _currentMonth = DateTime(_today.year, _today.month, 1);
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chọn ngày khám',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.blue, size: 28),
            onPressed: () => Get.offAll(() => const MainScreen()),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _prevMonth,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_left, color: Colors.grey),
                  ),
                ),
                Text(
                  'Tháng ${_currentMonth.month.toString().padLeft(2, '0')} - ${_currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                GestureDetector(
                  onTap: _nextMonth,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Days of Week Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']
                  .map(
                    (day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Calendar Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalendarGrid(),
            ),
          ),

          // Legend Note
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black87, fontSize: 15),
                    children: [
                      TextSpan(text: 'Chọn ngày có '),
                      TextSpan(
                        text: 'màu xanh dương',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' để đặt khám.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildLegendRow(
                  Colors.blue,
                  'Ngày có thể chọn khám',
                  isBorder: false,
                ),
                const SizedBox(height: 8),
                _buildLegendRow(
                  Colors.grey.shade400,
                  'Ngày không chọn khám',
                  isBorder: true,
                ),
                const SizedBox(height: 8),
                _buildLegendRow(Colors.orange, 'Ngày Lễ, Tết', isBorder: true),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth = DateUtils.getDaysInMonth(
      _currentMonth.year,
      _currentMonth.month,
    );
    int firstDayWeekday = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    ).weekday; // 1 = Monday, 7 = Sunday
    // Adjust so Sunday is first column (index 0)
    int emptyPrefixCells = firstDayWeekday == 7 ? 0 : firstDayWeekday;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: emptyPrefixCells + daysInMonth,
      itemBuilder: (context, index) {
        if (index < emptyPrefixCells) {
          return const SizedBox.shrink(); // Empty slots
        }

        int dayNum = index - emptyPrefixCells + 1;
        DateTime cellDate = DateTime(
          _currentMonth.year,
          _currentMonth.month,
          dayNum,
        );

        bool isToday =
            cellDate.year == _today.year &&
            cellDate.month == _today.month &&
            cellDate.day == _today.day;

        // Mock holidays and days off
        bool isHoliday = cellDate.month == 9 && (dayNum == 1 || dayNum == 2);
        bool isDayOff = cellDate.weekday == DateTime.sunday; // Chủ nhật nghỉ

        // Cannot pick days in the past
        bool isPast = cellDate.isBefore(
          DateTime(_today.year, _today.month, _today.day),
        );
        bool canSelect = !isHoliday && !isDayOff && !isPast;

        return _buildDayCell(
          day: dayNum,
          isHoliday: isHoliday,
          isDayOff: isDayOff || isPast,
          isToday: isToday,
          onTap: canSelect
              ? () {
                  controller.onDateSelected(cellDate);
                }
              : null,
        );
      },
    );
  }

  Widget _buildDayCell({
    required int day,
    required bool isHoliday,
    required bool isDayOff,
    required bool isToday,
    required VoidCallback? onTap,
  }) {
    Color bgColor = Colors.grey.shade200;
    Color textColor = Colors.black87;
    String? subText;

    if (isHoliday) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange;
      subText = 'Ngày lễ';
    } else if (isDayOff) {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade400;
      subText = 'Nghỉ';
    } else {
      bgColor = Colors.white; // Default for pickable days
      textColor = Colors.black87;
    }

    if (isToday) {
      bgColor = Colors.white;
    }

    Widget cell = Container(
      decoration: BoxDecoration(
        color: isToday ? Colors.white : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? Colors.blue
              : (onTap != null ? Colors.blue : Colors.grey.shade300),
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          if (subText != null) ...[
            const SizedBox(height: 2),
            Text(subText, style: TextStyle(fontSize: 9, color: textColor)),
          ],
        ],
      ),
    );

    if (isToday) {
      cell = Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          cell,
          Positioned(
            bottom: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Hôm nay',
                style: TextStyle(color: Colors.white, fontSize: 8),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(onTap: onTap, child: cell);
  }

  Widget _buildLegendRow(Color color, String text, {required bool isBorder}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isBorder ? Colors.white : color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isBorder ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
