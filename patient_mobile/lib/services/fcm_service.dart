import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

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
    
    // Hiển thị Token lên màn hình điện thoại để dễ copy
    if (token != null) {
      Get.snackbar(
        "FCM Token",
        token,
        duration: const Duration(seconds: 15),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    // TODO: Gửi token này lên Backend (Lưu vào bảng Users)

    // 3. Khởi tạo Flutter Local Notifications (để hiện pop-up khi app đang mở)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification click
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
  }

  // Hàm hiển thị Local Notification khi app đang mở
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: platformChannelSpecifics,
      );
    }
  }

  static void _handleNotificationClick(RemoteMessage message) {
    // Điều hướng dựa vào data của notification
    // Ví dụ: message.data['type'] == 'booking_reminder' -> Get.to(() => TrangChiTietKham())
    Get.snackbar("Thông báo", message.notification?.body ?? "Có thông báo mới");
  }
}
