import 'dart:convert';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/medical_history_models.dart';

class MedicalHistoryService {
  
  // Test connection
  static Future<bool> testConnection() async {
    try {
      final response = await HttpService.get(
        '/api/medical-records/test',
        token: AuthService.getCurrentToken(),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Medical history service test failed: $e');
      return false;
    }
  }
  
  // Get combined medical history (semua jenis riwayat)
  static Future<Map<String, dynamic>> getCombinedMedicalHistory() async {
    try {
      print('🔍 Fetching combined medical history...');
      
      final response = await HttpService.get(
        '/api/medical-records/combined-history',
        token: AuthService.getCurrentToken(),
      );

      print('📥 Medical history response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('📊 Response data: ${responseData['success']}');
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          print('📋 Medical history data keys: ${data.keys}');
          
          // Safe parsing with defaults
          final result = {
            'consultations': _safeParseList(data['consultations']),
            'queues': _safeParseList(data['queues']),
            'prescriptions': _safeParseList(data['prescriptions']),
            'medicalRecords': _safeParseList(data['medicalRecords']),
          };
          
          print('💬 Consultations: ${result['consultations']?.length ?? 0}');
          print('🔢 Queues: ${result['queues']?.length ?? 0}');
          print('💊 Prescriptions: ${result['prescriptions']?.length ?? 0}');
          
          return result;
        }
      }
      
      throw Exception('Failed to load combined medical history');
    } catch (e) {
      print('❌ Error getting combined medical history: $e');
      
      // Return empty data instead of throwing error
      return {
        'consultations': <Map<String, dynamic>>[],
        'queues': <Map<String, dynamic>>[],
        'prescriptions': <Map<String, dynamic>>[],
        'medicalRecords': <Map<String, dynamic>>[],
      };
    }
  }

  static List<Map<String, dynamic>> _safeParseList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];
    
    try {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        } else if (item is Map) {
          return Map<String, dynamic>.from(item);
        } else {
          return <String, dynamic>{'error': 'Invalid data format'};
        }
      }).toList();
    } catch (e) {
      print('❌ Error parsing list data: $e');
      return [];
    }
  }

  // Individual service methods with error handling
  static Future<List<ConsultationHistory>> getConsultationHistory() async {
    try {
      final response = await HttpService.get(
        '/api/medical-records/consultations/history',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> consultationsData = responseData['data']['consultations'];
          
          return consultationsData
              .map((consultation) => ConsultationHistory.fromJson(
                  consultation is Map<String, dynamic> 
                      ? consultation 
                      : Map<String, dynamic>.from(consultation as Map)))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Error getting consultation history: $e');
      return [];
    }
  }

  static Future<List<QueueHistory>> getQueueHistory() async {
    try {
      final response = await HttpService.get(
        '/api/medical-records/queues/history',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> queuesData = responseData['data']['queues'];
          
          return queuesData
              .map((queue) => QueueHistory.fromJson(
                  queue is Map<String, dynamic> 
                      ? queue 
                      : Map<String, dynamic>.from(queue as Map)))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Error getting queue history: $e');
      return [];
    }
  }

  static Future<List<PrescriptionHistory>> getPrescriptionHistory() async {
    try {
      final response = await HttpService.get(
        '/api/medical-records/prescriptions/history',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final List<dynamic> prescriptionsData = responseData['data']['prescriptions'];
          
          return prescriptionsData
              .map((prescription) => PrescriptionHistory.fromJson(
                  prescription is Map<String, dynamic> 
                      ? prescription 
                      : Map<String, dynamic>.from(prescription as Map)))
              .toList();
        }
      }
      
      return [];
    } catch (e) {
      print('❌ Error getting prescription history: $e');
      return [];
    }
  }
}