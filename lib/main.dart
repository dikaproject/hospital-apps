import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'services/background_notification_service.dart';
import 'services/work_manager_service.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone for notifications
  tz.initializeTimeZones();

  try {
    print('🚀 Initializing notification services...');

    // 1. Initialize Push Notification Service FIRST
    await PushNotificationService.initialize();
    await PushNotificationService.requestPermission();
    PushNotificationService.setupNotificationListeners();
    print('✅ Push notification service initialized');

    // 2. Initialize Notification Service
    await NotificationService.initialize();
    print('✅ Notification service initialized');

    // 3. Initialize Background Service for polling
    await BackgroundNotificationService.initialize();
    print('✅ Background service initialized');

    // Optional: WorkManager as backup
    // await WorkManagerService.initialize();

    print('🎉 All notification services ready!');

    // Test notification immediately
    await _testNotificationOnStartup();
  } catch (e) {
    print('❌ Error initializing notification services: $e');
  }

  runApp(const MyApp());
}

// Test notification on app startup
Future<void> _testNotificationOnStartup() async {
  try {
    // Wait 3 seconds then send test notification
    Future.delayed(const Duration(seconds: 3), () async {
      print('🧪 Sending startup test notification...');
      await PushNotificationService.showTestNotification();
    });
  } catch (e) {
    print('❌ Test notification failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HospitalLink',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D89)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
