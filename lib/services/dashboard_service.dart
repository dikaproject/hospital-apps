// Update: lib/services/dashboard_service.dart
import 'dart:convert';
import 'http_service.dart';
import 'auth_service.dart';
import 'transaction_service.dart';
import '../models/transaction_models.dart';

class DashboardData {
  final UserProfile user;
  final QueueStatus? queueStatus;
  final List<UpcomingAppointment> upcomingAppointments;
  final List<RecentConsultation> recentConsultations;
  final int pendingLabResults;
  final List<RecentPrescription> recentPrescriptions;
  final NotificationData notifications;
  final DashboardStats stats;
  final FinancialSummary? financialSummary;

  DashboardData({
    required this.user,
    this.queueStatus,
    required this.upcomingAppointments,
    required this.recentConsultations,
    required this.pendingLabResults,
    required this.recentPrescriptions,
    required this.notifications,
    required this.stats,
    this.financialSummary,
  });

  // ✅ COMPLETELY REWRITTEN: Ultra-safe JSON parsing
  factory DashboardData.fromJson(Map<String, dynamic> json) {
    print('🔍 === ULTRA-SAFE DASHBOARD PARSING ===');

    try {
      // ✅ Parse User Profile (required)
      final UserProfile user;
      try {
        final userData = json['user'];
        if (userData is Map<String, dynamic>) {
          user = UserProfile.fromJson(userData);
          print('✅ User parsed successfully: ${user.fullName}');
        } else {
          throw Exception('User data is not a valid map');
        }
      } catch (e) {
        print('❌ User parsing failed: $e');
        throw Exception('Failed to parse user data: $e');
      }

      // ✅ Parse Queue Status (optional)
      QueueStatus? queueStatus;
      try {
        final queueData = json['queueStatus'];
        if (queueData != null && queueData is Map<String, dynamic>) {
          queueStatus = QueueStatus.fromJson(queueData);
          print('✅ Queue status parsed: ${queueStatus.queueNumber}');
        } else {
          print('⚠️ No queue status data');
        }
      } catch (e) {
        print('❌ Queue status parsing failed: $e');
        queueStatus = null;
      }

      // ✅ Parse Lists with ultra-safe method
      final upcomingAppointments = _ultraSafeParseList<UpcomingAppointment>(
        json['upcomingAppointments'],
        (item) => UpcomingAppointment.fromJson(item),
        'upcomingAppointments',
      );

      final recentConsultations = _ultraSafeParseList<RecentConsultation>(
        json['recentConsultations'],
        (item) => RecentConsultation.fromJson(item),
        'recentConsultations',
      );

      final recentPrescriptions = _ultraSafeParseList<RecentPrescription>(
        json['recentPrescriptions'],
        (item) => RecentPrescription.fromJson(item),
        'recentPrescriptions',
      );

      // ✅ Parse numbers with ultra-safe method
      final pendingLabResults =
          _ultraSafeParseInt(json['pendingLabResults'], 'pendingLabResults');

      // ✅ Parse Notifications (required with fallback)
      NotificationData notifications;
      try {
        final notifData = json['notifications'];
        if (notifData is Map<String, dynamic>) {
          notifications = NotificationData.fromJson(notifData);
        } else {
          notifications = NotificationData(unreadCount: 0);
        }
        print('✅ Notifications parsed: ${notifications.unreadCount}');
      } catch (e) {
        print('❌ Notifications parsing failed: $e');
        notifications = NotificationData(unreadCount: 0);
      }

      // ✅ Parse Stats (required with fallback)
      DashboardStats stats;
      try {
        final statsData = json['stats'];
        if (statsData is Map<String, dynamic>) {
          stats = DashboardStats.fromJson(statsData);
        } else {
          stats = DashboardStats(
            totalConsultations: recentConsultations.length,
            totalPrescriptions: recentPrescriptions.length,
            pendingLabResults: pendingLabResults,
            upcomingAppointments: upcomingAppointments.length,
          );
        }
        print('✅ Stats parsed successfully');
      } catch (e) {
        print('❌ Stats parsing failed: $e');
        stats = DashboardStats(
          totalConsultations: recentConsultations.length,
          totalPrescriptions: recentPrescriptions.length,
          pendingLabResults: pendingLabResults,
          upcomingAppointments: upcomingAppointments.length,
        );
      }

      // ✅ Parse Financial Summary (optional)
      FinancialSummary? financialSummary;
      try {
        final financeData = json['financialSummary'];
        if (financeData != null && financeData is Map<String, dynamic>) {
          financialSummary = FinancialSummary.fromJson(financeData);
          print('✅ Financial summary parsed');
        }
      } catch (e) {
        print('❌ Financial summary parsing failed: $e');
        financialSummary = null;
      }

      final result = DashboardData(
        user: user,
        queueStatus: queueStatus,
        upcomingAppointments: upcomingAppointments,
        recentConsultations: recentConsultations,
        pendingLabResults: pendingLabResults,
        recentPrescriptions: recentPrescriptions,
        notifications: notifications,
        stats: stats,
        financialSummary: financialSummary,
      );

      print('✅ Dashboard data parsing completed successfully');
      return result;
    } catch (e, stackTrace) {
      print('❌ CRITICAL DASHBOARD PARSING ERROR: $e');
      print('📥 Stack trace: $stackTrace');
      print('📥 JSON keys: ${json.keys.toList()}');
      rethrow;
    }
  }

  // ✅ ULTRA-SAFE LIST PARSING: Never fails, always returns a list
  static List<T> _ultraSafeParseList<T>(
    dynamic data,
    T Function(Map<String, dynamic>) parser,
    String fieldName,
  ) {
    print('\n🔍 === ULTRA-SAFE LIST PARSING: $fieldName ===');

    try {
      // Handle null
      if (data == null) {
        print('⚠️ $fieldName is null → returning empty list');
        return <T>[];
      }

      // Handle non-list types
      if (data is! List) {
        print(
            '⚠️ $fieldName is ${data.runtimeType}, not List → returning empty list');
        return <T>[];
      }

      final List rawList = data;
      print('✅ $fieldName is a List with ${rawList.length} items');

      if (rawList.isEmpty) {
        print('✅ $fieldName is empty list');
        return <T>[];
      }

      // Parse each item safely
      final List<T> results = [];
      for (int i = 0; i < rawList.length; i++) {
        try {
          final item = rawList[i];

          if (item == null) {
            print('⚠️ $fieldName[$i] is null → skipping');
            continue;
          }

          if (item is! Map) {
            print(
                '⚠️ $fieldName[$i] is ${item.runtimeType}, not Map → skipping');
            continue;
          }

          // Convert to Map<String, dynamic> safely
          Map<String, dynamic> itemMap;
          if (item is Map<String, dynamic>) {
            itemMap = item;
          } else {
            itemMap = Map<String, dynamic>.from(item);
          }

          final parsed = parser(itemMap);
          results.add(parsed);
          print('✅ $fieldName[$i] parsed successfully');
        } catch (e) {
          print('❌ $fieldName[$i] parsing failed: $e → skipping');
          continue;
        }
      }

      print('✅ $fieldName: parsed ${results.length}/${rawList.length} items');
      return results;
    } catch (e) {
      print('❌ CRITICAL ERROR parsing $fieldName: $e → returning empty list');
      return <T>[];
    }
  }

  // ✅ ULTRA-SAFE INT PARSING: Never fails, always returns an int
  static int _ultraSafeParseInt(dynamic data, String fieldName) {
    print('\n🔍 === ULTRA-SAFE INT PARSING: $fieldName ===');

    try {
      if (data == null) {
        print('⚠️ $fieldName is null → returning 0');
        return 0;
      }

      if (data is int) {
        print('✅ $fieldName is already int: $data');
        return data;
      }

      if (data is double) {
        final result = data.round();
        print('✅ $fieldName converted from double: $data → $result');
        return result;
      }

      if (data is String) {
        final parsed = int.tryParse(data);
        if (parsed != null) {
          print('✅ $fieldName parsed from string: "$data" → $parsed');
          return parsed;
        } else {
          print('⚠️ $fieldName string cannot be parsed: "$data" → returning 0');
          return 0;
        }
      }

      print('⚠️ $fieldName is ${data.runtimeType}: $data → returning 0');
      return 0;
    } catch (e) {
      print('❌ ERROR parsing $fieldName: $e → returning 0');
      return 0;
    }
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
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      profileImage: json['profileImage']?.toString() ??
          json['profilePicture']?.toString(),
      age: DashboardData._ultraSafeParseInt(json['age'], 'user.age'),
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
      id: json['id']?.toString() ?? '',
      queueNumber: json['queueNumber']?.toString() ?? '',
      status: json['status']?.toString() ?? 'WAITING',
      estimatedWaitTime: DashboardData._ultraSafeParseInt(
          json['estimatedWaitTime'], 'queue.estimatedWaitTime'),
      position:
          DashboardData._ultraSafeParseInt(json['position'], 'queue.position'),
      doctor: DoctorInfo.fromJson(json['doctor'] ?? {}),
    );
  }

  String get statusText {
    switch (status.toUpperCase()) {
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
      name: json['name']?.toString() ?? 'Unknown Doctor',
      specialty: json['specialty']?.toString() ?? 'General',
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
      id: json['id']?.toString() ?? '',
      scheduledDate:
          DateTime.tryParse(json['scheduledDate']?.toString() ?? '') ??
              DateTime.now(),
      status: json['status']?.toString() ?? 'SCHEDULED',
      notes: json['notes']?.toString(),
      doctor: DoctorInfo.fromJson(json['doctor'] ?? {}),
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
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'CONSULTATION',
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      doctorNotes: json['doctorNotes']?.toString(),
      doctor: DoctorInfo.fromJson(json['doctor'] ?? {}),
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

  static double? _ultraSafeParseAmount(dynamic amount) {
    if (amount == null) return null;

    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();

    if (amount is String) {
      try {
        return double.parse(amount);
      } catch (e) {
        print('❌ Failed to parse amount from string: "$amount"');
        return null;
      }
    }

    print('⚠️ Unexpected amount type: ${amount.runtimeType} = $amount');
    return null;
  }

  factory RecentPrescription.fromJson(Map<String, dynamic> json) {
    return RecentPrescription(
      id: json['id']?.toString() ?? '',
      prescriptionCode: json['prescriptionCode']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      totalAmount: _ultraSafeParseAmount(json['totalAmount']),
      status: json['status']?.toString() ?? 'PENDING',
      medicationCount: DashboardData._ultraSafeParseInt(
          json['medicationCount'], 'prescription.medicationCount'),
      doctor: DoctorInfo.fromJson(json['doctor'] ?? {}),
    );
  }

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
      unreadCount: DashboardData._ultraSafeParseInt(
          json['unreadCount'], 'notifications.unreadCount'),
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
      totalConsultations: DashboardData._ultraSafeParseInt(
          json['totalConsultations'], 'stats.totalConsultations'),
      totalPrescriptions: DashboardData._ultraSafeParseInt(
          json['totalPrescriptions'], 'stats.totalPrescriptions'),
      pendingLabResults: DashboardData._ultraSafeParseInt(
          json['pendingLabResults'], 'stats.pendingLabResults'),
      upcomingAppointments: DashboardData._ultraSafeParseInt(
          json['upcomingAppointments'], 'stats.upcomingAppointments'),
    );
  }
}

class DashboardService {
  // ✅ ENHANCED: Fallback dashboard creator
  static DashboardData createMinimalDashboard(UserProfile user) {
    print('🔧 Creating minimal fallback dashboard');
    return DashboardData(
      user: user,
      queueStatus: null,
      upcomingAppointments: [],
      recentConsultations: [],
      pendingLabResults: 0,
      recentPrescriptions: [],
      notifications: NotificationData(unreadCount: 0),
      stats: DashboardStats(
        totalConsultations: 0,
        totalPrescriptions: 0,
        pendingLabResults: 0,
        upcomingAppointments: 0,
      ),
      financialSummary: null,
    );
  }

  static Future<DashboardData> getDashboardData() async {
    try {
      final token = AuthService.getCurrentToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      print('🏠 Fetching dashboard data...');

      final dashboardResponse =
          await HttpService.get('/api/dashboard', token: token);
      print('📥 Dashboard response status: ${dashboardResponse.statusCode}');

      if (dashboardResponse.statusCode == 200) {
        final responseBody = dashboardResponse.body;
        print('📥 Response length: ${responseBody.length}');

        try {
          final Map<String, dynamic> data = json.decode(responseBody);
          print('✅ JSON decoded successfully');
          print('🔍 Response structure: ${data.keys.toList()}');

          if (data['success'] == true) {
            print('✅ API success = true');
            final dashboardDataJson =
                data['data'] as Map<String, dynamic>? ?? {};
            print('🔍 Dashboard data keys: ${dashboardDataJson.keys.toList()}');

            try {
              // ✅ Try to parse dashboard data
              final dashboardData = DashboardData.fromJson(dashboardDataJson);
              print('✅ Dashboard data parsed successfully');

              // ✅ Get financial summary separately with fallback
              FinancialSummary? financialSummary;
              try {
                print('💰 Fetching financial summary...');
                financialSummary =
                    await TransactionService.getFinancialSummary();
                print('✅ Financial summary fetched');
              } catch (e) {
                print('⚠️ Failed to get financial summary: $e');
                financialSummary = FinancialSummary.empty();
              }

              // ✅ Combine data
              final combinedData = DashboardData(
                user: dashboardData.user,
                queueStatus: dashboardData.queueStatus,
                upcomingAppointments: dashboardData.upcomingAppointments,
                recentConsultations: dashboardData.recentConsultations,
                pendingLabResults: dashboardData.pendingLabResults,
                recentPrescriptions: dashboardData.recentPrescriptions,
                notifications: dashboardData.notifications,
                stats: dashboardData.stats,
                financialSummary: financialSummary,
              );

              print('✅ Dashboard data combined successfully');
              return combinedData;
            } catch (parseError) {
              print('❌ Dashboard parsing failed, creating fallback');
              print('❌ Parse error: $parseError');

              // ✅ FALLBACK: Try to at least get user data
              try {
                final userData =
                    dashboardDataJson['user'] as Map<String, dynamic>? ?? {};
                final user = UserProfile.fromJson(userData);
                print('✅ Fallback: User data extracted');

                return createMinimalDashboard(user);
              } catch (userError) {
                print('❌ Even user parsing failed: $userError');

                // ✅ ULTIMATE FALLBACK: Create anonymous user
                final fallbackUser = UserProfile(
                  id: 'fallback-${DateTime.now().millisecondsSinceEpoch}',
                  fullName: 'Pasien HospitalLink',
                  email: 'unknown@hospitalink.com',
                );

                return createMinimalDashboard(fallbackUser);
              }
            }
          } else {
            throw Exception(data['message'] ?? 'API returned success: false');
          }
        } catch (jsonError) {
          print('❌ JSON parsing error: $jsonError');
          print(
              '📥 Raw response preview: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
          throw Exception('Invalid JSON response from server');
        }
      } else {
        throw Exception('HTTP ${dashboardResponse.statusCode}: Server error');
      }
    } catch (e) {
      print('❌ Dashboard service error: $e');
      rethrow;
    }
  }

  static Future<DashboardStats> getQuickStats() async {
    try {
      final token = AuthService.getCurrentToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response =
          await HttpService.get('/api/dashboard/stats', token: token);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          return DashboardStats.fromJson(data['data'] ?? {});
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
