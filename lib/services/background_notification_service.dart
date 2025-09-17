import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'push_notification_service.dart';
import 'auth_service.dart';
import 'http_service.dart';

class BackgroundNotificationService {
  static const String _lastNotificationIdKey = 'last_notification_id';
  static Timer? _pollingTimer;
  static String? _lastNotificationId;

  static Future<void> initialize() async {
    print('🔄 Initializing background notification service...');
    await _loadLastNotificationId();
    await _initializeBackgroundService();
    _startPolling();
    print('✅ Background notification service started');
  }

  static Future<void> _initializeBackgroundService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: _onBackgroundStart,
        autoStart: true,
        isForegroundMode: false,
        notificationChannelId: 'background_service',
        initialNotificationTitle: 'HospitalLink Background Service',
        initialNotificationContent: 'Mendeteksi notifikasi baru...',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onBackgroundStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void _onBackgroundStart(ServiceInstance service) async {
    print('🔄 Background service started');

    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkForNewNotifications();
    });
  }

  @pragma('vm:entry-point')
  static bool _onIosBackground(ServiceInstance service) {
    print('🍎 iOS background service');
    return true;
  }

  static void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      print('🔍 Checking for new notifications...');
      if (AuthService.isLoggedIn()) {
        await _checkForNewNotifications();
      } else {
        print('❌ User not logged in, skipping notification check');
      }
    });
  }

  static Future<void> _checkForNewNotifications() async {
    try {
      final token = AuthService.getCurrentToken();
      if (token == null) {
        print('❌ No auth token found');
        return;
      }

      // Direct HTTP call to avoid service dependency issues
      final baseUrl = HttpService.getCurrentBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications?limit=1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Notification check response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final notifications = data['data']?['notifications'] as List?;

        if (notifications != null && notifications.isNotEmpty) {
          final latestNotification = notifications.first;
          final notificationId = latestNotification['id'];

          print('📬 Latest notification ID: $notificationId');
          print('💾 Last stored ID: $_lastNotificationId');

          // Check if this is a new notification
          if (_lastNotificationId != notificationId) {
            print('🆕 New notification detected!');
            await _showPushNotification(latestNotification);
            _lastNotificationId = notificationId;
            await _saveLastNotificationId();
          } else {
            print('📭 No new notifications');
          }
        } else {
          print('📭 No notifications found');
        }
      } else {
        print('❌ Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking notifications: $e');
    }
  }

  static Future<void> _showPushNotification(
      Map<String, dynamic> notification) async {
    try {
      print('📱 Showing push notification: ${notification['title']}');

      // Use PushNotificationService to show real notification
      await PushNotificationService.initialize();

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Show the actual push notification
      await PushNotificationService.showHospitalNotificationFromMap(
          notification);

      print('✅ Push notification sent successfully');
    } catch (e) {
      print('❌ Error showing push notification: $e');
    }
  }

  static Future<void> _loadLastNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    _lastNotificationId = prefs.getString(_lastNotificationIdKey);
    print('💾 Loaded last notification ID: $_lastNotificationId');
  }

  static Future<void> _saveLastNotificationId() async {
    if (_lastNotificationId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastNotificationIdKey, _lastNotificationId!);
      print('💾 Saved last notification ID: $_lastNotificationId');
    }
  }

  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('⏹️ Background polling stopped');
  }

  static void dispose() {
    stopPolling();
  }

  // Manual trigger for testing
  static Future<void> manualCheck() async {
    print('🔍 Manual notification check triggered');
    await _checkForNewNotifications();
  }

  // Force reset last notification ID (for testing)
  static Future<void> resetLastNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastNotificationIdKey);
    _lastNotificationId = null;
    print('🔄 Last notification ID reset');
  }
}
