import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../screens/main/main_screen.dart';
import '../screens/home/controllers/notification_controller.dart';

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
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // 2. Lấy FCM Token để backend biết thiết bị nào mà gửi
    String? token = await _firebaseMessaging.getToken();
    print("Firebase Messaging Token: $token");
    
    // Đã lấy được Token thành công

    // Lắng nghe khi token thay đổi (ví dụ: gỡ app cài lại)
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print("FCM Token refreshed: $newToken");
      // TODO: Gửi newToken lên Backend qua API /update-fcm-token
    });

    // 3. Khởi tạo Flutter Local Notifications (để hiện pop-up khi app đang mở)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click khi đang trong app
        _handleNotificationClickFromPayload(response.payload);
      },
    );

    // 4. Lắng nghe thông báo khi app ĐANG MỞ (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Nhận được thông báo khi app đang mở: ${message.messageId}');
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
      // Delay một chút để đảm bảo app đã build xong UI
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
            color: Get.theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
        onTap: (_) {
          _handleNotificationClick(message);
        },
      );
    }
  }

  // Xử lý khi người dùng click vào thông báo FCM
  static void _handleNotificationClick(RemoteMessage message) {
    // Lưu vào Controller nếu chưa lưu (cho trường hợp app chạy nền/bị kill)
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().addNotification(message);
    } else {
      Get.put(NotificationController()).addNotification(message);
    }

    final type = message.data['type'];
    
    if (type == 'booking_confirmed') {
      // Điều hướng về trang chủ (có thể mở rộng thêm màn hình chi tiết lượt khám)
      Get.offAll(() => const MainScreen());
      Get.snackbar(
        '📋 Lịch hẹn',
        message.notification?.body ?? 'Bạn có lịch hẹn mới!',
        duration: const Duration(seconds: 5),
      );
    } else {
      // Nếu là thông báo bình thường, có thể điều hướng sang trang Thông báo
      // Get.offAll(() => const MainScreen()); // Có thể cần logic để chọn đúng tab Thông Báo
      Get.snackbar("Thông báo", message.notification?.body ?? "Có thông báo mới");
    }
  }

  // Xử lý khi click local notification (từ payload string)
  static void _handleNotificationClickFromPayload(String? payload) {
    if (payload == 'booking_confirmed') {
      Get.offAll(() => const MainScreen());
    }
  }
}
