import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/login_screen.dart';
import 'firebase_options.dart'; // Make sure you have generated this via flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If firebase_options.dart is missing or Firebase is not configured, it will print here
    print("Firebase initialization error: \$e");
  }
  runApp(const UMCCareCloneApp());
}

class UMCCareCloneApp extends StatelessWidget {
  const UMCCareCloneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUIT Care',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
