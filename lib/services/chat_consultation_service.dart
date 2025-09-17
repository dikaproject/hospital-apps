import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/consultation_models.dart';
import 'http_service.dart';
import 'auth_service.dart';

// Update ChatConsultationService
class ChatConsultationService {
  static Map<String, dynamic> _parseResponse(dynamic response) {
    try {
      if (response.body != null && response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return {'success': false, 'message': 'Empty response'};
    } catch (e) {
      print('❌ Error parsing response: $e');
      return {'success': false, 'message': 'Invalid JSON response'};
    }
  }

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

      final uri = Uri.parse(
              '${HttpService.getCurrentBaseUrl()}/api/consultations/available-slots')
          .replace(queryParameters: queryParams);

      final response = await HttpService.get(
        uri.toString().replaceFirst(HttpService.getCurrentBaseUrl(), ''),
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] == true) {
        final slots = (data['data']['slots'] as List? ?? [])
            .map((slot) => TimeSlot.fromJson(slot))
            .toList();
        return slots;
      } else {
        throw Exception(data['message'] ?? 'Failed to get available slots');
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

      final data = _parseResponse(response);

      if (data['success'] == true) {
        return ChatConsultation.fromJson(data['data']['consultation']);
      } else {
        throw Exception(data['message'] ?? 'Failed to book consultation');
      }
    } catch (e) {
      print('❌ Book chat consultation error: $e');
      throw Exception('Failed to book consultation: $e');
    }
  }

  // Fix status mapping
  static ConsultationStatus _mapStringToStatus(String? status) {
    if (status == null) return ConsultationStatus.waiting;

    switch (status.toUpperCase()) {
      case 'WAITING':
      case 'PENDING':
        return ConsultationStatus.waiting;
      case 'IN_PROGRESS':
      case 'ACTIVE':
      case 'PAID':
        return ConsultationStatus.inProgress;
      case 'COMPLETED':
      case 'FINISHED':
        return ConsultationStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return ConsultationStatus.cancelled;
      default:
        return ConsultationStatus.waiting;
    }
  }

  // Fix: Better error handling for consultations list
  static Future<List<ChatConsultation>> getChatConsultations() async {
    try {
      print('📱 Getting chat consultations...');

      // Fix: Use correct endpoint
      final response = await HttpService.get(
        '/api/consultations/chat', // Changed from '/api/mobile/consultations/chat'
        token: AuthService.getCurrentToken(),
      );

      print('📥 Chat consultations response: ${response.statusCode}');

      final data = _parseResponse(response);

      if (data['success'] == true) {
        final consultationsList = data['data']['consultations'] as List? ?? [];

        return consultationsList
            .map((item) {
              try {
                final consultation = item as Map<String, dynamic>;
                final isPaid = consultation['isPaid'] == true;
                final paymentStatus = consultation['paymentStatus']?.toString();

                // Fix: Check if consultation is really completed
                String status = consultation['status']?.toString() ?? 'WAITING';
                final isCompleted = consultation['isCompleted'] == true;

                if (isPaid && paymentStatus == 'PAID' && !isCompleted) {
                  status = 'IN_PROGRESS'; // Only if not completed
                } else if (isCompleted) {
                  status = 'COMPLETED';
                }

                return ChatConsultation(
                  id: consultation['id']?.toString() ?? '',
                  doctorName: consultation['doctorName']?.toString() ??
                      'Unknown Doctor',
                  specialty: consultation['specialty']?.toString() ?? 'General',
                  scheduledTime: DateTime.tryParse(
                          consultation['scheduledTime']?.toString() ?? '') ??
                      DateTime.now(),
                  status: _mapStringToStatus(status),
                  queuePosition: (consultation['queuePosition'] is num)
                      ? (consultation['queuePosition'] as num).toInt()
                      : 1,
                  estimatedWaitMinutes: (consultation['estimatedWaitMinutes']
                          is num)
                      ? (consultation['estimatedWaitMinutes'] as num).toInt()
                      : 30,
                  messages: _parseMessages(consultation['messages']),
                  hasUnreadMessages: consultation['hasUnreadMessages'] == true,
                  lastMessageTime: consultation['lastMessageTime'] != null
                      ? DateTime.tryParse(consultation['lastMessageTime'])
                      : null,
                );
              } catch (e) {
                print('Error parsing consultation item: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<ChatConsultation>()
            .toList();
      }

      return [];
    } catch (e) {
      print('❌ Error getting chat consultations: $e');
      return [];
    }
  }

  static List<ChatConsultationMessage> _parseMessages(dynamic messagesData) {
    try {
      final messagesList = messagesData as List? ?? [];
      return messagesList
          .map((msg) => ChatConsultationMessage.fromJson(msg))
          .toList();
    } catch (e) {
      print('Error parsing messages: $e');
      return [];
    }
  }

  // Update ChatConsultationService
  static Future<List<ChatConsultationMessage>> getChatMessages(
      String consultationId) async {
    try {
      print('📱 Getting chat messages for: $consultationId');

      // Fix: Use the correct endpoint path
      final response = await HttpService.get(
        '/api/consultations/chat-messages/$consultationId', // Fixed path
        token: AuthService.getCurrentToken(),
      );

      print('📥 Chat messages response: ${response.statusCode}');

      final data = _parseResponse(response);

      if (data['success'] == true) {
        final messages = (data['data']['messages'] as List? ?? [])
            .map((message) => ChatConsultationMessage.fromJson(message))
            .toList();
        print('✅ Retrieved ${messages.length} messages');
        return messages;
      } else {
        print('⚠️ API returned error: ${data['message']}');

        // If unauthorized, return empty list instead of throwing
        if (response.statusCode == 403) {
          print('🔒 Authorization failed, returning empty messages');
          return [];
        }

        throw Exception(data['message'] ?? 'Failed to get messages');
      }
    } catch (e) {
      print('❌ Get chat messages error: $e');

      // Return empty list for authorization errors
      if (e.toString().contains('Not authorized')) {
        print('🔒 Returning empty messages due to authorization');
        return [];
      }

      throw Exception('Failed to get messages: $e');
    }
  }

  // Add send message with better error handling
  static Future<ChatConsultationMessage> sendChatMessage({
  required String consultationId,
  required String message,
}) async {
  try {
    print('📤 Sending chat message to: $consultationId');

    // Fix: Use correct endpoint without /mobile prefix
    final response = await HttpService.post(
      '/api/consultations/send-message', // Fixed path
      {
        'consultationId': consultationId,
        'message': message,
      },
      token: AuthService.getCurrentToken(),
    );

    print('📥 Send message response: ${response.statusCode}');

    final data = _parseResponse(response);

    if (data['success'] == true) {
      print('✅ Message sent successfully');
      return ChatConsultationMessage.fromJson(data['data']['message']);
    } else {
      throw Exception(data['message'] ?? 'Failed to send message');
    }
  } catch (e) {
    print('❌ Send chat message error: $e');
    throw Exception('Failed to send message: $e');
  }
}

  // Accept early consultation
  static Future<void> acceptEarlyConsultation(String consultationId) async {
    try {
      final response = await HttpService.post(
        '/api/consultations/accept-early',
        {
          'consultationId': consultationId,
        },
        token: AuthService.getCurrentToken(),
      );

      final data = _parseResponse(response);

      if (data['success'] != true) {
        throw Exception(
            data['message'] ?? 'Failed to accept early consultation');
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

      final data = _parseResponse(response);

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to cancel consultation');
      }
    } catch (e) {
      print('❌ Cancel consultation error: $e');
      throw Exception('Failed to cancel consultation: $e');
    }
  }
}
