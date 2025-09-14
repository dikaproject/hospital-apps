import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/consultation_models.dart';
import 'http_service.dart';
import 'auth_service.dart';

class ChatConsultationService {
  // Get available time slots
  static Future<List<TimeSlot>> getAvailableTimeSlots({
    String? doctorId,
    DateTime? preferredDate,
  }) async {
    try {
      final userId = AuthService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final queryParams = <String, String>{};
      if (doctorId != null) queryParams['doctorId'] = doctorId;
      if (preferredDate != null) {
        queryParams['date'] = preferredDate.toIso8601String().split('T')[0];
      }

      final uri = Uri.parse('${HttpService.getCurrentBaseUrl()}/api/consultations/available-slots')
          .replace(queryParameters: queryParams);

      final response = await HttpService.get(
        uri.toString().replaceFirst(HttpService.getCurrentBaseUrl(), ''),
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final slots = (data['data']['slots'] as List? ?? [])
              .map((slot) => TimeSlot.fromJson(slot))
              .toList();
          return slots;
        } else {
          throw Exception(data['message'] ?? 'Failed to get available slots');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to get available slots');
      }
    } catch (e) {
      print('❌ Get available slots error: $e');
      throw Exception('Failed to get available slots: $e');
    }
  }

  // Book consultation chat
  static Future<ChatConsultation> bookChatConsultation({
    required String slotId,
    required DateTime scheduledTime,
    String? notes,
  }) async {
    try {
      final userId = AuthService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await HttpService.post(
        '/api/consultations/book-chat',
        {
          'userId': userId,
          'slotId': slotId,
          'scheduledTime': scheduledTime.toIso8601String(),
          'notes': notes,
        },
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return ChatConsultation.fromJson(data['data']['consultation']);
        } else {
          throw Exception(data['message'] ?? 'Failed to book consultation');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to book consultation');
      }
    } catch (e) {
      print('❌ Book chat consultation error: $e');
      throw Exception('Failed to book consultation: $e');
    }
  }

  // Get user's chat consultations
  static Future<List<ChatConsultation>> getChatConsultations() async {
    try {
      final userId = AuthService.getCurrentUser()?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await HttpService.get(
        '/api/consultations/chat-consultations/$userId',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final consultations = (data['data']['consultations'] as List? ?? [])
              .map((consultation) => ChatConsultation.fromJson(consultation))
              .toList();
          return consultations;
        } else {
          throw Exception(data['message'] ?? 'Failed to get consultations');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to get consultations');
      }
    } catch (e) {
      print('❌ Get chat consultations error: $e');
      throw Exception('Failed to get consultations: $e');
    }
  }

  // Send chat message - FIXED: Use ChatConsultationMessage
  static Future<ChatConsultationMessage> sendChatMessage({
    required String consultationId,
    required String message,
  }) async {
    try {
      final response = await HttpService.post(
        '/api/consultations/send-message',
        {
          'consultationId': consultationId,
          'message': message,
        },
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          return ChatConsultationMessage.fromJson(data['data']['message']);
        } else {
          throw Exception(data['message'] ?? 'Failed to send message');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      print('❌ Send chat message error: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  // Get chat messages for consultation - FIXED: Use ChatConsultationMessage
  static Future<List<ChatConsultationMessage>> getChatMessages(String consultationId) async {
    try {
      final response = await HttpService.get(
        '/api/consultations/chat-messages/$consultationId',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final messages = (data['data']['messages'] as List? ?? [])
              .map((message) => ChatConsultationMessage.fromJson(message))
              .toList();
          return messages;
        } else {
          throw Exception(data['message'] ?? 'Failed to get messages');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to get messages');
      }
    } catch (e) {
      print('❌ Get chat messages error: $e');
      throw Exception('Failed to get messages: $e');
    }
  }

  // Accept early consultation (when notified slot is available early)
  static Future<void> acceptEarlyConsultation(String consultationId) async {
    try {
      final response = await HttpService.post(
        '/api/consultations/accept-early',
        {
          'consultationId': consultationId,
        },
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to accept early consultation');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to accept early consultation');
      }
    } catch (e) {
      print('❌ Accept early consultation error: $e');
      throw Exception('Failed to accept early consultation: $e');
    }
  }

  // Cancel consultation
  static Future<void> cancelConsultation(String consultationId) async {
    try {
      final response = await HttpService.post(
        '/api/consultations/cancel',
        {
          'consultationId': consultationId,
        },
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to cancel consultation');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to cancel consultation');
      }
    } catch (e) {
      print('❌ Cancel consultation error: $e');
      throw Exception('Failed to cancel consultation: $e');
    }
  }
}