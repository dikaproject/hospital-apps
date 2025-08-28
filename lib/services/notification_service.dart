import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/notification_models.dart';

class NotificationService {
  static NotificationSettings _settings = NotificationSettings();
  static final List<HospitalNotification> _notifications = [];
  static final List<Function(HospitalNotification)> _listeners = [];

  // Initialize notification service
  static Future<void> initialize() async {
    try {
      await _loadSettings();
      await _requestPermissions();
      await _setupNotificationChannels();
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  // Request notification permissions
  static Future<bool> _requestPermissions() async {
    try {
      // For iOS and Android 13+, request permission
      if (Platform.isIOS || Platform.isAndroid) {
        // In a real app, you would use firebase_messaging or flutter_local_notifications
        // For now, we'll simulate permission granted
        return true;
      }
      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  // Setup notification channels (Android)
  static Future<void> _setupNotificationChannels() async {
    try {
      // In a real app, you would create notification channels here
      // This is a simulation
      print('Notification channels setup complete');
    } catch (e) {
      print('Error setting up notification channels: $e');
    }
  }

  // Load settings from storage
  static Future<void> _loadSettings() async {
    try {
      // In a real app, load from SharedPreferences
      // For now, use default settings
      _settings = NotificationSettings();
      print('Settings loaded successfully');
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Save settings to storage
  static Future<void> _saveSettings() async {
    try {
      // In a real app, save to SharedPreferences
      print('Settings saved successfully');
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  // Update notification settings
  static Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    try {
      _settings = NotificationSettings.fromJson(newSettings);
      await _saveSettings();
      print('Notification settings updated');
    } catch (e) {
      print('Error updating settings: $e');
    }
  }

  // Get current settings
  static NotificationSettings getSettings() {
    return _settings;
  }

  // Send a notification
  static Future<void> sendNotification(
      HospitalNotification notification) async {
    try {
      // Check if notifications are enabled
      if (!_settings.pushNotifications) {
        return;
      }

      // Check notification type permissions
      if (!_isNotificationTypeEnabled(notification.type)) {
        return;
      }

      // Check quiet hours
      if (_isQuietHours()) {
        // Store for later or show silently
        return;
      }

      // Add to notification list
      _notifications.insert(0, notification);

      // Show system notification
      await _showSystemNotification(notification);

      // Notify listeners
      for (var listener in _listeners) {
        listener(notification);
      }

      print('Notification sent: ${notification.title}');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Show system notification
  static Future<void> _showSystemNotification(
      HospitalNotification notification) async {
    try {
      // In a real app, use flutter_local_notifications
      // For now, we'll simulate with print and vibration/sound

      print('📱 NOTIFICATION: ${notification.title}');
      print('   Message: ${notification.message}');
      print('   Hospital: ${notification.hospitalName}');

      // Play sound if enabled
      if (_settings.soundEnabled) {
        await _playNotificationSound();
      }

      // Vibrate if enabled
      if (_settings.vibrationEnabled) {
        await _triggerVibration();
      }
    } catch (e) {
      print('Error showing system notification: $e');
    }
  }

  // Play notification sound
  static Future<void> _playNotificationSound() async {
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  // Trigger vibration
  static Future<void> _triggerVibration() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      print('Error triggering vibration: $e');
    }
  }

  // Check if notification type is enabled
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

  // Check if current time is in quiet hours
  static bool _isQuietHours() {
    if (!_settings.quietHoursEnabled) return false;

    try {
      final now = TimeOfDay.now();
      final start = _parseTimeOfDay(_settings.quietHoursStart);
      final end = _parseTimeOfDay(_settings.quietHoursEnd);

      // Handle overnight quiet hours (e.g., 22:00 to 07:00)
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

  // Parse time string to TimeOfDay
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Test methods
  static Future<void> sendTestNotification() async {
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

    await sendNotification(testNotification);
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

  // Send specific notification types
  static Future<void> sendQueueNotification({
    required String queueNumber,
    required String message,
    String? hospitalName,
    Map<String, dynamic>? extraData,
  }) async {
    final notification = HospitalNotification(
      id: 'QUEUE_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Update Antrean',
      message: message,
      type: NotificationType.queue,
      priority: NotificationPriority.high,
      timestamp: DateTime.now(),
      hospitalName: hospitalName ?? 'Rumah Sakit',
      relatedData: {
        'queueNumber': queueNumber,
        ...?extraData,
      },
    );

    await sendNotification(notification);
  }

  static Future<void> sendAppointmentReminder({
    required String doctorName,
    required DateTime appointmentTime,
    String? hospitalName,
    Map<String, dynamic>? extraData,
  }) async {
    final notification = HospitalNotification(
      id: 'APPOINTMENT_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Reminder Konsultasi',
      message:
          'Jangan lupa konsultasi dengan $doctorName pada ${_formatDateTime(appointmentTime)}',
      type: NotificationType.appointment,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now(),
      hospitalName: hospitalName ?? 'Rumah Sakit',
      relatedData: {
        'doctorName': doctorName,
        'appointmentTime': appointmentTime.toIso8601String(),
        ...?extraData,
      },
    );

    await sendNotification(notification);
  }

  static Future<void> sendLabResultNotification({
    required String testName,
    String? hospitalName,
    Map<String, dynamic>? extraData,
  }) async {
    final notification = HospitalNotification(
      id: 'LAB_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Hasil Lab Tersedia',
      message:
          'Hasil pemeriksaan $testName sudah dapat dilihat. Tap untuk melihat detail.',
      type: NotificationType.labResult,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now(),
      hospitalName: hospitalName ?? 'Laboratorium',
      relatedData: {
        'testName': testName,
        ...?extraData,
      },
    );

    await sendNotification(notification);
  }

  static Future<void> sendPaymentNotification({
    required String amount,
    required String status,
    String? hospitalName,
    Map<String, dynamic>? extraData,
  }) async {
    final notification = HospitalNotification(
      id: 'PAYMENT_${DateTime.now().millisecondsSinceEpoch}',
      title: status == 'success' ? 'Pembayaran Berhasil' : 'Update Pembayaran',
      message: 'Pembayaran sebesar $amount telah $status.',
      type: NotificationType.payment,
      priority: NotificationPriority.medium,
      timestamp: DateTime.now(),
      hospitalName: hospitalName ?? 'Rumah Sakit',
      relatedData: {
        'amount': amount,
        'status': status,
        ...?extraData,
      },
    );

    await sendNotification(notification);
  }

  static Future<void> sendHealthTip({
    required String tip,
    String? title,
  }) async {
    final notification = HospitalNotification(
      id: 'HEALTH_${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Tips Kesehatan Hari Ini',
      message: tip,
      type: NotificationType.healthTip,
      priority: NotificationPriority.low,
      timestamp: DateTime.now(),
      hospitalName: 'Tim Medis HospitalLink',
    );

    await sendNotification(notification);
  }

  // Utility methods
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Listener management
  static void addListener(Function(HospitalNotification) listener) {
    _listeners.add(listener);
  }

  static void removeListener(Function(HospitalNotification) listener) {
    _listeners.remove(listener);
  }

  // Get notifications
  static List<HospitalNotification> getAllNotifications() {
    return List.from(_notifications);
  }

  static List<HospitalNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  // Mark notifications as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      final notification =
          _notifications.firstWhere((n) => n.id == notificationId);
      notification.isRead = true;
      print('Notification marked as read: $notificationId');
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
      print('All notifications marked as read');
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  // Clear notifications
  static Future<void> clearAllNotifications() async {
    try {
      _notifications.clear();
      print('All notifications cleared');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Badge count
  static int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }
}
