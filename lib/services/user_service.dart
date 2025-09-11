import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_service.dart';
import 'http_service.dart';

class UserService {
  // Update profile
  static Future<UserModel?> updateProfile({
    String? phone,
    String? gender,
    String? street,
    File? profilePicture,
  }) async {
    try {
      final token = AuthService.getCurrentToken();
      if (token == null) throw Exception('No authentication token');

      // Use multipart request for file upload
      final uri =
          Uri.parse('${HttpService.getCurrentBaseUrl()}/api/users/profile');
      final request = http.MultipartRequest('PUT', uri);

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      });

      // Add fields
      if (phone != null) request.fields['phone'] = phone;
      if (gender != null) request.fields['gender'] = gender;
      if (street != null) request.fields['street'] = street;

      // Add profile picture if provided
      if (profilePicture != null) {
        final file = await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
        );
        request.files.add(file);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return UserModel.fromApiResponse(responseData['data']['user']);
        }
      }

      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Update profile failed');
    } catch (e) {
      throw Exception('Update profile failed: ${e.toString()}');
    }
  }

  // Change email
  static Future<bool> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final token = AuthService.getCurrentToken();
      if (token == null) throw Exception('No authentication token');

      final response = await HttpService.put(
        '/api/users/change-email',
        {
          'newEmail': newEmail,
          'currentPassword': currentPassword,
        },
        token: token,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }

      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Change email failed');
    } catch (e) {
      throw Exception('Change email failed: ${e.toString()}');
    }
  }

  // Change password
  static Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = AuthService.getCurrentToken();
      if (token == null) throw Exception('No authentication token');

      final response = await HttpService.put(
        '/api/users/change-password',
        {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        token: token,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }

      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Change password failed');
    } catch (e) {
      throw Exception('Change password failed: ${e.toString()}');
    }
  }

  // Register fingerprint - FIXED VERSION
  static Future<bool> registerFingerprint(String fingerprintData) async {
    try {
      final token = AuthService.getCurrentToken();
      if (token == null) throw Exception('No authentication token');

      print('🔄 Registering fingerprint: $fingerprintData');

      final response = await HttpService.put(
        // Changed to PUT to match backend
        '/api/users/register-fingerprint',
        {'fingerprintData': fingerprintData},
        token: token,
      );

      print(
          '📥 Fingerprint register response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      }

      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Register fingerprint failed');
    } catch (e) {
      print('❌ Register fingerprint error: ${e.toString()}');
      throw Exception('Register fingerprint failed: ${e.toString()}');
    }
  }
}
