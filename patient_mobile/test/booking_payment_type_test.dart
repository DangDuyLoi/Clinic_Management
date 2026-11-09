import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:umc_care_clone/screens/booking/controllers/booking_controller.dart';

void main() {
  late BookingController controller;

  setUp(() {
    Get.reset();
    controller = BookingController();
  });

  tearDown(() {
    Get.reset();
  });

  Map<String, dynamic> bookingItem({
    required int doctorId,
    required int price,
    required bool isBhyt,
    DateTime? date,
  }) {
    return {
      'specialty': {'name': 'Specialty $doctorId', 'gia_kham': price},
      'doctor': {'id': doctorId},
      'date': date ?? DateTime(2026, 12, 1),
      'timeSlot': {'time': '08:00:00'},
      'price': price,
      'isBhyt': isBhyt,
      'bhytCardNumber': isBhyt ? 'AB1012345678901' : '',
    };
  }

  test('Service pricing is ALWAYS 100% and NEVER reduced to 30%', () {
    controller.bookedItems.assignAll([
      bookingItem(doctorId: 1, price: 150000, isBhyt: false),
      bookingItem(doctorId: 2, price: 200000, isBhyt: false),
      bookingItem(doctorId: 3, price: 180000, isBhyt: false),
    ]);

    final breakdown = controller.itemCostBreakdown;

    expect(breakdown.length, 3);
    // Every service item must be 100% of base price
    expect(breakdown[0]['cost'], 150000);
    expect(breakdown[0]['rate'], 1.0);
    expect(breakdown[0]['patientPayable'], 150000);

    expect(breakdown[1]['cost'], 200000);
    expect(breakdown[1]['rate'], 1.0);
    expect(breakdown[1]['patientPayable'], 200000);

    expect(breakdown[2]['cost'], 180000);
    expect(breakdown[2]['rate'], 1.0);
    expect(breakdown[2]['patientPayable'], 180000);

    expect(controller.totalBookingCost, 150000 + 200000 + 180000);
  });

  test('BHYT logic per appointment date: Item 1 = 100%, Item 2 = 30% of state price (42.100đ)', () {
    final dateA = DateTime(2026, 12, 1);
    controller.bhytCardNumber.value = 'AB1012345678901'; // Mức hưởng 100%
    controller.bookedItems.assignAll([
      bookingItem(doctorId: 1, price: 42100, isBhyt: true, date: dateA),
      bookingItem(doctorId: 2, price: 42100, isBhyt: true, date: dateA),
    ]);

    final breakdown = controller.itemCostBreakdown;

    expect(breakdown.length, 2);
    // Slot 1: 100% = 42.100đ
    expect(breakdown[0]['cost'], 42100);
    expect(breakdown[0]['rate'], 1.0);

    // Slot 2: 30% = 12.630đ
    expect(breakdown[1]['cost'], 12630);
    expect(breakdown[1]['rate'], 0.30);

    // Total BHYT = 54.730đ < 379.500đ -> Miễn đồng chi trả 100%
    expect(breakdown[0]['patientPayable'], 0);
    expect(breakdown[1]['patientPayable'], 0);
    expect(controller.totalBookingCost, 0);
  });

  test('BHYT 2-slot limit is per appointment date, not real-time or global', () {
    final dateA = DateTime(2026, 12, 1);
    final dateB = DateTime(2026, 12, 5);

    controller.bookedItems.assignAll([
      bookingItem(doctorId: 1, price: 42100, isBhyt: true, date: dateA),
      bookingItem(doctorId: 2, price: 42100, isBhyt: true, date: dateA),
    ]);

    // On dateA, 2 slots used -> cannot add more BHYT for dateA
    controller.selectedDate.value = dateA;
    controller.selectedDoctor.value = {'id': 3};
    expect(controller.canSelectBhytForCurrentItem, isFalse);

    // On dateB, 0 slots used -> can select BHYT for dateB!
    controller.selectedDate.value = dateB;
    expect(controller.canSelectBhytForCurrentItem, isTrue);
  });

  test('Hybrid mode: 2 BHYT + 1 Service on same date', () {
    final dateA = DateTime(2026, 12, 1);
    controller.bhytCardNumber.value = 'AB1012345678901';
    controller.bookedItems.assignAll([
      bookingItem(doctorId: 1, price: 42100, isBhyt: true, date: dateA),
      bookingItem(doctorId: 2, price: 42100, isBhyt: true, date: dateA),
      bookingItem(doctorId: 3, price: 150000, isBhyt: false, date: dateA),
    ]);

    final breakdown = controller.itemCostBreakdown;

    expect(breakdown.length, 3);
    // BHYT 1: 42.100đ, patient pays 0
    expect(breakdown[0]['cost'], 42100);
    expect(breakdown[0]['patientPayable'], 0);

    // BHYT 2: 12.630đ, patient pays 0
    expect(breakdown[1]['cost'], 12630);
    expect(breakdown[1]['patientPayable'], 0);

    // Service: 150.000đ, patient pays 150.000
    expect(breakdown[2]['cost'], 150000);
    expect(breakdown[2]['patientPayable'], 150000);

    // Total booking cost is strictly the service portion
    expect(controller.totalBookingCost, 150000);
  });

  test('resetBookingSession completely cleans up cart and state to prevent session leak', () {
    controller.bookedItems.assignAll([
      bookingItem(doctorId: 1, price: 150000, isBhyt: false),
    ]);
    controller.selectedDoctor.value = {'id': 1};
    controller.selectedSpecialty.value = {'name': 'Noi Tong Quat'};
    controller.selectedDate.value = DateTime.now();
    controller.bookingType.value = BookingType.dichVu;
    controller.paymentMethod.value = 'vnpay';

    expect(controller.bookedItems.isNotEmpty, isTrue);

    // Call session cleanup
    controller.resetBookingSession();

    expect(controller.bookedItems.isEmpty, isTrue);
    expect(controller.selectedDoctor.value, isNull);
    expect(controller.selectedSpecialty.value, isNull);
    expect(controller.selectedDate.value, isNull);
    expect(controller.bookingType.value, isNull);
    expect(controller.paymentMethod.value, isNull);
  });
}
