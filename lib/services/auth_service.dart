import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart'; // Add this for hashing
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'http_service.dart';
import 'user_service.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static UserModel? _currentUser;
  static String? _currentToken;

  // SharedPreferences keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Register fingerprint - SIMPLIFIED VERSION
  static Future<String?> registerFingerprint() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        throw Exception('Biometric tidak tersedia pada perangkat ini');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Daftarkan fingerprint untuk login cepat',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Check if user is logged in
        final currentUser = getCurrentUser();
        final token = getCurrentToken();

        if (currentUser == null || token == null) {
          throw Exception('User not logged in. Please login first.');
        }

        // Generate simple but unique fingerprint data based on device
        final deviceId = await _getSimpleDeviceId();
        final biometricHash =
            _generateSimpleBiometricHash(currentUser.id, deviceId);

        print('🔄 Generated biometric hash: $biometricHash');

        // Call backend to register fingerprint
        final success = await UserService.registerFingerprint(biometricHash);

        if (success) {
          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_fingerprint_data', biometricHash);

          // Update local user data
          final updatedUser =
              currentUser.copyWith(fingerprintData: biometricHash);
          await _saveUserData(updatedUser);
          _currentUser = updatedUser;

          print('✅ Fingerprint registered and saved locally');
          return biometricHash;
        } else {
          throw Exception('Failed to register fingerprint on server');
        }
      }

      return null; // User cancelled
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel') {
        return null;
      }
      throw Exception('Error registering fingerprint: ${e.message}');
    } catch (e) {
      print('❌ Register fingerprint error: ${e.toString()}');
      throw Exception('Registering fingerprint failed: ${e.toString()}');
    }
  }

  // Login with fingerprint - SIMPLIFIED VERSION
  static Future<UserModel?> loginWithFingerprint() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        throw Exception('Biometric tidak tersedia pada perangkat ini');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Login dengan fingerprint',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Get stored fingerprint data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final storedFingerprintData = prefs.getString('user_fingerprint_data');

        if (storedFingerprintData == null) {
          throw Exception(
              'Fingerprint belum terdaftar. Silakan daftar fingerprint terlebih dahulu.');
        }

        print('🔄 Attempting fingerprint login with: $storedFingerprintData');

        // Call backend for fingerprint login
        final response =
            await HttpService.post('/api/auth/mobile/fingerprint-login', {
          'fingerprintData': storedFingerprintData,
        });

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

            print('✅ Fingerprint login successful for: ${user.email}');
            return user;
          } else {
            throw Exception(
                responseData['message'] ?? 'Fingerprint login failed');
          }
        } else {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Fingerprint login failed');
        }
      }

      return null; // User cancelled
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel') {
        return null;
      }
      throw Exception('Error fingerprint login: ${e.message}');
    } catch (e) {
      print('❌ Fingerprint login error: ${e.toString()}');
      throw Exception('Fingerprint login failed: ${e.toString()}');
    }
  }

  // Simple device ID generation - SIMPLIFIED
  static Future<String> _getSimpleDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('simple_device_id');

      if (deviceId == null) {
        // Generate simple device ID based on timestamp + platform
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final platform = Platform.isAndroid ? 'AND' : 'IOS';
        deviceId = '${platform}_${timestamp.toString().substring(8)}';
        await prefs.setString('simple_device_id', deviceId);
        print('🆔 Generated simple device ID: $deviceId');
      } else {
        print('🆔 Using existing device ID: $deviceId');
      }

      return deviceId;
    } catch (e) {
      // Ultimate fallback
      final fallback = 'DEV_${DateTime.now().millisecondsSinceEpoch}';
      print('⚠️ Using fallback device ID: $fallback');
      return fallback;
    }
  }

  // Simple biometric hash - SIMPLIFIED
  static String _generateSimpleBiometricHash(String userId, String deviceId) {
    // Create simple hash
    final combined = '${userId}_${deviceId}_BIOMETRIC';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return 'BIO_${digest.toString().substring(0, 24)}';
  }

  // Generate consistent biometric hash - FIXED VERSION
  static String _generateBiometricHash(String userId, String deviceId) {
    // Create a CONSISTENT hash based on user and device only
    // Remove timestamp dan random elements
    final combined = '$userId:$deviceId:HOSPITALINK_BIOMETRIC';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return 'BIO_${digest.toString().substring(0, 32)}';
  }

  // Get device ID - FIXED VERSION untuk consistent
  static Future<String> _getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');

      if (deviceId == null) {
        // Generate device ID berdasarkan info device yang tidak berubah
        // Simulasi device fingerprint
        final deviceInfo =
            'ANDROID_${Platform.operatingSystemVersion.hashCode}';
        deviceId = 'DEV_${deviceInfo.hashCode.abs()}';
        await prefs.setString('device_id', deviceId);
        print('🆔 Generated new device ID: $deviceId');
      } else {
        print('🆔 Using existing device ID: $deviceId');
      }

      return deviceId;
    } catch (e) {
      // Fallback yang konsisten
      final fallbackId =
          'DEV_FALLBACK_${Platform.operatingSystem.hashCode.abs()}';
      print('⚠️ Using fallback device ID: $fallbackId');
      return fallbackId;
    }
  }

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

      // Handle fingerprint data for registration
      if (fingerprintData != null && fingerprintData.isNotEmpty) {
        // Regenerate fingerprint hash with actual user ID after registration
        // For now, use the provided fingerprint data
        requestBody['fingerprintData'] = fingerprintData;
      }

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

          // If fingerprint was registered during signup, update it with proper user ID
          if (fingerprintData != null && fingerprintData.isNotEmpty) {
            try {
              final deviceId = await _getSimpleDeviceId();
              final properFingerprintHash =
                  _generateSimpleBiometricHash(user.id, deviceId);

              // Update fingerprint with proper user ID
              final updateSuccess =
                  await UserService.registerFingerprint(properFingerprintHash);

              if (updateSuccess) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'user_fingerprint_data', properFingerprintHash);

                // Update local user data
                final updatedUser =
                    user.copyWith(fingerprintData: properFingerprintHash);
                await _saveUserData(updatedUser);
                _currentUser = updatedUser;

                print(
                    '✅ Fingerprint updated with proper user ID: $properFingerprintHash');
              }
            } catch (e) {
              print(
                  '⚠️ Failed to update fingerprint with proper user ID: ${e.toString()}');
              // Don't fail registration if fingerprint update fails
            }
          }

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

  // Register fingerprint during signup (without auth token) - NEW METHOD
  static Future<String?> registerFingerprintForNewUser(String userId) async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        throw Exception('Biometric tidak tersedia pada perangkat ini');
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Daftarkan fingerprint untuk login cepat',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Generate fingerprint hash for new user
        final deviceId = await _getSimpleDeviceId();
        final biometricHash = _generateSimpleBiometricHash(userId, deviceId);

        print('🔄 Generated biometric hash for new user: $biometricHash');

        // Save to local storage for later use
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_fingerprint_data', biometricHash);
        await prefs.setString(
            'pending_fingerprint_data', biometricHash); // Store as pending

        print('✅ Fingerprint registered locally for new user');
        return biometricHash;
      }

      return null; // User cancelled
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel') {
        return null;
      }
      throw Exception('Error registering fingerprint: ${e.message}');
    } catch (e) {
      print('❌ Register fingerprint for new user error: ${e.toString()}');
      throw Exception('Registering fingerprint failed: ${e.toString()}');
    }
  }

  // Apply pending fingerprint after login - NEW METHOD
  static Future<void> applyPendingFingerprint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingFingerprintData =
          prefs.getString('pending_fingerprint_data');

      if (pendingFingerprintData != null) {
        print('🔄 Applying pending fingerprint: $pendingFingerprintData');

        // Call backend to register fingerprint
        final success =
            await UserService.registerFingerprint(pendingFingerprintData);

        if (success) {
          // Remove pending data
          await prefs.remove('pending_fingerprint_data');

          // Update current user data
          final currentUser = getCurrentUser();
          if (currentUser != null) {
            final updatedUser =
                currentUser.copyWith(fingerprintData: pendingFingerprintData);
            await _saveUserData(updatedUser);
            _currentUser = updatedUser;
          }

          print('✅ Pending fingerprint applied successfully');
        } else {
          print('❌ Failed to apply pending fingerprint');
        }
      }
    } catch (e) {
      print('❌ Apply pending fingerprint error: ${e.toString()}');
    }
  }

  // Login with password (email or NIK) - UPDATED
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

          // Apply any pending fingerprint registration
          await applyPendingFingerprint();

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

  // Save authentication data to local storage
  static Future<void> _saveAuthData(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Create user data map for saving
    final userDataToSave = {
      'id': user.id,
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
      'profilePicture': user.profilePicture,
      'role': user.role,
      'isActive': user.isActive,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLogin': user.lastLogin?.toIso8601String(),
    };

    await prefs.setString(_userKey, json.encode(userDataToSave));

    // Save fingerprint data separately as backup
    if (user.fingerprintData != null && user.fingerprintData!.isNotEmpty) {
      await prefs.setString('user_fingerprint_data', user.fingerprintData!);
      print('💾 Saved fingerprint data: ${user.fingerprintData}');
    } else {
      print('⚠️ No fingerprint data to save');
    }

    print('💾 User data saved to SharedPreferences');
  }

  // Save user data to local storage - ADD THIS METHOD
  static Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    final userDataToSave = {
      'id': user.id,
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
      'profilePicture': user.profilePicture,
      'role': user.role,
      'isActive': user.isActive,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLogin': user.lastLogin?.toIso8601String(),
    };

    await prefs.setString(_userKey, json.encode(userDataToSave));
    print('💾 User data updated in SharedPreferences');
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
          'id': userMap['id'] ?? 'local_user_id',
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
          'qrCode': userMap['qrCode'] ?? 'QR_local_123456',
          'fingerprintData': userMap['fingerprintData'],
          'profilePicture': userMap['profilePicture'],
          'role': userMap['role'] ?? 'USER',
          'isActive': userMap['isActive'] ?? true,
          'createdAt': userMap['createdAt'] ?? DateTime.now().toIso8601String(),
          'lastLogin': userMap['lastLogin'] ?? DateTime.now().toIso8601String(),
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

  // Clear authentication data - UPDATE TO CLEAR NEW KEYS
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save device ID only (for consistency in future registrations)
    final deviceId = prefs.getString('simple_device_id');

    // Clear ALL auth and fingerprint data
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove('user_fingerprint_data');
    await prefs.remove('device_id');
    await prefs.remove('pending_fingerprint_data');

    // Restore device ID for consistent device identification
    if (deviceId != null) {
      await prefs.setString('simple_device_id', deviceId);
      print('💾 Preserved device ID for consistency: $deviceId');
    }

    _currentUser = null;
    _currentToken = null;

    print('🔄 Auth data cleared, fingerprint data removed');
  }

// Clear all fingerprint data completely - IMPROVED VERSION
  static Future<void> clearFingerprintData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove ALL fingerprint related data
      await prefs.remove('user_fingerprint_data');
      await prefs.remove('simple_device_id');
      await prefs.remove('device_id');
      await prefs.remove('pending_fingerprint_data');

      // Update current user to remove fingerprint data
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(fingerprintData: null);
        await _saveUserData(_currentUser!);
      }

      print('🗑️ Completely cleared ALL fingerprint data from local storage');
    } catch (e) {
      print('❌ Error clearing fingerprint data: ${e.toString()}');
    }
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
    await _saveUserData(updatedUser);
  }
}
