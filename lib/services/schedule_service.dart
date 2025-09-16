import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/consultation_models.dart';
import '../models/schedule_models.dart';

class ScheduleService {
  // Get active consultations (ongoing/pending)
  static Future<List<ScheduleConsultationItem>> getActiveConsultations() async {
    try {
      // Remove userId check since backend gets it from token
      print('📅 Getting active consultations');

      final response = await HttpService.get(
        '/api/consultations/active',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Active consultations response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final consultations = responseData['data']['consultations'] as List;
          return consultations
              .map((item) => ScheduleConsultationItem.fromJson(item))
              .toList();
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get active consultations');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get active consultations');
      }
    } catch (e) {
      print('❌ Get active consultations error: $e');
      throw Exception('Failed to get active consultations: $e');
    }
  }

  // Get upcoming consultations (scheduled for future)
  static Future<List<ScheduleConsultationItem>>
      getUpcomingConsultations() async {
    try {
      // Remove userId check since backend gets it from token
      print('📅 Getting upcoming consultations');

      final response = await HttpService.get(
        '/api/consultations/upcoming',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Upcoming consultations response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final consultations = responseData['data']['consultations'] as List;
          return consultations
              .map((item) => ScheduleConsultationItem.fromJson(item))
              .toList();
        } else {
          throw Exception(responseData['message'] ??
              'Failed to get upcoming consultations');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get upcoming consultations');
      }
    } catch (e) {
      print('❌ Get upcoming consultations error: $e');
      throw Exception('Failed to get upcoming consultations: $e');
    }
  }

  // Get chat consultations (both active and scheduled)
  static Future<List<ChatConsultation>> getChatConsultations() async {
    try {
      // Remove userId check since backend gets it from token
      print('💬 Getting chat consultations');

      final response = await HttpService.get(
        '/api/consultations/chat',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Chat consultations response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final consultations = responseData['data']['consultations'] as List;
          return consultations
              .map((item) => ChatConsultation.fromJson(item))
              .toList();
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get chat consultations');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get chat consultations');
      }
    } catch (e) {
      print('❌ Get chat consultations error: $e');
      throw Exception('Failed to get chat consultations: $e');
    }
  }

  // Cancel consultation
  static Future<void> cancelConsultation(String consultationId) async {
    try {
      print('❌ Cancelling consultation: $consultationId');

      final response = await HttpService.post(
        '/api/consultations/cancel',
        {
          'consultationId': consultationId,
        },
        token: AuthService.getCurrentToken(),
      );

      print('📥 Cancel consultation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] != true) {
          throw Exception(
              responseData['message'] ?? 'Failed to cancel consultation');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to cancel consultation');
      }
    } catch (e) {
      print('❌ Cancel consultation error: $e');
      throw Exception('Failed to cancel consultation: $e');
    }
  }

  // Reschedule consultation (if supported)
  static Future<void> rescheduleConsultation({
    required String consultationId,
    required DateTime newScheduledTime,
  }) async {
    try {
      print('🔄 Rescheduling consultation: $consultationId');

      final response = await HttpService.post(
        '/api/consultations/reschedule',
        {
          'consultationId': consultationId,
          'newScheduledTime': newScheduledTime.toIso8601String(),
        },
        token: AuthService.getCurrentToken(),
      );

      print('📥 Reschedule consultation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] != true) {
          throw Exception(
              responseData['message'] ?? 'Failed to reschedule consultation');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to reschedule consultation');
      }
    } catch (e) {
      print('❌ Reschedule consultation error: $e');
      throw Exception('Failed to reschedule consultation: $e');
    }
  }

  // Mark consultation as completed (not cancelled)
  static Future<void> markConsultationCompleted(String consultationId) async {
    try {
      print('✅ Marking consultation completed: $consultationId');

      final response = await HttpService.post(
        '/api/consultations/complete',
        {
          'consultationId': consultationId,
          'reason': 'USER_COMPLETED',
        },
        token: AuthService.getCurrentToken(),
      );

      print('📥 Complete consultation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] != true) {
          throw Exception(
              responseData['message'] ?? 'Failed to complete consultation');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to complete consultation');
      }
    } catch (e) {
      print('❌ Complete consultation error: $e');
      throw Exception('Failed to complete consultation: $e');
    }
  }

  // Get consultation details
  static Future<Map<String, dynamic>> getConsultationDetails(
      String consultationId) async {
    try {
      print('📋 Getting consultation details: $consultationId');

      final response = await HttpService.get(
        '/api/consultations/details/$consultationId',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Consultation details response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return responseData['data']['consultation'];
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get consultation details');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get consultation details');
      }
    } catch (e) {
      print('❌ Get consultation details error: $e');
      throw Exception('Failed to get consultation details: $e');
    }
  }
}
