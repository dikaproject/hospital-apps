import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'notification_service.dart';
import 'auth_service.dart';
import 'http_service.dart';

class WorkManagerService {
  static const String _notificationCheckTask = "notification_check_task";

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );

    await _scheduleNotificationCheck();
  }

  static Future<void> _scheduleNotificationCheck() async {
    await Workmanager().registerPeriodicTask(
      _notificationCheckTask,
      _notificationCheckTask,
      frequency: const Duration(minutes: 15), // Minimum 15 minutes
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔧 WorkManager task executed: $task');

    try {
      // Check for new notifications
      await _checkNotificationsInBackground();
      return Future.value(true);
    } catch (e) {
      print('❌ WorkManager task failed: $e');
      return Future.value(false);
    }
  });
}

Future<void> _checkNotificationsInBackground() async {
  try {
    // Get stored auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) return;

    // Check for new notifications via HTTP
    final response = await http.get(
      Uri.parse('${HttpService.getCurrentBaseUrl()}/api/notifications?limit=1'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final notifications = data['data']['notifications'] as List?;

      if (notifications != null && notifications.isNotEmpty) {
        final latestNotification = notifications.first;

        // Check if this is new
        final lastId = prefs.getString('last_notification_id');
        if (lastId != latestNotification['id']) {
          await _showBackgroundNotification(latestNotification);
          await prefs.setString(
              'last_notification_id', latestNotification['id']);
        }
      }
    }
  } catch (e) {
    print('❌ Background notification check failed: $e');
  }
}

Future<void> _showBackgroundNotification(
    Map<String, dynamic> notification) async {
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  await localNotifications.show(
    notification['id'].hashCode,
    '🏥 ${notification['title']}',
    notification['message'],
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'hospital_push',
        'Hospital Push Notifications',
        channelDescription: 'Push notifications dari rumah sakit',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}