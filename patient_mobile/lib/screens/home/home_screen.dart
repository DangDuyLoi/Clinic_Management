import 'dart:ui';
import 'package:flutter/material.dart';
import 'widgets/custom_header.dart';
import 'widgets/patient_id_card.dart';
import 'widgets/upcoming_appointment_card.dart';
import 'widgets/feature_grid.dart';
import '../booking/booking_screen.dart';
import '../emr/emr_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.blue.shade50,
              ), // Fallback if image not found
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.white.withOpacity(0.4)),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [const CustomHeader(patientName: 'Đặng Duy Lợi')],
                ),
                const SizedBox(height: 60),
                const UpcomingAppointmentCard(
                  date: 'Ngày mai',
                  time: '08:30',
                  doctorName: 'ThS.BS Nguyễn Văn A',
                  specialty: 'Chuyên khoa Tim mạch',
                ),
                FeatureGrid(
                  onBookAppointment: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BookingScreen(),
                      ),
                    );
                  },
                  onEmr: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmrScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
