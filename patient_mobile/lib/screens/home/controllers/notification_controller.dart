import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp.toIso8601String(),
        'isRead': isRead,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        id: json['id'],
        title: json['title'],
        body: json['body'],
        timestamp: DateTime.parse(json['timestamp']),
        isRead: json['isRead'],
      );
}

class NotificationController extends GetxController {
  var notifications = <AppNotification>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notificationsJson = prefs.getString('notifications');
    if (notificationsJson != null) {
      final List<dynamic> decoded = jsonDecode(notificationsJson);
      notifications.value = decoded.map((e) => AppNotification.fromJson(e)).toList();
    }
  }

  Future<void> saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(notifications.map((e) => e.toJson()).toList());
    await prefs.setString('notifications', encoded);
  }

  void addNotification(RemoteMessage message) {
    final newNotif = AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Thông báo mới',
      body: message.notification?.body ?? '',
      timestamp: DateTime.now(),
    );
    notifications.insert(0, newNotif);
    saveNotifications();
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index].isRead = true;
      notifications.refresh();
      saveNotifications();
    }
  }

  void markAllAsRead() {
    for (var n in notifications) {
      n.isRead = true;
    }
    notifications.refresh();
    saveNotifications();
  }
}
