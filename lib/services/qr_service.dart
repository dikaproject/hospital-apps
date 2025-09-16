import 'dart:convert';
import 'http_service.dart';
import 'auth_service.dart';
import '../models/qr_models.dart';

class QRService {
  
  // Generate user QR code
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

  // Get current user QR
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
}