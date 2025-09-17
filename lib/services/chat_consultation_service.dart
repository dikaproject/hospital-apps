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
    if (status == null)
      return ConsultationStatus.inProgress; // Default for chat

    switch (status.toUpperCase()) {
      case 'WAITING':
      case 'PENDING':
        return ConsultationStatus.waiting;
      case 'IN_PROGRESS':
      case 'ACTIVE':
      case 'DOCTOR_CHAT': // ✅ Add this mapping
        return ConsultationStatus.inProgress;
      case 'COMPLETED':
      case 'FINISHED':
        return ConsultationStatus.completed;
      case 'CANCELLED':
      case 'CANCELED':
        return ConsultationStatus.cancelled;
      default:
        return ConsultationStatus.inProgress; // Default untuk chat aktif
    }
  }

  // Fix: Better error handling for consultations list
  static Future<List<ChatConsultation>> getChatConsultations() async {
    try {
      print('💬 Getting active doctor consultations...');

      final response = await HttpService.get(
        '/api/consultations/chat',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Chat consultations response: ${response.statusCode}');
      if (response.body != null) {
        print('📄 Response body: ${response.body.substring(0, 200)}...');
      }

      final data = _parseResponse(response);

      if (data['success'] == true) {
        final consultationsList = data['data']['consultations'] as List? ?? [];
        print('📊 Raw consultations count: ${consultationsList.length}');

        final mappedConsultations = consultationsList
            .map((item) {
              try {
                final consultation = item as Map<String, dynamic>;
                print('🔄 Processing consultation: ${consultation['id']} - ${consultation['type']}');

                // ✅ DOUBLE CHECK: Skip AI and completed consultations
                final consultationType = consultation['type']?.toString() ?? '';
                final isCompleted = consultation['isCompleted'] == true;
                
                if (consultationType == 'AI') {
                  print('⚠️ Skipping AI consultation: ${consultation['id']}');
                  return null;
                }
                
                if (isCompleted) {
                  print('⚠️ Skipping completed consultation: ${consultation['id']}');
                  return null;
                }

                // ✅ Only map active doctor consultations
                return ChatConsultation(
                  id: consultation['id']?.toString() ?? '',
                  doctorName: consultation['doctorName']?.toString() ??
                      consultation['doctor']?['name']?.toString() ?? 
                      'Dokter',
                  specialty: consultation['specialty']?.toString() ?? 
                            consultation['doctor']?['specialty']?.toString() ?? 
                            'Dokter Umum',
                  scheduledTime: DateTime.tryParse(
                          consultation['scheduledTime']?.toString() ??
                              consultation['createdAt']?.toString() ?? '') ??
                      DateTime.now(),
                  status: ConsultationStatus.inProgress, // ✅ Always in progress for active chats
                  queuePosition: 0,
                  estimatedWaitMinutes: 30,
                  messages: _parseMessages(consultation['chatHistory'] ?? consultation['messages']),
                  hasUnreadMessages: consultation['hasUnreadMessages'] == true,
                  lastMessageTime: consultation['lastMessageTime'] != null
                      ? DateTime.tryParse(consultation['lastMessageTime'])
                      : consultation['updatedAt'] != null
                          ? DateTime.tryParse(consultation['updatedAt'])
                          : null,
                );
              } catch (e) {
                print('❌ Error parsing consultation item: $e');
                print('📄 Item data: $item');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<ChatConsultation>()
            .toList();

        print('✅ Mapped active consultations: ${mappedConsultations.length}');
        return mappedConsultations;
      } else {
        print('⚠️ API returned error: ${data['message']}');
        return [];
      }
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
