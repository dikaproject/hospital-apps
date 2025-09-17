import 'dart:convert';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/qr_models.dart';

class QRService {
  
  // Generate or get static user QR code
  static Future<Map<String, dynamic>> generateUserQR() async {
    try {
      final response = await HttpService.post(
        '/api/qr/generate',
        {},
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      throw Exception('Failed to generate QR code');
    } catch (e) {
      print('❌ Error generating QR: $e');
      throw Exception('Failed to generate QR code: $e');
    }
  }

  // Get existing static user QR
  static Future<Map<String, dynamic>> getUserQR() async {
    try {
      final response = await HttpService.get(
        '/api/qr/user-qr',
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      throw Exception('Failed to get user QR');
    } catch (e) {
      print('❌ Error getting user QR: $e');
      throw Exception('Failed to get user QR: $e');
    }
  }

  // Parse QR data (for verification)
  static HospitalQRData? parseQRData(String qrData) {
    try {
      // ✅ Parse JSON directly (no base64 decoding)
      final Map<String, dynamic> data = json.decode(qrData);
      return HospitalQRData.fromJson(data);
    } catch (e) {
      print('❌ Error parsing QR data: $e');
      return null;
    }
  }

  // Handle QR scan actions
  static Future<Map<String, dynamic>> handleQRScan({
    required String qrData,
    required String action,
    String? location,
  }) async {
    try {
      final response = await HttpService.post(
        '/api/qr/scan-action',
        {
          'qrData': qrData,
          'action': action,
          'location': location,
        },
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data'];
        }
      }
      
      throw Exception('Failed to process QR scan');
    } catch (e) {
      print('❌ Error processing QR scan: $e');
      throw Exception('Failed to process QR scan: $e');
    }
  }

  // Validate QR code
  static Future<bool> validateQR(String qrData) async {
    try {
      final response = await HttpService.post(
        '/api/qr/validate',
        {'qrData': qrData},
        token: AuthService.getCurrentToken(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error validating QR: $e');
      return false;
    }
  }

  // ✅ NEW: Get formatted QR text for display/sharing
  static String getQRText(String qrData) {
    try {
      final data = json.decode(qrData);
      return """
HOSPITALINK PATIENT ID
====================
Name: ${data['fullName'] ?? 'N/A'}
NIK: ${data['nik'] ?? 'N/A'}
Phone: ${data['phone'] ?? 'N/A'}
Hospital: ${data['hospital'] ?? 'HospitalLink'}
Patient ID: ${data['userId'] ?? 'N/A'}
====================
Scan this QR for check-in
""";
    } catch (e) {
      return qrData;
    }
  }
}