import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:umc_care_clone/screens/payment/controllers/payment_tab_controller.dart';
import 'package:umc_care_clone/screens/payment/payment_screen.dart';

void main() {
  setUp(() {
    // Reset GetX trước mỗi test
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('1. Unit Test - PaymentTabController Logic', () {
    test('Khởi tạo Controller và kiểm tra tải dữ liệu ban đầu', () async {
      final controller = Get.put(PaymentTabController());

      // Ban đầu khi khởi tạo, onInit gọi fetchPaymentData
      expect(controller.isLoading.value, true);

      // Đợi hoàn thành tác vụ bất đồng bộ fetchPaymentData
      await Future.delayed(const Duration(milliseconds: 700));

      expect(controller.isLoading.value, false);
      expect(controller.pendingBills.length, 2);
      expect(controller.paymentHistory.length, 3);

      // Kiểm tra dữ liệu bill chờ thanh toán đầu tiên
      final firstBill = controller.pendingBills[0];
      expect(firstBill['ma_luot_kham'], 101);
      expect(firstBill['chuyen_khoa'], 'Khoa Nội Tổng Quát');
      expect(firstBill['bac_si'], 'BS. CKI Nguyễn Văn A');
      expect(firstBill['tien_kham'], 150000);
      expect(firstBill['tong_tien'], 580000);

      // Kiểm tra dữ liệu lịch sử thanh toán đầu tiên
      final firstHistory = controller.paymentHistory[0];
      expect(firstHistory['ma_giao_dich'], 'VNP14892019');
      expect(firstHistory['trang_thai'], 'Thành công');
      expect(firstHistory['tong_tien'], 570000);
    });

    test('Kiểm tra hàm formatCurrency định dạng tiền VNĐ chuẩn xác', () {
      final controller = Get.put(PaymentTabController());
      expect(controller.formatCurrency(150000), contains('150.000'));
      expect(controller.formatCurrency(580000), contains('580.000'));
      expect(controller.formatCurrency(1250000), contains('1.250.000'));
    });
  });

  group('2. Widget Test - PaymentScreen UI & Interactions', () {
    testWidgets('Kiểm tra hiển thị đầy đủ Tab Chờ thanh toán và chi tiết viện phí',
        (WidgetTester tester) async {
      // Set kích thước màn hình test mô phỏng điện thoại
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Khởi tạo controller
      final controller = Get.put(PaymentTabController());

      // Render màn hình PaymentScreen
      await tester.pumpWidget(
        const GetMaterialApp(
          home: PaymentScreen(),
        ),
      );

      // Ban đầu controller đang loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Đợi fetchPaymentData hoàn tất và re-render UI
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Kiểm tra tiêu đề AppBar
      expect(find.text('Thanh toán viện phí'), findsOneWidget);

      // Kiểm tra 2 Tab
      expect(find.text('Chờ thanh toán'), findsWidgets);
      expect(find.text('Lịch sử'), findsOneWidget);

      // Kiểm tra thông tin trên Card Tab 1
      expect(find.text('Khoa Nội Tổng Quát'), findsOneWidget);
      expect(find.text('BS. CKI Nguyễn Văn A'), findsOneWidget);
      expect(find.text('Tiền khám'), findsWidgets);
      expect(find.text('Tiền dịch vụ / CLS'), findsWidgets);
      expect(find.text('Tiền thuốc'), findsWidgets);

      // Kiểm tra nút Thanh toán VNPay
      expect(find.text('Thanh toán VNPay'), findsWidgets);
    });

    testWidgets('Kiểm tra chuyển Tab Lịch sử, Badge Thành công và Popup Biên lai',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      Get.put(PaymentTabController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: PaymentScreen(),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Tap chuyển sang Tab "Lịch sử"
      await tester.tap(find.text('Lịch sử'));
      await tester.pumpAndSettle();

      // Kiểm tra các phần tử trong Tab Lịch sử
      expect(find.text('VNP14892019'), findsOneWidget);
      expect(find.text('Thành công'), findsWidgets);
      expect(find.text('Xem biên lai'), findsWidgets);

      // Tap vào nút "Xem biên lai" của thẻ đầu tiên
      await tester.tap(find.text('Xem biên lai').first);
      await tester.pumpAndSettle();

      // Kiểm tra hiển thị Popup Biên lai điện tử
      expect(find.text('BIÊN LAI ĐIỆN TỬ'), findsOneWidget);
      expect(find.text('HỆ THỐNG PHÒNG KHÁM HUIT CARE'), findsOneWidget);
      expect(find.text('Đóng'), findsOneWidget);

      // Đóng modal
      await tester.tap(find.text('Đóng'));
      await tester.pumpAndSettle();
      expect(find.text('BIÊN LAI ĐIỆN TỬ'), findsNothing);
    });

    testWidgets('Kiểm tra Empty State khi không có khoản viện phí nào',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = Get.put(PaymentTabController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: PaymentScreen(),
        ),
      );
      await tester.pumpAndSettle(const Duration(milliseconds: 800));

      // Xóa hết danh sách chờ thanh toán để test Empty State
      controller.pendingBills.clear();
      await tester.pumpAndSettle();

      // Kiểm tra Text Empty State xuất hiện
      expect(
        find.text('Bạn không có khoản viện phí nào cần thanh toán'),
        findsOneWidget,
      );
    });
  });
}
