import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../../widgets/live_queue_tracker_widget.dart';

class UpcomingAppointmentCard extends StatefulWidget {
  final String date;
  final String time;
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
  bool _showQueueTracker = true;

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Sắp tới',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
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
                Row(
                  children: [
                    const Icon(Icons.person_pin, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Bệnh nhân: ${widget.patientName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
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
                            _showQueueTracker ? 'Thu gọn' : 'Live Queue',
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
