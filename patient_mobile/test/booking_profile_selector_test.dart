import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:umc_care_clone/screens/booking/controllers/booking_controller.dart';
import 'package:umc_care_clone/screens/booking/views/summary_screen.dart';
import 'package:umc_care_clone/services/patient_profile_service.dart';

void main() {
  late BookingController controller;

  final firstProfile = <String, dynamic>{
    'ma_ho_so': 1,
    'ho_chu_lot': 'Nguyễn Văn',
    'ten': 'An',
    'so_dien_thoai': '0900000001',
    'quan_he': 'Bản thân',
  };
  final secondProfile = <String, dynamic>{
    'ma_ho_so': 2,
    'ho_chu_lot': 'Trần Thị',
    'ten': 'Bình',
    'so_dien_thoai': '0900000002',
    'quan_he': 'Con cái',
  };

  setUp(() {
    Get.reset();
    PatientProfileService.cachedProfiles
      ..clear()
      ..addAll([firstProfile, secondProfile]);
    controller = Get.put(BookingController());
    controller.selectedProfile.value = firstProfile;
  });

  tearDown(() {
    PatientProfileService.cachedProfiles.clear();
    Get.reset();
  });

  testWidgets('shows the selected patient and allows changing profiles', (
    tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: SummaryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('Mã hồ sơ: 1  ·  SĐT: 0900000001'), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trần Thị Bình'));
    await tester.pumpAndSettle();

    expect(controller.selectedProfile.value?['ma_ho_so'], 2);
    expect(find.text('Trần Thị Bình'), findsOneWidget);
    expect(find.text('Mã hồ sơ: 2  ·  SĐT: 0900000002'), findsOneWidget);
  });
}
