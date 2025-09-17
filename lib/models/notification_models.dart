import 'dart:convert';

enum NotificationType {
  queue,
  appointment,
  labResult,
  payment,
  system,
  healthTip,
}

enum NotificationPriority {
  high,
  medium,
  low,
}

class HospitalNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final String? hospitalName;
  final String? actionUrl;
  final Map<String, dynamic>? relatedData;
  bool isRead;

  HospitalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.hospitalName,
    this.actionUrl,
    this.relatedData,
    this.isRead = false,
  });

  // ✅ ENHANCED: Ultra-safe JSON parsing
  factory HospitalNotification.fromJson(Map<String, dynamic> json) {
    print('🔍 === PARSING NOTIFICATION ===');
    print('📊 JSON keys: ${json.keys.toList()}');
    print('📊 JSON data: ${json.toString()}');

    try {
      // ✅ SAFE: Parse type
      NotificationType type;
      try {
        final typeString = json['type']?.toString().toLowerCase() ?? 'system';
        switch (typeString) {
          case 'queue':
          case 'antrean':
            type = NotificationType.queue;
            break;
          case 'appointment':
          case 'jadwal':
            type = NotificationType.appointment;
            break;
          case 'lab_result':
          case 'labresult':
          case 'lab':
            type = NotificationType.labResult;
            break;
          case 'payment':
          case 'pembayaran':
            type = NotificationType.payment;
            break;
          case 'health_tip':
          case 'healthtip':
          case 'tips':
            type = NotificationType.healthTip;
            break;
          default:
            type = NotificationType.system;
        }
      } catch (e) {
        print('❌ Error parsing type: $e');
        type = NotificationType.system;
      }

      // ✅ SAFE: Parse priority
      NotificationPriority priority;
      try {
        final priorityString =
            json['priority']?.toString().toLowerCase() ?? 'medium';
        switch (priorityString) {
          case 'high':
          case 'tinggi':
          case 'penting':
            priority = NotificationPriority.high;
            break;
          case 'low':
          case 'rendah':
          case 'info':
            priority = NotificationPriority.low;
            break;
          default:
            priority = NotificationPriority.medium;
        }
      } catch (e) {
        print('❌ Error parsing priority: $e');
        priority = NotificationPriority.medium;
      }

      // ✅ SAFE: Parse timestamp
      DateTime timestamp;
      try {
        if (json['timestamp'] != null) {
          timestamp = DateTime.parse(json['timestamp'].toString());
        } else if (json['createdAt'] != null) {
          timestamp = DateTime.parse(json['createdAt'].toString());
        } else {
          timestamp = DateTime.now();
        }
      } catch (e) {
        print('❌ Error parsing timestamp: $e');
        timestamp = DateTime.now();
      }

      // ✅ SAFE: Parse related data
      Map<String, dynamic>? relatedData;
      try {
        final relatedDataRaw =
            json['relatedData'] ?? json['data'] ?? json['metadata'];
        if (relatedDataRaw != null) {
          if (relatedDataRaw is String) {
            // Try to parse JSON string
            relatedData = jsonDecode(relatedDataRaw);
          } else if (relatedDataRaw is Map) {
            relatedData = Map<String, dynamic>.from(relatedDataRaw);
          }
        }
      } catch (e) {
        print('❌ Error parsing relatedData: $e');
        relatedData = null;
      }

      final notification = HospitalNotification(
        id: json['id']?.toString() ??
            'unknown_${DateTime.now().millisecondsSinceEpoch}',
        title: json['title']?.toString() ?? 'Notifikasi',
        message: json['message']?.toString() ??
            json['body']?.toString() ??
            'Tidak ada pesan',
        type: type,
        priority: priority,
        timestamp: timestamp,
        hospitalName:
            json['hospitalName']?.toString() ?? json['hospital']?.toString(),
        actionUrl: json['actionUrl']?.toString() ?? json['action']?.toString(),
        relatedData: relatedData,
        isRead: json['isRead'] == true || json['read'] == true,
      );

      print('✅ Notification parsed successfully: ${notification.title}');
      return notification;
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR parsing notification: $e');
      print('📥 Stack trace: $stackTrace');
      print('📥 JSON data: ${json.toString()}');

      // ✅ FALLBACK: Return minimal valid notification
      return HospitalNotification(
        id: json['id']?.toString() ??
            'error_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Error parsing notification',
        message: 'Terjadi kesalahan saat memproses notifikasi',
        type: NotificationType.system,
        priority: NotificationPriority.low,
        timestamp: DateTime.now(),
        isRead: false,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'hospitalName': hospitalName,
      'actionUrl': actionUrl,
      'relatedData': relatedData,
      'isRead': isRead,
    };
  }
}

class NotificationSettings {
  final bool pushNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool queueNotifications;
  final bool appointmentNotifications;
  final bool labResultNotifications;
  final bool paymentNotifications;
  final bool systemNotifications;
  final bool healthTipsNotifications;
  final bool quietHoursEnabled;
  final String quietHoursStart;
  final String quietHoursEnd;

  NotificationSettings({
    this.pushNotifications = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.queueNotifications = true,
    this.appointmentNotifications = true,
    this.labResultNotifications = true,
    this.paymentNotifications = true,
    this.systemNotifications = false,
    this.healthTipsNotifications = true,
    this.quietHoursEnabled = true,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '07:00',
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotifications: json['pushNotifications'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      queueNotifications: json['queueNotifications'] ?? true,
      appointmentNotifications: json['appointmentNotifications'] ?? true,
      labResultNotifications: json['labResultNotifications'] ?? true,
      paymentNotifications: json['paymentNotifications'] ?? true,
      systemNotifications: json['systemNotifications'] ?? false,
      healthTipsNotifications: json['healthTipsNotifications'] ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] ?? true,
      quietHoursStart: json['quietHoursStart'] ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushNotifications': pushNotifications,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'queueNotifications': queueNotifications,
      'appointmentNotifications': appointmentNotifications,
      'labResultNotifications': labResultNotifications,
      'paymentNotifications': paymentNotifications,
      'systemNotifications': systemNotifications,
      'healthTipsNotifications': healthTipsNotifications,
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
    };
  }
}
