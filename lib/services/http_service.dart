import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  // Ngrok URL - Ganti dengan URL ngrok kamu
  static const String _baseUrl = 'https://5b64b31db9f9.ngrok-free.app';
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  // Get headers with auth token from SharedPreferences
  static Future<Map<String, String>> _getHeadersWithAuth(
      {String? token}) async {
    final headers = Map<String, String>.from(_headers);

    // Use provided token or get from SharedPreferences
    final authToken = token ?? await _getStoredToken();

    if (authToken != null && authToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // Get stored token from SharedPreferences
  static Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('❌ Error getting stored token: $e');
      return null;
    }
  }

  // GET Request
  static Future<http.Response> get(String endpoint, {String? token}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeadersWithAuth(token: token);

      print('🚀 GET: $uri');
      print('🔑 Headers: ${headers.keys.join(', ')}');

      final response = await http.get(uri, headers: headers).timeout(_timeout);

      print(
          '📥 Response: ${response.statusCode} - ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');

      return response;
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // POST Request
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeadersWithAuth(token: token);

      print('🚀 POST: $uri');
      print('🔑 Headers: ${headers.keys.join(', ')}');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .post(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(_timeout);

      print(
          '📥 Response: ${response.statusCode} - ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');

      return response;
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // PUT Request
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body,
      {String? token}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeadersWithAuth(token: token);

      print('🚀 PUT: $uri');
      print('📤 Body: ${json.encode(body)}');

      final response = await http
          .put(
            uri,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(_timeout);

      print('📥 Response: ${response.statusCode} - ${response.body}');

      return response;
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // DELETE Request
  static Future<http.Response> delete(String endpoint, {String? token}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeadersWithAuth(token: token);

      print('🚀 DELETE: $uri');

      final response =
          await http.delete(uri, headers: headers).timeout(_timeout);

      print('📥 Response: ${response.statusCode} - ${response.body}');

      return response;
    } on SocketException {
      throw Exception('Tidak ada koneksi internet');
    } on HttpException {
      throw Exception('HTTP error occurred');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // PATCH Request
  static Future<http.Response> patch(String endpoint, Map<String, dynamic> data,
      {String? token}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getHeadersWithAuth(token: token);

      print('🔄 PATCH Request: $uri');
      print('📤 Request Body: ${json.encode(data)}');

      final response = await http
          .patch(
            uri,
            headers: headers,
            body: json.encode(data),
          )
          .timeout(_timeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ HTTP PATCH Error: $e');
      rethrow;
    }
  }

  // Test connection method
  static Future<bool> testConnection() async {
    try {
      final response = await get('/health');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: ${e.toString()}');
      return false;
    }
  }

  // Get current base URL
  static String getCurrentBaseUrl() {
    return _baseUrl;
  }
}
