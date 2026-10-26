import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../../widgets/live_queue_tracker_widget.dart';

class UpcomingAppointmentCard extends StatefulWidget {
  final String date;
  final String time;
  final DateTime? appointmentDateTime;
  final String doctorName;
  final String specialty;
  final String patientName;
  final int? maLuotKham;
  final String? roomName;
  final VoidCallback onTap;

  const UpcomingAppointmentCard({
    Key? key,
    required this.date,
    required this.time,
    this.appointmentDateTime,
    required this.doctorName,
    required this.specialty,
    required this.patientName,
    this.maLuotKham,
    this.roomName,
    required this.onTap,
  }) : super(key: key);

  @override
  State<UpcomingAppointmentCard> createState() => _UpcomingAppointmentCardState();
}

class _UpcomingAppointmentCardState extends State<UpcomingAppointmentCard> {
  late bool _showQueueTracker;

  @override
  void initState() {
    super.initState();
    _showQueueTracker = _checkIsToday();
  }

  bool _checkIsToday() {
    if (widget.appointmentDateTime != null) {
      final now = DateTime.now();
      return widget.appointmentDateTime!.year == now.year &&
          widget.appointmentDateTime!.month == now.month &&
          widget.appointmentDateTime!.day == now.day;
    }
    try {
      final parts = widget.date.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final now = DateTime.now();
        return year == now.year && month == now.month && day == now.day;
      }
    } catch (_) {}
    return false;
  }

  int _getDaysLeft() {
    DateTime? aptDate = widget.appointmentDateTime;
    if (aptDate == null) {
      try {
        final parts = widget.date.split('/');
        if (parts.length == 3) {
          aptDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      } catch (_) {}
    }
    if (aptDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(aptDate.year, aptDate.month, aptDate.day);
      return target.difference(today).inDays;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _checkIsToday();
    final daysLeft = _getDaysLeft();

    String badgeText = 'Sắp tới';
    Color badgeTextColor = AppColors.primary;
    Color badgeBgColor = Colors.white.withValues(alpha: 0.85);

    if (isToday) {
      badgeText = 'Hôm nay';
      badgeTextColor = const Color(0xFF047857);
      badgeBgColor = const Color(0xFFD1FAE5);
    } else if (daysLeft > 0) {
      badgeText = 'Còn $daysLeft ngày';
      badgeTextColor = const Color(0xFF1E40AF);
      badgeBgColor = const Color(0xFFDBEAFE);
    } else if (daysLeft < 0) {
      badgeText = 'Đã qua';
      badgeTextColor = Colors.grey.shade700;
      badgeBgColor = Colors.grey.shade200;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.date}, ${widget.time}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(fontSize: 12, color: badgeTextColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
              title: Text(
                widget.doctorName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.specialty),
            ),
            const Divider(color: Colors.white54, height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.person_pin, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bệnh nhân: ${widget.patientName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.maLuotKham != null)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showQueueTracker = !_showQueueTracker;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showQueueTracker ? Icons.visibility_off_outlined : Icons.radar_outlined,
                            size: 14,
                            color: const Color(0xFF0056D2),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _showQueueTracker ? 'Thu gọn' : 'Xem hàng đợi',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0056D2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.maLuotKham != null && !_showQueueTracker && !isToday && daysLeft > 0)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lịch khám ngày ${widget.date}. Hàng đợi trực tiếp sẽ mở vào đúng ngày khám.',
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),

            // Widget Live Queue Tracker theo thời gian thực
            if (widget.maLuotKham != null && _showQueueTracker) ...[
              const SizedBox(height: 14),
              LiveQueueTrackerWidget(
                maLuotKham: widget.maLuotKham!,
                initialDoctorName: widget.doctorName,
                initialRoom: widget.roomName,
                isCompact: true,
              ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                ),
                child: const Text('Xem phiếu khám (E-Ticket)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
