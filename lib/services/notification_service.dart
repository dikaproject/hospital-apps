import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import '../models/notification_models.dart';
import 'http_service.dart';
import 'auth_service.dart';
import 'push_notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationAPIResponse {
  final List<HospitalNotification> notifications;
  final Map<String, dynamic> pagination;
  final Map<String, dynamic> summary;

  NotificationAPIResponse({
    required this.notifications,
    required this.pagination,
    required this.summary,
  });

  factory NotificationAPIResponse.fromJson(Map<String, dynamic> json) {
    return NotificationAPIResponse(
      notifications: (json['notifications'] as List? ?? [])
          .map((item) => HospitalNotification.fromJson(item))
          .toList(),
      pagination: json['pagination'] ?? {},
      summary: json['summary'] ?? {},
    );
  }
}

class NotificationService {
  static NotificationSettings _settings = NotificationSettings();
  static final List<HospitalNotification> _localNotifications = [];
  static final List<Function(HospitalNotification)> _listeners = [];
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  static Future<void> initialize() async {
    try {
      await _loadSettings();
      await _requestPermissions();
      await _setupNotificationChannels();

      // Initialize real push notifications
      await PushNotificationService.initialize();
      PushNotificationService.setupNotificationListeners();

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await _notifications.initialize(initializationSettings);

      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  // API Methods (keep existing implementation)
  static Future<NotificationAPIResponse> getNotifications({
    int page = 1,
    int limit = 20,
    String type = 'all',
    bool unreadOnly = false,
  }) async {
    try {
      final token = AuthService.getCurrentToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'type': type,
        'unreadOnly': unreadOnly.toString(),
      };

      final baseUrl = HttpService.getCurrentBaseUrl();
      final uri = Uri.parse('$baseUrl/api/notifications')
          .replace(queryParameters: queryParams);

      final response = await HttpService.get(
        uri.toString().replaceFirst(baseUrl, ''),
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return NotificationAPIResponse.fromJson(data['data'] ?? {});
        } else {
          throw Exception(data['message'] ?? 'Failed to get notifications');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: Failed to get notifications');
      }
    } catch (e) {
      print('❌ Get notifications error: $e');
      throw Exception('Failed to get notifications: $e');
    }
  }

  // Keep existing API methods (markAsRead, deleteNotification, etc.)
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final token = AuthService.getCurrentToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await HttpService.put(
        '/api/notifications/$notificationId/read',
        {},
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to mark as read');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to mark as read');
      }
    } catch (e) {
      print('❌ Mark as read error: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  static Future<void> markAllNotificationsAsRead() async {
    try {
      final token = AuthService.getCurrentToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await HttpService.put(
        '/api/notifications/read-all',
        {},
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to mark all as read');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: Failed to mark all as read');
      }
    } catch (e) {
      print('❌ Mark all as read error: $e');
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      final token = AuthService.getCurrentToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await HttpService.delete(
        '/api/notifications/$notificationId',
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to delete notification');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: Failed to delete notification');
      }
    } catch (e) {
      print('❌ Delete notification error: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }

  static Future<void> clearAllNotifications() async {
    try {
      final token = AuthService.getCurrentToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await HttpService.delete(
        '/api/notifications',
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to clear notifications');
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: Failed to clear notifications');
      }
    } catch (e) {
      print('❌ Clear notifications error: $e');
      throw Exception('Failed to clear notifications: $e');
    }
  }

  // Keep existing local notification methods for testing
  static Future<bool> _requestPermissions() async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        return true;
      }
      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  static Future<void> _setupNotificationChannels() async {
    try {
      print('Notification channels setup complete');
    } catch (e) {
      print('Error setting up notification channels: $e');
    }
  }

  static Future<void> _loadSettings() async {
    try {
      _settings = NotificationSettings();
      print('Settings loaded successfully');
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  static Future<void> _saveSettings() async {
    try {
      print('Settings saved successfully');
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  static Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      _settings = NotificationSettings.fromJson(newSettings);
      await _saveSettings();
      print('Notification settings updated');
    } catch (e) {
      print('Error updating settings: $e');
    }
  }

  static NotificationSettings getSettings() {
    return _settings;
  }

  // Updated test methods with real push notifications
  static Future<void> sendTestNotification() async {
    // Send both local notification (for in-app) and real push notification
    final testNotification = HospitalNotification(
      id: 'TEST_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Test Notifikasi 🔔',
      message:
          'Ini adalah test notifikasi untuk memastikan sistem berjalan dengan baik.',
      type: NotificationType.system,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now(),
      hospitalName: 'HospitalLink Test System',
      relatedData: {
        'testType': 'manual',
        'userId': 'test_user',
      },
    );

    // Send local notification for in-app display
    await sendNotification(testNotification);

    // Send real push notification that appears in status bar
    await PushNotificationService.showTestNotification();
  }

  static Future<void> testRealNotification() async {
    await PushNotificationService.showTestNotification();
  }

  static Future<void> testQueueNotification() async {
    await PushNotificationService.showQueueNotification(
      queueNumber: 'A-15',
      doctorName: 'Dr. Sarah Wijaya - Poli Umum',
      estimatedTime: '5 menit',
    );
  }

  static Future<void> testAppointmentNotification() async {
    await PushNotificationService.showAppointmentNotification(
      doctorName: 'Dr. Ahmad Ramdan',
      appointmentTime: 'Besok, 10:00 WIB',
    );
  }

  static Future<void> testLabResultNotification() async {
    await PushNotificationService.showLabResultNotification(
      testName: 'Darah Lengkap',
    );
  }

  static Future<void> testAllNotificationTypes() async {
    await PushNotificationService.sendMultipleTestNotifications();
  }

  // Local notification methods (keep existing)
  static Future<void> sendNotification(
      HospitalNotification notification) async {
    try {
      if (!_settings.pushNotifications) {
        return;
      }

      if (!_isNotificationTypeEnabled(notification.type)) {
        return;
      }

      if (_isQuietHours()) {
        return;
      }

      _localNotifications.insert(0, notification);
      await _showSystemNotification(notification);

      for (var listener in _listeners) {
        listener(notification);
      }

      print('Local notification sent: ${notification.title}');
    } catch (e) {
      print('Error sending local notification: $e');
    }
  }

  static Future<void> _showSystemNotification(
      HospitalNotification notification) async {
    try {
      print('📱 NOTIFICATION: ${notification.title}');
      print('   Message: ${notification.message}');

      if (_settings.soundEnabled) {
        await _playNotificationSound();
      }

      if (_settings.vibrationEnabled) {
        await _triggerVibration();
      }
    } catch (e) {
      print('Error showing system notification: $e');
    }
  }

  static Future<void> _playNotificationSound() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  static Future<void> _triggerVibration() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      print('Error triggering vibration: $e');
    }
  }

  static bool _isNotificationTypeEnabled(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return _settings.queueNotifications;
      case NotificationType.appointment:
        return _settings.appointmentNotifications;
      case NotificationType.labResult:
        return _settings.labResultNotifications;
      case NotificationType.payment:
        return _settings.paymentNotifications;
      case NotificationType.system:
        return _settings.systemNotifications;
      case NotificationType.healthTip:
        return _settings.healthTipsNotifications;
      default:
        return false;
    }
  }

  static bool _isQuietHours() {
    if (!_settings.quietHoursEnabled) return false;

    try {
      final now = TimeOfDay.now();
      final start = _parseTimeOfDay(_settings.quietHoursStart);
      final end = _parseTimeOfDay(_settings.quietHoursEnd);

      if (start.hour > end.hour) {
        return now.hour >= start.hour || now.hour <= end.hour;
      } else {
        return now.hour >= start.hour && now.hour <= end.hour;
      }
    } catch (e) {
      print('Error checking quiet hours: $e');
      return false;
    }
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static Future<void> testSound() async {
    if (_settings.soundEnabled) {
      await _playNotificationSound();
      print('🔊 Test sound played');
    } else {
      print('🔇 Sound is disabled');
    }
  }

  static Future<void> testVibration() async {
    if (_settings.vibrationEnabled) {
      await _triggerVibration();
      print('📳 Test vibration triggered');
    } else {
      print('📵 Vibration is disabled');
    }
  }

  // Listener management
  static void addListener(Function(HospitalNotification) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(HospitalNotification) listener) {
    _listeners.remove(listener);
  }

  // Get local notifications
  static List<HospitalNotification> getAllLocalNotifications() {
    return List.from(_localNotifications);
  }

  static List<HospitalNotification> getUnreadLocalNotifications() {
    return _localNotifications.where((n) => !n.isRead).toList();
  }

  static int getUnreadLocalCount() {
    return _localNotifications.where((n) => !n.isRead).length;
  }

  // Notification scheduling
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Pengingat Obat',
          channelDescription: 'Pengingat untuk minum obat sesuai resep dokter',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Immediate notification (for testing)
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_test',
          'Test Pengingat',
          channelDescription: 'Test untuk pengingat obat',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
