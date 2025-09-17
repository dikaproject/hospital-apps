import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/consultation_models.dart';

class ConsultationService {
  // Get Available Doctors (General Practitioners)
  static Future<List<DoctorInfo>> getAvailableDoctors() async {
    try {
      print('🩺 Getting available doctors...');

      final response = await HttpService.get(
        '/api/consultations/available-doctors',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Available doctors response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final doctors = responseData['data']['doctors'] as List;
          return doctors.map((doctor) => DoctorInfo.fromJson(doctor)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get doctors');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get doctors');
      }
    } catch (e) {
      print('❌ Get available doctors error: ${e.toString()}');
      throw Exception('Failed to get available doctors: ${e.toString()}');
    }
  }

  // Direct Consultation without AI (NEW)
  static Future<DirectConsultationResult> startDirectConsultation({
    required String doctorId,
    required List<String> symptoms,
    String? notes,
  }) async {
    try {
      final userId = AuthService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final requestBody = {
        'userId': userId,
        'doctorId': doctorId,
        'symptoms': symptoms,
      };

      // Only add notes if not null or empty
      if (notes != null && notes.trim().isNotEmpty) {
        requestBody['notes'] = notes.trim();
      }

      final response = await HttpService.post(
        '/api/consultations/start-direct',
        requestBody,
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return DirectConsultationResult.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Direct consultation failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Direct consultation failed');
      }
    } catch (e) {
      throw Exception('Direct consultation failed: ${e.toString()}');
    }
  }

  // AI Screening - Step 1 (EXISTING)
  static Future<AIScreeningResult> performAIScreening({
    required List<String> symptoms,
    List<Map<String, dynamic>>? chatHistory,
    int questionCount = 0,
    String? consultationId,
  }) async {
    try {
      final userId = AuthService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('🤖 Performing AI screening - Question $questionCount');

      final response = await HttpService.post(
        '/api/consultations/ai-screening',
        {
          'userId': userId,
          'symptoms': symptoms,
          'chatHistory': chatHistory ?? [],
          'questionCount': questionCount,
          if (consultationId != null) 'consultationId': consultationId,
        },
        token: AuthService.getCurrentToken(),
      );

      print('📥 AI Screening response: ${response.statusCode}');

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

  // Continue AI consultation with user response (EXISTING)
  static Future<AIScreeningResult> continueAIConsultation({
    required String consultationId,
    required String userResponse,
    required List<Map<String, dynamic>> chatHistory,
  }) async {
    try {
      print('🔄 Continuing AI consultation: $consultationId');

      final response = await HttpService.post(
        '/api/consultations/continue-ai',
        {
          'consultationId': consultationId,
          'userResponse': userResponse,
          'chatHistory': chatHistory,
        },
        token: AuthService.getCurrentToken(),
      );

      print('📥 Continue consultation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          return AIScreeningResult.fromJson(responseData['data']);
        } else {
          throw Exception(
              responseData['message'] ?? 'Continue consultation failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Continue consultation failed');
      }
    } catch (e) {
      print('❌ Continue consultation error: ${e.toString()}');
      throw Exception('Continue consultation failed: ${e.toString()}');
    }
  }

  // Get Consultation History (EXISTING)
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

      print('📥 Consultation history response: ${response.statusCode}');

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

  // Test AI Connection (EXISTING)
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
}
