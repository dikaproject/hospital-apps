// Update: lib/services/dashboard_service.dart
import 'dart:convert';
import 'http_service.dart';
import 'auth_service.dart'; 

class DashboardData {
  final UserProfile user;
  final QueueStatus? queueStatus;
  final List<UpcomingAppointment> upcomingAppointments;
  final List<RecentConsultation> recentConsultations;
  final int pendingLabResults;
  final List<RecentPrescription> recentPrescriptions;
  final NotificationData notifications;
  final DashboardStats stats;

  DashboardData({
    required this.user,
    this.queueStatus,
    required this.upcomingAppointments,
    required this.recentConsultations,
    required this.pendingLabResults,
    required this.recentPrescriptions,
    required this.notifications,
    required this.stats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      user: UserProfile.fromJson(json['user']),
      queueStatus: json['queueStatus'] != null 
          ? QueueStatus.fromJson(json['queueStatus']) 
          : null,
      upcomingAppointments: (json['upcomingAppointments'] as List)
          .map((item) => UpcomingAppointment.fromJson(item))
          .toList(),
      recentConsultations: (json['recentConsultations'] as List)
          .map((item) => RecentConsultation.fromJson(item))
          .toList(),
      pendingLabResults: json['pendingLabResults'] ?? 0,
      recentPrescriptions: (json['recentPrescriptions'] as List)
          .map((item) => RecentPrescription.fromJson(item))
          .toList(),
      notifications: NotificationData.fromJson(json['notifications']),
      stats: DashboardStats.fromJson(json['stats']),
    );
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? profileImage;
  final int? age;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.profileImage,
    this.age,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      profileImage: json['profileImage'],
      age: json['age'],
    );
  }
}

class QueueStatus {
  final String id;
  final String queueNumber;
  final String status;
  final int estimatedWaitTime;
  final int position;
  final DoctorInfo doctor;

  QueueStatus({
    required this.id,
    required this.queueNumber,
    required this.status,
    required this.estimatedWaitTime,
    required this.position,
    required this.doctor,
  });

  factory QueueStatus.fromJson(Map<String, dynamic> json) {
    return QueueStatus(
      id: json['id'],
      queueNumber: json['queueNumber'],
      status: json['status'],
      estimatedWaitTime: json['estimatedWaitTime'] ?? 0,
      position: json['position'] ?? 0,
      doctor: DoctorInfo.fromJson(json['doctor']),
    );
  }

  String get statusText {
    switch (status) {
      case 'WAITING':
        return 'MENUNGGU';
      case 'CALLED':
        return 'DIPANGGIL';
      case 'IN_PROGRESS':
        return 'SEDANG BERLANGSUNG';
      default:
        return status;
    }
  }

  String get estimatedTimeText {
    if (estimatedWaitTime <= 0) return 'Segera';
    if (estimatedWaitTime < 60) return '~$estimatedWaitTime menit';
    final hours = estimatedWaitTime ~/ 60;
    final minutes = estimatedWaitTime % 60;
    return '~${hours}j ${minutes}m';
  }
}

class DoctorInfo {
  final String name;
  final String specialty;

  DoctorInfo({required this.name, required this.specialty});

  factory DoctorInfo.fromJson(Map<String, dynamic> json) {
    return DoctorInfo(
      name: json['name'] ?? 'Unknown Doctor',
      specialty: json['specialty'] ?? 'General',
    );
  }
}

class UpcomingAppointment {
  final String id;
  final DateTime scheduledDate;
  final String status;
  final String? notes;
  final DoctorInfo doctor;

  UpcomingAppointment({
    required this.id,
    required this.scheduledDate,
    required this.status,
    this.notes,
    required this.doctor,
  });

  factory UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    return UpcomingAppointment(
      id: json['id'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      status: json['status'],
      notes: json['notes'],
      doctor: DoctorInfo.fromJson(json['doctor']),
    );
  }
}

class RecentConsultation {
  final String id;
  final String type;
  final String status;
  final DateTime createdAt;
  final String? doctorNotes;
  final DoctorInfo doctor;

  RecentConsultation({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    this.doctorNotes,
    required this.doctor,
  });

  factory RecentConsultation.fromJson(Map<String, dynamic> json) {
    return RecentConsultation(
      id: json['id'],
      type: json['type'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      doctorNotes: json['doctorNotes'],
      doctor: DoctorInfo.fromJson(json['doctor']),
    );
  }
}

class RecentPrescription {
  final String id;
  final String prescriptionCode;
  final DateTime createdAt;
  final double? totalAmount;
  final String status;
  final int medicationCount;
  final DoctorInfo doctor;

  RecentPrescription({
    required this.id,
    required this.prescriptionCode,
    required this.createdAt,
    this.totalAmount,
    required this.status,
    required this.medicationCount,
    required this.doctor,
  });

  // Helper method to safely parse totalAmount
  static double? _parseAmount(dynamic amount) {
    if (amount == null) return null;
    
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) {
      try {
        return double.parse(amount);
      } catch (e) {
        print('❌ Failed to parse amount: $amount');
        return null;
      }
    }
    
    return null;
  }

  factory RecentPrescription.fromJson(Map<String, dynamic> json) {
    return RecentPrescription(
      id: json['id'],
      prescriptionCode: json['prescriptionCode'],
      createdAt: DateTime.parse(json['createdAt']),
      totalAmount: _parseAmount(json['totalAmount']), // FIXED: Safe parsing
      status: json['status'],
      medicationCount: json['medicationCount'] ?? 0,
      doctor: DoctorInfo.fromJson(json['doctor']),
    );
  }

  // Helper method to format currency
  String get formattedAmount {
    if (totalAmount == null) return 'Gratis';
    return 'Rp ${totalAmount!.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}

class NotificationData {
  final int unreadCount;

  NotificationData({required this.unreadCount});

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class DashboardStats {
  final int totalConsultations;
  final int totalPrescriptions;
  final int pendingLabResults;
  final int upcomingAppointments;

  DashboardStats({
    required this.totalConsultations,
    required this.totalPrescriptions,
    required this.pendingLabResults,
    required this.upcomingAppointments,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalConsultations: json['totalConsultations'] ?? 0,
      totalPrescriptions: json['totalPrescriptions'] ?? 0,
      pendingLabResults: json['pendingLabResults'] ?? 0,
      upcomingAppointments: json['upcomingAppointments'] ?? 0,
    );
  }
}

class DashboardService {
  static Future<DashboardData> getDashboardData() async {
    try {
      // Use AuthService.getCurrentToken() instead of getToken()
      final token = AuthService.getCurrentToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await HttpService.get(
        '/api/dashboard',
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success']) {
          return DashboardData.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get dashboard data');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to get dashboard data');
      }
    } catch (e) {
      print('❌ Dashboard service error: $e');
      throw Exception('Failed to get dashboard data: $e');
    }
  }

  static Future<DashboardStats> getQuickStats() async {
    try {
      // Use AuthService.getCurrentToken() instead of getToken()
      final token = AuthService.getCurrentToken();
      
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await HttpService.get(
        '/api/dashboard/stats',
        token: token,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success']) {
          return DashboardStats.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get stats');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to get stats');
      }
    } catch (e) {
      print('❌ Quick stats error: $e');
      throw Exception('Failed to get quick stats: $e');
    }
  }
}