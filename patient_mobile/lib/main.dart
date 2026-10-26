import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'firebase_options.dart';
import 'services/patient_profile_service.dart';
import 'services/master_data_service.dart';
import 'services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/chatbot/chatbot_screen.dart';
import 'screens/booking/views/select_profile_screen.dart';
import 'screens/profile/profile_empty_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/payment/payment_screen.dart';

// Hàm xử lý thông báo khi app chạy ngầm (Background / Terminated)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await FCMService.init();
  } catch (e) {
    print("Firebase initialization error: $e");
  }
  
  await MasterDataService.initialize();
  await PatientProfileService.loadProfiles();
  
  runApp(const UMCCareCloneApp());
}

class UMCCareCloneApp extends StatelessWidget {
  const UMCCareCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HUIT Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(), // Khởi động luồng chuẩn của ứng dụng
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/main', page: () => const MainScreen()),
        GetPage(name: '/chatbot', page: () => const ChatbotScreen()),
        GetPage(
          name: '/booking',
          page: () => PatientProfileService.cachedProfiles.isEmpty
              ? const ProfileEmptyScreen()
              : SelectProfileScreen(),
        ),
        GetPage(name: '/payment', page: () => const PaymentScreen()),
      ],
    );
  }
}
