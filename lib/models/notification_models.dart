import 'package:flutter/material.dart';

enum NotificationType {
  queue,
  appointment,
  labResult,
  payment,
  system,
  healthTip
}

enum NotificationPriority {
  high,
  medium,
  low
}

class HospitalNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  bool isRead; // Changed to mutable for state updates
  final String? hospitalName;
  final String? actionUrl;
  final Map<String, dynamic>? relatedData;

  HospitalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.timestamp,
    this.isRead = false,
    this.hospitalName,
    this.actionUrl,
    this.relatedData,
  });

  // FIXED: Better null handling in fromJson
  factory HospitalNotification.fromJson(Map<String, dynamic> json) {
    return HospitalNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notifikasi',
      message: json['message']?.toString() ?? 'Pesan kosong',
      type: _parseNotificationType(json['type']),
      priority: _parseNotificationPriority(json['priority']),
      timestamp: _parseDateTime(json['createdAt'] ?? json['timestamp']),
      isRead: json['isRead'] == true,
      hospitalName: json['hospitalName']?.toString(),
      actionUrl: json['actionUrl']?.toString(),
      relatedData: json['relatedData'] != null 
          ? Map<String, dynamic>.from(json['relatedData']) 
          : null,
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        return DateTime.now();
      }
    } catch (e) {
      print('Error parsing date: $dateValue - $e');
      return DateTime.now();
    }
  }

  // Helper method to parse notification type from string
  static NotificationType _parseNotificationType(dynamic typeValue) {
    if (typeValue == null) return NotificationType.system;
    
    final typeString = typeValue.toString().toUpperCase();
    switch (typeString) {
      case 'QUEUE':
        return NotificationType.queue;
      case 'APPOINTMENT':
        return NotificationType.appointment;
      case 'LAB_RESULT':
        return NotificationType.labResult;
      case 'PAYMENT':
        return NotificationType.payment;
      case 'SYSTEM':
        return NotificationType.system;
      case 'HEALTH_TIP':
        return NotificationType.healthTip;
      default:
        return NotificationType.system;
    }
  }

  // Helper method to parse notification priority from string
  static NotificationPriority _parseNotificationPriority(dynamic priorityValue) {
    if (priorityValue == null) return NotificationPriority.medium;
    
    final priorityString = priorityValue.toString().toUpperCase();
    switch (priorityString) {
      case 'HIGH':
        return NotificationPriority.high;
      case 'MEDIUM':
        return NotificationPriority.medium;
      case 'LOW':
        return NotificationPriority.low;
      default:
        return NotificationPriority.medium;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.toString().split('.').last.toUpperCase(),
      'priority': priority.toString().split('.').last.toUpperCase(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'hospitalName': hospitalName,
      'actionUrl': actionUrl,
      'relatedData': relatedData,
    };
  }

  // Create a copy with updated fields
  HospitalNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? hospitalName,
    String? actionUrl,
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
      hospitalName: hospitalName ?? this.hospitalName,
      actionUrl: actionUrl ?? this.actionUrl,
      relatedData: relatedData ?? this.relatedData,
    );
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