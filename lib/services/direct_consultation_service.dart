import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/consultation_models.dart';
import 'http_service.dart';
import 'auth_service.dart';

class DirectConsultationService {
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

  // ✅ Get available doctors for direct consultation
  static Future<List<DoctorInfo>> getAvailableDoctors() async {
    try {
      print('🩺 Getting available doctors for direct consultation...');

      final response = await HttpService.get(
        '/api/mobile/direct-consultation/available-doctors',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Available doctors response: ${response.statusCode}');

      final data = _parseResponse(response);

      if (data['success'] == true) {
        final doctorsList = data['data']['doctors'] as List? ?? [];

        return doctorsList
            .map((doctor) => DoctorInfo.fromJson(doctor))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to get available doctors');
      }
    } catch (e) {
      print('❌ Get available doctors error: $e');
      throw Exception('Failed to get available doctors: $e');
    }
  }

  // ✅ Start direct consultation with selected doctor
  static Future<DirectConsultationResult> startDirectConsultation({
    required String doctorId,
    required List<String> symptoms,
    String? notes,
    String consultationType = 'CHAT',
  }) async {
    try {
      print('🚀 Starting direct consultation with doctor: $doctorId');

      final response = await HttpService.post(
        '/api/mobile/direct-consultation/start',
        {
          'doctorId': doctorId,
          'symptoms': symptoms,
          'notes': notes,
          'consultationType': consultationType,
        },
        token: AuthService.getCurrentToken(),
      );

      print('📥 Start consultation response: ${response.statusCode}');

      final data = _parseResponse(response);

      if (data['success'] == true) {
        return DirectConsultationResult.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to start consultation');
      }
    } catch (e) {
      print('❌ Start direct consultation error: $e');
      throw Exception('Failed to start consultation: $e');
    }
  }

  // ✅ Get consultation details
  static Future<Map<String, dynamic>> getConsultationDetails(
      String consultationId) async {
    try {
      print('📋 Getting consultation details: $consultationId');

      final response = await HttpService.get(
        '/api/mobile/direct-consultation/details/$consultationId',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Consultation details response: ${response.statusCode}');

      final data = _parseResponse(response);

      if (data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(
            data['message'] ?? 'Failed to get consultation details');
      }
    } catch (e) {
      print('❌ Get consultation details error: $e');
      throw Exception('Failed to get consultation details: $e');
    }
  }
}
