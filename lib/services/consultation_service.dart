import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/consultation_models.dart';

class ConsultationService {
  // AI Screening - Step 1
  static Future<AIScreeningResult> performAIScreening({
    required List<String> symptoms,
    List<Map<String, dynamic>>? chatHistory,
  }) async {
    try {
      final userId = AuthService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('🤖 Performing AI screening with symptoms: $symptoms');

      final response = await HttpService.post(
        '/api/consultations/ai-screening',
        {
          'userId': userId,
          'symptoms': symptoms,
          'chatHistory': chatHistory ?? [],
        },
        token: AuthService.getCurrentToken(),
      );

      print(
          '📥 AI Screening response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return AIScreeningResult.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'AI screening failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'AI screening request failed');
      }
    } catch (e) {
      print('❌ AI Screening error: ${e.toString()}');
      throw Exception('AI screening failed: ${e.toString()}');
    }
  }

  // Generate Follow-up Question
  static Future<String> generateFollowUpQuestion({
    required List<String> symptoms,
    List<Map<String, dynamic>>? chatHistory,
  }) async {
    try {
      print('🔄 Generating follow-up question...');

      final response = await HttpService.post(
        '/api/consultations/generate-question',
        {
          'symptoms': symptoms,
          'chatHistory': chatHistory ?? [],
        },
        token: AuthService.getCurrentToken(),
      );

      print(
          '📥 Follow-up question response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return responseData['data']['question'] as String;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to generate question');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Question generation failed');
      }
    } catch (e) {
      print('❌ Generate question error: ${e.toString()}');
      throw Exception('Failed to generate question: ${e.toString()}');
    }
  }

  // Test AI Connection
  static Future<bool> testAIConnection() async {
    try {
      print('🔄 Testing AI connection...');

      final response = await HttpService.get('/api/consultations/test-ai');

      print('📥 AI test response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }

      return false;
    } catch (e) {
      print('❌ AI connection test failed: ${e.toString()}');
      return false;
    }
  }

  // Request Doctor Consultation - Step 2
  static Future<DoctorConsultationResult> requestDoctorConsultation({
    required String consultationId,
    String paymentMethod = 'CASH',
  }) async {
    try {
      print('🩺 Requesting doctor consultation for: $consultationId');

      final response = await HttpService.post(
        '/api/consultations/request-doctor',
        {
          'consultationId': consultationId,
          'paymentMethod': paymentMethod,
        },
        token: AuthService.getCurrentToken(),
      );

      print(
          '📥 Doctor consultation response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return DoctorConsultationResult.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Doctor consultation request failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Doctor consultation request failed');
      }
    } catch (e) {
      print('❌ Doctor consultation request error: ${e.toString()}');
      throw Exception('Doctor consultation request failed: ${e.toString()}');
    }
  }

  // Book Appointment - Step 3
  static Future<AppointmentBookingResult> bookAppointment({
    required String consultationId,
    required String doctorId,
    required DateTime appointmentDate,
    required DateTime startTime,
    String? reason,
  }) async {
    try {
      print('📅 Booking appointment for consultation: $consultationId');

      final response = await HttpService.post(
        '/api/consultations/book-appointment',
        {
          'consultationId': consultationId,
          'doctorId': doctorId,
          'appointmentDate': appointmentDate.toIso8601String(),
          'startTime': startTime.toIso8601String(),
          'reason': reason,
        },
        token: AuthService.getCurrentToken(),
      );

      print(
          '📥 Appointment booking response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return AppointmentBookingResult.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Appointment booking failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Appointment booking failed');
      }
    } catch (e) {
      print('❌ Appointment booking error: ${e.toString()}');
      throw Exception('Appointment booking failed: ${e.toString()}');
    }
  }

  // Get Consultation History
  static Future<List<ConsultationHistoryItem>> getConsultationHistory() async {
    try {
      final userId = AuthService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('📋 Getting consultation history for user: $userId');

      final response = await HttpService.get(
        '/api/consultations/history/$userId',
        token: AuthService.getCurrentToken(),
      );

      print(
          '📥 Consultation history response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final consultations = responseData['data']['consultations'] as List;
          return consultations
              .map((item) => ConsultationHistoryItem.fromJson(item))
              .toList();
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get consultation history');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get consultation history');
      }
    } catch (e) {
      print('❌ Get consultation history error: ${e.toString()}');
      throw Exception('Failed to get consultation history: ${e.toString()}');
    }
  }
}
