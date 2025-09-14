import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import '../models/notification_models.dart';

class PushNotificationService {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'hospitalink_basic',
          channelName: 'HospitalLink Notifications',
          channelDescription: 'Notification channel for HospitalLink app',
          defaultColor: const Color(0xFF2E7D89),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'hospitalink_high',
          channelName: 'HospitalLink High Priority',
          channelDescription: 'High priority notifications for urgent updates',
          defaultColor: const Color(0xFFE74C3C),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
          criticalAlerts: true,
        ),
      ],
      debug: true, // Enable debug mode for testing
    );

    _isInitialized = true;
    print('✅ Push Notification Service initialized');
  }

  static Future<bool> requestPermission() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        final permission = await AwesomeNotifications().requestPermissionToSendNotifications();
        print('🔔 Notification permission: $permission');
        return permission;
      }
      print('✅ Notification permission already granted');
      return true;
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<void> showTestNotification() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('❌ Notification permission denied');
        return;
      }

      final now = DateTime.now();
      final notificationId = now.millisecondsSinceEpoch ~/ 1000;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'hospitalink_high',
          title: '🔔 Test Notifikasi HospitalLink',
          body: 'Ini adalah test push notification yang muncul di status bar Android! Tap untuk membuka app.',
          bigPicture: null,
          notificationLayout: NotificationLayout.Default,
          color: const Color(0xFF2E7D89),
          backgroundColor: const Color(0xFF2E7D89),
          payload: {
            'type': 'test',
            'action': 'open_app',
            'timestamp': now.toIso8601String(),
          },
          autoDismissible: true,
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
          wakeUpScreen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'open',
            label: 'Buka App',
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'dismiss',
            label: 'Tutup',
            autoDismissible: true,
            isDangerousOption: true,
          ),
        ],
      );

      print('✅ Test notification sent with ID: $notificationId');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  static Future<void> showHospitalNotification(HospitalNotification notification) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('❌ Notification permission denied');
        return;
      }

      final channelKey = notification.priority == NotificationPriority.high 
          ? 'hospitalink_high' 
          : 'hospitalink_basic';

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notification.id.hashCode,
          channelKey: channelKey,
          title: notification.title,
          body: notification.message,
          bigPicture: null,
          category: _getNotificationCategory(notification.type),
          notificationLayout: NotificationLayout.Default,
          color: _getNotificationColor(notification.type),
          backgroundColor: _getNotificationColor(notification.type),
          payload: {
            'id': notification.id,
            'type': notification.type.toString(),
            'actionUrl': notification.actionUrl ?? '',
            'hospitalName': notification.hospitalName ?? '',
          },
          autoDismissible: true,
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
          wakeUpScreen: notification.priority == NotificationPriority.high,
        ),
        actionButtons: notification.actionUrl != null ? [
          NotificationActionButton(
            key: 'open_action',
            label: 'Buka',
            autoDismissible: true,
          ),
        ] : null,
      );

      print('✅ Hospital notification sent: ${notification.title}');
    } catch (e) {
      print('❌ Error sending hospital notification: $e');
    }
  }

  static Future<void> showQueueNotification({
    required String queueNumber,
    required String doctorName,
    required String estimatedTime,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) return;

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'hospitalink_high',
          title: '🏥 Antrean Anda Hampir Tiba!',
          body: 'Nomor antrean $queueNumber akan dipanggil dalam $estimatedTime. Bersiaplah ke ruang $doctorName.',
          bigPicture: null,
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.BigText,
          color: const Color(0xFF3498DB),
          backgroundColor: const Color(0xFF3498DB),
          payload: {
            'type': 'queue',
            'queueNumber': queueNumber,
            'doctorName': doctorName,
            'estimatedTime': estimatedTime,
          },
          autoDismissible: false, // Don't auto dismiss for important queue updates
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
          wakeUpScreen: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'check_queue',
            label: 'Cek Antrean',
            autoDismissible: true,
          ),
        ],
      );

      print('✅ Queue notification sent: $queueNumber');
    } catch (e) {
      print('❌ Error sending queue notification: $e');
    }
  }

  static Future<void> showAppointmentNotification({
    required String doctorName,
    required String appointmentTime,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) return;

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'hospitalink_basic',
          title: '📅 Reminder Konsultasi',
          body: 'Jangan lupa konsultasi dengan $doctorName pada $appointmentTime.',
          category: NotificationCategory.Event,
          notificationLayout: NotificationLayout.Default,
          color: const Color(0xFF9B59B6),
          payload: {
            'type': 'appointment',
            'doctorName': doctorName,
            'appointmentTime': appointmentTime,
          },
          autoDismissible: true,
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'view_appointment',
            label: 'Lihat Jadwal',
            autoDismissible: true,
          ),
        ],
      );

      print('✅ Appointment notification sent');
    } catch (e) {
      print('❌ Error sending appointment notification: $e');
    }
  }

  static Future<void> showLabResultNotification({
    required String testName,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final hasPermission = await requestPermission();
      if (!hasPermission) return;

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'hospitalink_basic',
          title: '🧪 Hasil Lab Tersedia',
          body: 'Hasil pemeriksaan $testName sudah dapat dilihat. Tap untuk melihat detail.',
          category: NotificationCategory.Message,
          notificationLayout: NotificationLayout.Default,
          color: const Color(0xFF2ECC71),
          payload: {
            'type': 'lab_result',
            'testName': testName,
          },
          autoDismissible: true,
          showWhen: true,
          displayOnForeground: true,
          displayOnBackground: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'view_result',
            label: 'Lihat Hasil',
            autoDismissible: true,
          ),
        ],
      );

      print('✅ Lab result notification sent');
    } catch (e) {
      print('❌ Error sending lab result notification: $e');
    }
  }

  // Helper methods
  static Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return const Color(0xFF3498DB);
      case NotificationType.appointment:
        return const Color(0xFF9B59B6);
      case NotificationType.labResult:
        return const Color(0xFF2ECC71);
      case NotificationType.payment:
        return const Color(0xFFF39C12);
      case NotificationType.system:
        return const Color(0xFF34495E);
      case NotificationType.healthTip:
        return const Color(0xFF1ABC9C);
    }
  }

  static NotificationCategory _getNotificationCategory(NotificationType type) {
    switch (type) {
      case NotificationType.queue:
        return NotificationCategory.Reminder;
      case NotificationType.appointment:
        return NotificationCategory.Event;
      case NotificationType.labResult:
        return NotificationCategory.Message;
      case NotificationType.payment:
        return NotificationCategory.Message;
      case NotificationType.system:
        return NotificationCategory.Service;
      case NotificationType.healthTip:
        return NotificationCategory.Recommendation;
    }
  }

  // Listen to notification actions
  static void setupNotificationListeners() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    print('📱 Notification created: ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    print('👀 Notification displayed: ${receivedNotification.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    print('❌ Notification dismissed: ${receivedAction.title}');
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    print('🔔 Notification action received: ${receivedAction.actionType}');
    print('   Action Key: ${receivedAction.buttonKeyPressed}');
    
    // Handle notification tap actions here
    final payload = receivedAction.payload;
    if (payload != null) {
      final actionUrl = payload['actionUrl'];
      final type = payload['type'];
      
      print('Action URL: $actionUrl');
      print('Notification Type: $type');
      
      // You can navigate to specific screens based on actionUrl
      // NavigationService.navigateTo(actionUrl);
    }
  }

  // Utility methods
  static Future<int> getBadgeCount() async {
    return await AwesomeNotifications().getGlobalBadgeCounter();
  }

  static Future<void> setBadgeCount(int count) async {
    await AwesomeNotifications().setGlobalBadgeCounter(count);
  }

  static Future<void> clearAllNotifications() async {
    await AwesomeNotifications().cancelAll();
    await setBadgeCount(0);
  }

  static Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  // Test different notification types
  static Future<void> sendMultipleTestNotifications() async {
    await showTestNotification();
    
    await Future.delayed(const Duration(seconds: 2));
    await showQueueNotification(
      queueNumber: 'A-15',
      doctorName: 'Dr. Sarah Wijaya - Poli Umum',
      estimatedTime: '5 menit',
    );
    
    await Future.delayed(const Duration(seconds: 2));
    await showAppointmentNotification(
      doctorName: 'Dr. Ahmad Ramdan',
      appointmentTime: 'Besok, 10:00 WIB',
    );
    
    await Future.delayed(const Duration(seconds: 2));
    await showLabResultNotification(
      testName: 'Darah Lengkap',
    );
  }
}