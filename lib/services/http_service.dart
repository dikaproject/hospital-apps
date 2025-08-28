import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpService {
  // Ngrok URL - Ganti dengan URL ngrok kamu
  static const String _baseUrl = 'https://11ab70ee4810.ngrok-free.app';

  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
      };

  static Map<String, String> _headersWithAuth(String token) => {
        ..._headers,
        'Authorization': 'Bearer $token',
      };

  // GET Request
  static Future<http.Response> get(String endpoint, {String? token}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = token != null ? _headersWithAuth(token) : _headers;

      print('🚀 GET: $uri');

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
      final headers = token != null ? _headersWithAuth(token) : _headers;

      print('🚀 POST: $uri');
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
      final headers = token != null ? _headersWithAuth(token) : _headers;

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
      final headers = token != null ? _headersWithAuth(token) : _headers;

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
