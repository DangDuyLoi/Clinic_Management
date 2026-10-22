import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/main/main_screen.dart';
import '../screens/home/controllers/notification_controller.dart';
import 'auth_service.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Xin quyền thông báo trên iOS / Android 13+
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM: Quyền thông báo đã được cấp');
    } else {
      print('FCM: Người dùng chưa cấp quyền thông báo');
    }

    // 2. Lấy FCM Token để backend biết thiết bị nào mà gửi
    try {
      String? token = await _firebaseMessaging.getToken();
      print("Firebase Messaging Token: $token");
      
      if (token != null) {
        final phone = await AuthService().getUserPhone();
        if (phone != null && phone.isNotEmpty) {
          await AuthService().updateFcmToken(phone, token);
          print("Đã cập nhật FCM Token cho số điện thoại: $phone");
        }
      }
    } catch (e) {
      print("Lỗi lấy FCM token: $e");
    }

    // Lắng nghe khi token thay đổi
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print("FCM Token refreshed: $newToken");
      final phone = await AuthService().getUserPhone();
      if (phone != null && phone.isNotEmpty) {
        await AuthService().updateFcmToken(phone, newToken);
      }
    });

    // 3. Khởi tạo Flutter Local Notifications (để hiện pop-up khi app đang mở)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClickFromPayload(response.payload);
      },
    );

    // 4. Lắng nghe thông báo khi app ĐANG MỞ (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận được thông báo Foreground: ${message.messageId}');
      _showLocalNotification(message);
    });

    // 5. Lắng nghe sự kiện click vào thông báo (khi app chạy nền)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Người dùng click vào thông báo: ${message.messageId}');
      _handleNotificationClick(message);
    });

    // 6. Kiểm tra nếu app được mở từ một thông báo (khi app đã tắt hoàn toàn)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App mở từ thông báo (terminated): ${initialMessage.messageId}');
      Future.delayed(const Duration(seconds: 2), () {
        _handleNotificationClick(initialMessage);
      });
    }
  }

  // Hàm hiển thị Notification khi app đang mở (Foreground)
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      // Lưu vào Controller
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().addNotification(message);
      } else {
        Get.put(NotificationController()).addNotification(message);
      }

      final type = message.data['type'];

      if (type == 'checkin_success') {
        showCheckinSuccessNotification(
          title: notification.title,
          body: notification.body,
        );
      } else if (type == 'payment_success') {
        showPaymentSuccessNotification(
          title: notification.title,
          body: notification.body,
        );
      } else {
        Get.snackbar(
          notification.title ?? "Thông báo",
          notification.body ?? "",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          backgroundColor: Get.theme.colorScheme.surface,
          colorText: Get.theme.colorScheme.onSurface,
          margin: const EdgeInsets.all(16),
          boxShadows: [
            BoxShadow(
              color: Get.theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
          onTap: (_) => _handleNotificationClick(message),
        );
      }
    }
  }

  /// Thông báo tiếp nhận / Check-in thành công (gọi từ FCM hoặc Real-time polling)
  static void showCheckinSuccessNotification({String? title, String? body}) {
    final notifTitle = title ?? "🎉 Check-in thành công!";
    final notifBody = body ?? "Bạn đã được tiếp nhận tại quầy lễ tân. Vui lòng ngồi chờ đến lượt khám.";

    // 1. Lưu vào NotificationController (để hiện trong tab Thông báo ở thanh điều hướng đáy & tăng badge)
    try {
      final notifController = Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());
      notifController.addNotificationItem(
        title: notifTitle,
        body: notifBody,
      );
    } catch (_) {}

    // 2. Hiển thị thông báo nổi trên đầu màn hình
    Get.snackbar(
      notifTitle,
      notifBody,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 6),
      backgroundColor: const Color(0xFF059669),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 30),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  /// Thông báo thanh toán thành công
  static void showPaymentSuccessNotification({String? title, String? body}) {
    final notifTitle = title ?? "💳 Thanh toán thành công!";
    final notifBody = body ?? "Mã QR check-in tiếp nhận đã sẵn sàng.";

    // 1. Lưu vào NotificationController
    try {
      final notifController = Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());
      notifController.addNotificationItem(
        title: notifTitle,
        body: notifBody,
      );
    } catch (_) {}

    // 2. Hiển thị thông báo nổi
    Get.snackbar(
      notifTitle,
      notifBody,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      backgroundColor: const Color(0xFF0284C7),
      colorText: Colors.white,
      icon: const Icon(Icons.payment, color: Colors.white, size: 28),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  /// Thông báo sắp đến lượt khám (còn 2-3 số)
  static void showQueueTurnNotification({
    String? title,
    String? body,
    String? room,
    int? yourNumber,
    int? currentServing,
  }) {
    final notifTitle = title ?? "🔔 Sắp đến lượt bạn!";
    final notifBody = body ??
        "Số của bạn: #${yourNumber ?? 18} (Đang phục vụ #${currentServing ?? 15}). Vui lòng có mặt trước cửa ${room ?? 'phòng khám'}.";

    // 1. Lưu vào NotificationController
    try {
      final notifController = Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());
      notifController.addNotificationItem(
        title: notifTitle,
        body: notifBody,
      );
    } catch (_) {}

    // 2. Hiển thị thông báo nổi
    Get.snackbar(
      notifTitle,
      notifBody,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 6),
      backgroundColor: const Color(0xFFD97706),
      colorText: Colors.white,
      icon: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 28),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  // Xử lý khi người dùng click vào thông báo FCM
  static void _handleNotificationClick(RemoteMessage message) {
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().addNotification(message);
    } else {
      Get.put(NotificationController()).addNotification(message);
    }

    final type = message.data['type'];
    
    if (type == 'checkin_success') {
      Get.defaultDialog(
        title: "🎉 Đã tiếp nhận!",
        middleText: message.notification?.body ?? "Bạn đã được tiếp nhận tại quầy lễ tân. Vui lòng ngồi chờ đến lượt khám.",
        textConfirm: "Đã hiểu",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF059669),
        onConfirm: () => Get.back(),
      );
    } else if (type == 'queue_turn_alert') {
      Get.defaultDialog(
        title: "🔔 Sắp đến lượt khám!",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706), fontSize: 18),
        middleText: message.notification?.body ?? "Vui lòng có mặt trước cửa phòng khám để chuẩn bị vào khám.",
        middleTextStyle: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
        textConfirm: "Đã hiểu",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFD97706),
        onConfirm: () => Get.back(),
      );
    } else if (type == 'payment_success') {
      Get.snackbar(
        '💳 Thanh toán hoàn tất',
        message.notification?.body ?? 'Lượt khám đã được thanh toán thành công!',
        backgroundColor: const Color(0xFF0284C7),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } else if (type == 'booking_confirmed') {
      Get.offAll(() => const MainScreen());
      Get.snackbar(
        '📋 Lịch hẹn',
        message.notification?.body ?? 'Bạn có lịch hẹn mới!',
        duration: const Duration(seconds: 5),
      );
    } else {
      Get.snackbar("Thông báo", message.notification?.body ?? "Có thông báo mới");
    }
  }

  // Xử lý khi click local notification (từ payload string)
  static void _handleNotificationClickFromPayload(String? payload) {
    if (payload == 'booking_confirmed' || payload == 'checkin_success') {
      Get.offAll(() => const MainScreen());
    }
  }
}
