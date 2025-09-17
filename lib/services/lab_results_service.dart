import 'dart:convert';
import '../models/lab_results_models.dart';
import '../models/prescription_models.dart' as prescription_models;
import 'http_service.dart';

class LabResultsService {
  static const String _baseUrl = '/api/mobile/medical-history';
  static const String _prescriptionUrl = '/api/mobile/prescriptions';

  // Helper method to parse HTTP response
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

  // Get Lab Results - FIXED TO USE MEDICAL HISTORY ROUTE
  static Future<List<LabResult>> getLabResults() async {
    try {
      print('🧪 Fetching lab results...');

      // ✅ FIXED: Use medical history route for lab results
      final response = await HttpService.get('$_baseUrl/lab-results');
      final data = _parseResponse(response);

      if (data['success'] == true) {
        final List<dynamic> labData = data['data']['labResults'] ?? [];

        List<LabResult> labResults = labData.map((item) {
          return LabResult.fromJson(item);
        }).toList();

        print('✅ Found ${labResults.length} lab results');
        return labResults;
      } else {
        print('⚠️ No lab results found or API returned false');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching lab results: $e');
      return [];
    }
  }

  // Get Medical Records - USE MEDICAL HISTORY ROUTE
  static Future<List<MedicalRecord>> getMedicalRecords() async {
    try {
      print('📋 Fetching medical records...');

      final response = await HttpService.get(_baseUrl);
      final data = _parseResponse(response);

      if (data['success'] == true) {
        final List<dynamic> recordData = data['data']['records'] ?? [];

        List<MedicalRecord> records = recordData.map((item) {
          return MedicalRecord.fromJson(item);
        }).toList();

        print('✅ Found ${records.length} medical records');
        return records;
      } else {
        print('⚠️ No medical records found or API returned false');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching medical records: $e');
      return [];
    }
  }

  // Get Prescriptions - USE PRESCRIPTION ROUTE
  static Future<List<prescription_models.DigitalPrescription>>
      getPrescriptions() async {
    try {
      print('💊 Fetching prescriptions...');

      final response = await HttpService.get('$_prescriptionUrl/history');
      final data = _parseResponse(response);

      print('💊 Prescription API response success: ${data['success']}');
      print('💊 Prescription API message: ${data['message']}');

      if (data['success'] == true) {
        final List<dynamic> prescriptionData =
            data['data']['prescriptions'] ?? [];
        print('💊 Raw prescription data count: ${prescriptionData.length}');

        List<prescription_models.DigitalPrescription> prescriptions = [];

        for (int i = 0; i < prescriptionData.length; i++) {
          try {
            final item = prescriptionData[i];
            print(
                '💊 Processing prescription $i: ${item['id']} - ${item['prescriptionCode']}');

            if (item is Map<String, dynamic>) {
              final prescription =
                  prescription_models.DigitalPrescription.fromJson(item);
              prescriptions.add(prescription);
              print(
                  '✅ Prescription $i parsed: ${prescription.prescriptionCode} with ${prescription.medications.length} medications');
            } else {
              print('⚠️ Prescription $i is not a map: ${item.runtimeType}');
            }
          } catch (e, stackTrace) {
            print('❌ Error parsing prescription $i: $e');
            print('📥 Stack trace: $stackTrace');
            // ✅ SKIP instead of adding fallback
          }
        }

        print('✅ Successfully parsed ${prescriptions.length} prescriptions');
        return prescriptions;
      } else {
        print('⚠️ API returned success: false - ${data['message']}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching prescriptions: $e');
      print('📥 Stack trace: $stackTrace');
      return [];
    }
  }

  // Pay for Prescription
  static Future<bool> payPrescription(
      String prescriptionId, prescription_models.PaymentMethod method) async {
    try {
      print('💳 Processing prescription payment...');

      final response =
          await HttpService.post('$_prescriptionUrl/$prescriptionId/pay', {
        'paymentMethod': method.name,
        'timestamp': DateTime.now().toIso8601String(),
      });

      final data = _parseResponse(response);

      if (data['success'] == true) {
        print('✅ Prescription payment successful');
        return true;
      } else {
        throw Exception(data['message'] ?? 'Payment failed');
      }
    } catch (e) {
      print('❌ Error processing payment: $e');
      throw Exception('Payment failed: $e');
    }
  }

  // Get Prescription Detail with Medications
  static Future<prescription_models.DigitalPrescription?> getPrescriptionDetail(
      String prescriptionId) async {
    try {
      print('📄 Fetching prescription detail...');

      final response =
          await HttpService.get('$_prescriptionUrl/$prescriptionId');
      final data = _parseResponse(response);

      if (data['success'] == true) {
        return prescription_models.DigitalPrescription.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to get prescription detail');
      }
    } catch (e) {
      print('❌ Error fetching prescription detail: $e');
      return null;
    }
  }

  // Mark Lab Result as Read
  static Future<bool> markLabResultAsRead(String labResultId) async {
    try {
      // Use medical history route for lab result operations
      final response = await HttpService.patch(
          '$_baseUrl/lab-results/$labResultId/read', {});
      final data = _parseResponse(response);
      return data['success'] ?? false;
    } catch (e) {
      print('❌ Error marking lab result as read: $e');
      return false;
    }
  }
}
