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
  bool isRead;
  final String? actionUrl;
  final String hospitalName;
  final Map<String, dynamic>? relatedData;

  HospitalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    required this.hospitalName,
    this.relatedData,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'actionUrl': actionUrl,
      'hospitalName': hospitalName,
      'relatedData': relatedData,
    };
  }

  // Create from JSON
  factory HospitalNotification.fromJson(Map<String, dynamic> json) {
    return HospitalNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => NotificationPriority.medium,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      actionUrl: json['actionUrl'],
      hospitalName: json['hospitalName'],
      relatedData: json['relatedData'],
    );
  }

  // Copy with method
  HospitalNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
    String? hospitalName,
    Map<String, dynamic>? relatedData,
  }) {
    return HospitalNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      hospitalName: hospitalName ?? this.hospitalName,
      relatedData: relatedData ?? this.relatedData,
    );
  }
}

// Notification Settings Model
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

  NotificationSettings copyWith({
    bool? pushNotifications,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? queueNotifications,
    bool? appointmentNotifications,
    bool? labResultNotifications,
    bool? paymentNotifications,
    bool? systemNotifications,
    bool? healthTipsNotifications,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) {
    return NotificationSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      queueNotifications: queueNotifications ?? this.queueNotifications,
      appointmentNotifications:
          appointmentNotifications ?? this.appointmentNotifications,
      labResultNotifications:
          labResultNotifications ?? this.labResultNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      healthTipsNotifications:
          healthTipsNotifications ?? this.healthTipsNotifications,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}
