import 'dart:convert';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'http_service.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static UserModel? _currentUser;
  static String? _currentToken;

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!isAvailable || !isDeviceSupported) {
        return false;
      }

      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Validate NIK format
  static bool isValidNIK(String nik) {
    return nik.length == 16 && RegExp(r'^\d{16}$').hasMatch(nik);
  }

  // Register user
  static Future<UserModel?> register({
    required String email,
    required String fullName,
    required String password,
    String? nik,
    String? phone,
    String? gender,
    String? dateOfBirth,
    String? street,
    String? village,
    String? district,
    String? regency,
    String? province,
    String? fingerprintData,
  }) async {
    try {
      final requestBody = {
        'email': email,
        'fullName': fullName,
        'password': password,
      };

      // Add optional fields
      if (nik != null && nik.isNotEmpty) requestBody['nik'] = nik;
      if (phone != null && phone.isNotEmpty) requestBody['phone'] = phone;
      if (gender != null && gender.isNotEmpty) requestBody['gender'] = gender;
      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
        requestBody['dateOfBirth'] = dateOfBirth;
      if (street != null && street.isNotEmpty) requestBody['street'] = street;
      if (village != null && village.isNotEmpty)
        requestBody['village'] = village;
      if (district != null && district.isNotEmpty)
        requestBody['district'] = district;
      if (regency != null && regency.isNotEmpty)
        requestBody['regency'] = regency;
      if (province != null && province.isNotEmpty)
        requestBody['province'] = province;
      if (fingerprintData != null && fingerprintData.isNotEmpty)
        requestBody['fingerprintData'] = fingerprintData;

      print(
          '🔄 Attempting registration to: ${HttpService.getCurrentBaseUrl()}');

      final response =
          await HttpService.post('/api/auth/mobile/register', requestBody);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final userData = responseData['data']['user'];
          final token = responseData['data']['token'];

          final user = UserModel.fromApiResponse(userData);

          // Save to local storage
          await _saveAuthData(token, user);

          _currentUser = user;
          _currentToken = token;

          print('✅ Registration successful for: ${user.email}');
          return user;
        } else {
          throw Exception(responseData['message'] ?? 'Registration failed');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('❌ Registration error: ${e.toString()}');

      if (e.toString().contains('User with this email already exists')) {
        throw Exception('Email sudah terdaftar');
      } else if (e.toString().contains('User with this nik already exists')) {
        throw Exception('NIK sudah terdaftar');
      } else if (e.toString().contains('NIK must be exactly 16 digits')) {
        throw Exception('NIK harus 16 digit angka');
      } else if (e.toString().contains('Tidak ada koneksi internet')) {
        throw Exception(
            'Tidak ada koneksi internet. Pastikan HP terhubung ke internet.');
      } else if (e.toString().contains('Network error')) {
        throw Exception(
            'Gagal terhubung ke server. Coba lagi dalam beberapa saat.');
      }
      throw Exception('Registrasi gagal: ${e.toString()}');
    }
  }

  // Login with password (email or NIK)
  static Future<UserModel?> loginWithPassword(
      String identifier, String password) async {
    try {
      final requestBody = {
        'password': password,
      };

      // Check if identifier is email or NIK
      if (identifier.contains('@')) {
        requestBody['email'] = identifier;
      } else {
        requestBody['nik'] = identifier;
      }

      print('🔄 Attempting login to: ${HttpService.getCurrentBaseUrl()}');

      final response =
          await HttpService.post('/api/auth/mobile/login', requestBody);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          final userData = responseData['data']['user'];
          final token = responseData['data']['token'];

          final user = UserModel.fromApiResponse(userData);

          // Save to local storage
          await _saveAuthData(token, user);

          _currentUser = user;
          _currentToken = token;

          print('✅ Login successful for: ${user.email}');
          return user;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Login error: ${e.toString()}');

      if (e.toString().contains('Tidak ada koneksi internet')) {
        throw Exception('Tidak ada koneksi internet');
      }
      throw Exception('Login gagal: ${e.toString()}');
    }
  }

  // Register fingerprint
  static Future<String?> registerFingerprint() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric tidak tersedia pada perangkat ini');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan fingerprint untuk registrasi',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Generate unique fingerprint identifier
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        return 'fp_mobile_$timestamp';
      }
      return null;
    } on PlatformException catch (e) {
      throw Exception('Error registrasi fingerprint: ${e.message}');
    } catch (e) {
      throw Exception('Registrasi fingerprint gagal: ${e.toString()}');
    }
  }

  // Login with fingerprint
  static Future<UserModel?> loginWithFingerprint() async {
    try {
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric tidak tersedia pada perangkat ini');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Scan fingerprint untuk masuk ke HospitalLink',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        String? storedFingerprintData = prefs.getString('fingerprint_data');

        // Jika tidak ada, coba ambil dari user data terakhir
        if (storedFingerprintData == null) {
          final userData = prefs.getString(_userKey);
          if (userData != null) {
            final userMap = json.decode(userData);
            storedFingerprintData = userMap['fingerprintData'];
            if (storedFingerprintData != null) {
              await prefs.setString('fingerprint_data', storedFingerprintData);
            }
          }
        }

        if (storedFingerprintData != null) {
          final requestBody = {'fingerprintData': storedFingerprintData};
          final response =
              await HttpService.post('/api/auth/mobile/login', requestBody);

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              final userData = responseData['data']['user'];
              final token = responseData['data']['token'];
              final user = UserModel.fromApiResponse(userData);

              await _saveAuthData(token, user);
              _currentUser = user;
              _currentToken = token;

              return user;
            }
          } else {
            final errorData = json.decode(response.body);
            throw Exception('${errorData['message'] ?? 'Login gagal'}');
          }
        } else {
          throw Exception(
              'Tidak ada data fingerprint tersimpan. Silakan daftar ulang dengan fingerprint.');
        }
        return null;
      }
      return null;
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        throw Exception('Biometric authentication tidak tersedia');
      } else if (e.code == 'NotEnrolled') {
        throw Exception('Tidak ada fingerprint yang terdaftar di perangkat');
      } else if (e.code == 'UserCancel') {
        return null;
      }
      throw Exception('Error fingerprint login: ${e.message}');
    } catch (e) {
      throw Exception('Fingerprint login gagal: ${e.toString()}');
    }
  }

  // Save authentication data to local storage
  static Future<void> _saveAuthData(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Create user data map for saving
    final userDataToSave = {
      'email': user.email,
      'fullName': user.fullName,
      'nik': user.nik,
      'phone': user.phone,
      'gender': user.gender,
      'dateOfBirth': user.dateOfBirth?.toIso8601String(),
      'street': user.street,
      'village': user.village,
      'district': user.district,
      'regency': user.regency,
      'province': user.province,
      'fingerprintData': user.fingerprintData,
      'qrCode': user.qrCode,
      'role': user.role,
      'isActive': user.isActive,
    };

    await prefs.setString(_userKey, json.encode(userDataToSave));

    // Save fingerprint data separately as backup
    if (user.fingerprintData != null && user.fingerprintData!.isNotEmpty) {
      await prefs.setString('fingerprint_data', user.fingerprintData!);
      print('💾 Saved fingerprint data: ${user.fingerprintData}');
    } else {
      print('⚠️ No fingerprint data to save');
    }

    print('💾 User data saved to SharedPreferences');
  }

  // Load authentication data from local storage
  static Future<bool> loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      if (token != null && userData != null) {
        _currentToken = token;

        // Try to verify token with server (optional, skip if offline)
        try {
          final response =
              await HttpService.get('/api/users/profile', token: token);

          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              _currentUser =
                  UserModel.fromApiResponse(responseData['data']['user']);
              return true;
            }
          }
        } catch (e) {
          // If server verification fails, use local data
          print(
              '⚠️ Server verification failed, using local data: ${e.toString()}');
        }

        // Fallback to local user data
        final userMap = json.decode(userData);
        _currentUser = UserModel.fromApiResponse({
          'id': 'local_user_id',
          'email': userMap['email'],
          'fullName': userMap['fullName'],
          'nik': userMap['nik'],
          'phone': userMap['phone'],
          'gender': userMap['gender'],
          'dateOfBirth': userMap['dateOfBirth'],
          'street': userMap['street'],
          'village': userMap['village'],
          'district': userMap['district'],
          'regency': userMap['regency'],
          'province': userMap['province'],
          'qrCode': 'QR_local_123456',
          'fingerprintData': userMap['fingerprintData'],
          'role': 'USER',
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLogin': DateTime.now().toIso8601String(),
        });

        return true;
      }

      return false;
    } catch (e) {
      print('❌ Load auth data error: ${e.toString()}');
      await clearAuthData();
      return false;
    }
  }

  // Clear authentication data
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    _currentUser = null;
    _currentToken = null;
  }

  // Get current user
  static UserModel? getCurrentUser() {
    return _currentUser;
  }

  // Get current token
  static String? getCurrentToken() {
    return _currentToken;
  }

  // Logout
  static Future<void> logout() async {
    await clearAuthData();
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return _currentUser != null && _currentToken != null;
  }

  // Check server health
  static Future<bool> checkServerHealth() async {
    try {
      final response = await HttpService.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update local user data
  static Future<void> updateLocalUser(UserModel updatedUser) async {
    _currentUser = updatedUser;
    final prefs = await SharedPreferences.getInstance();

    final userDataToSave = {
      'id': updatedUser.id,
      'email': updatedUser.email,
      'fullName': updatedUser.fullName,
      'nik': updatedUser.nik,
      'phone': updatedUser.phone,
      'gender': updatedUser.gender,
      'dateOfBirth': updatedUser.dateOfBirth?.toIso8601String(),
      'street': updatedUser.street,
      'village': updatedUser.village,
      'district': updatedUser.district,
      'regency': updatedUser.regency,
      'province': updatedUser.province,
      'fingerprintData': updatedUser.fingerprintData,
      'qrCode': updatedUser.qrCode,
      'profilePicture': updatedUser.profilePicture, // Tambah ini
      'role': updatedUser.role,
      'isActive': updatedUser.isActive,
      'createdAt': updatedUser.createdAt.toIso8601String(),
      'lastLogin': updatedUser.lastLogin?.toIso8601String(),
    };

    await prefs.setString(_userKey, json.encode(userDataToSave));
    print('✅ Local user data updated with email: ${updatedUser.email}');
  }
}
