import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/http_service.dart';
import '../auth/auth_screen.dart';
import 'edit_profile_screen.dart';
import 'change_email_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkBiometric();
  }

  void _loadUserData() {
    setState(() {
      _currentUser = AuthService.getCurrentUser();
    });
  }

  Future<void> _checkBiometric() async {
    final isAvailable = await AuthService.isBiometricAvailable();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _registerFingerprint() async {
    if (!_isBiometricAvailable) {
      _showErrorSnackBar('Biometric tidak tersedia pada perangkat ini');
      return;
    }

    // Check if user is logged in
    if (_currentUser == null) {
      _showErrorSnackBar('User tidak ditemukan. Silakan login ulang.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔄 Current user: ${_currentUser?.email}');
      print('🔄 Token exists: ${AuthService.getCurrentToken() != null}');

      // Use the improved AuthService method
      final fingerprintData = await AuthService.registerFingerprint();

      if (fingerprintData != null) {
        // Refresh user data from server
        await _refreshUserData();

        _showSuccessSnackBar('Fingerprint berhasil didaftarkan!');
        _loadUserData(); // Refresh UI
      } else {
        _showErrorSnackBar('Registrasi fingerprint dibatalkan');
      }
    } catch (e) {
      print('❌ Settings fingerprint registration error: ${e.toString()}');

      if (e.toString().contains('User not logged in')) {
        _showErrorSnackBar('Sesi login berakhir. Silakan login ulang.');

        // Redirect to login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      } else {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showQRCode() {
    if (_currentUser?.qrCode == null) {
      _showErrorSnackBar('QR Code tidak tersedia');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'QR Code Anda',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: QrImageView(
                    data: _currentUser!.qrCode!,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tunjukkan QR code ini untuk check-in',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _currentUser!.qrCode!));
                        Navigator.of(context).pop();
                        _showSuccessSnackBar('QR Code disalin ke clipboard');
                      },
                      child: const Text('Salin'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _refreshUserData() async {
    try {
      // Refresh dari server
      final token = AuthService.getCurrentToken();
      if (token != null) {
        final response =
            await HttpService.get('/api/users/profile', token: token);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          if (responseData['success'] == true) {
            final updatedUser =
                UserModel.fromApiResponse(responseData['data']['user']);

            // Update local storage
            await AuthService.updateLocalUser(updatedUser);

            // Update UI
            setState(() {
              _currentUser = updatedUser;
            });
          }
        }
      }
    } catch (e) {
      print('Error refreshing user data: $e');
      // Fallback: load from local storage
      _loadUserData();
    }
  }

  Future<void> _removeFingerprint() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Fingerprint'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus fingerprint? Anda harus login dengan NIK dan password.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              setState(() => _isLoading = true);

              try {
                // Call backend to remove fingerprint
                final token = AuthService.getCurrentToken();
                if (token != null) {
                  print('🗑️ Attempting to remove fingerprint from server...');

                  final response = await HttpService.delete(
                    '/api/users/remove-fingerprint',
                    token: token,
                  );

                  print(
                      '📥 Remove fingerprint response: ${response.statusCode} - ${response.body}');

                  if (response.statusCode == 200) {
                    final responseData = json.decode(response.body);
                    if (responseData['success'] == true) {
                      // Clear ALL local fingerprint data
                      await AuthService.clearFingerprintData();

                      print(
                          '✅ Fingerprint removed from server and local storage');

                      // Refresh user data from server
                      await _refreshUserData();

                      _showSuccessSnackBar('Fingerprint berhasil dihapus');
                      _loadUserData(); // Refresh UI
                    } else {
                      throw Exception(responseData['message'] ??
                          'Failed to remove fingerprint');
                    }
                  } else {
                    final errorData = json.decode(response.body);
                    throw Exception(
                        errorData['message'] ?? 'Failed to remove fingerprint');
                  }
                } else {
                  throw Exception('Authentication token not found');
                }
              } catch (e) {
                print('❌ Remove fingerprint error: ${e.toString()}');
                _showErrorSnackBar('Error: ${e.toString()}');
              } finally {
                setState(() => _isLoading = false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Info Card
                  _buildUserInfoCard(),
                  const SizedBox(height: 24),

                  // Account Settings
                  _buildSectionCard(
                    'Akun',
                    [
                      _buildSettingsTile(
                        icon: Icons.person,
                        title: 'Edit Profile',
                        subtitle: 'Ubah alamat, foto, dan data lainnya',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        ).then((_) => _loadUserData()),
                      ),
                      _buildSettingsTile(
                        icon: Icons.email,
                        title: 'Ubah Email',
                        subtitle: _currentUser!.email,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangeEmailScreen(),
                          ),
                        ).then((result) {
                          // Refresh user data setelah kembali dari change email
                          if (result == true) {
                            _refreshUserData();
                          }
                        }),
                      ),
                      _buildSettingsTile(
                        icon: Icons.lock,
                        title: 'Ubah Password',
                        subtitle: 'Perbarui kata sandi Anda',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Security Settings
                  _buildSectionCard(
                    'Keamanan',
                    [
                      _buildSettingsTile(
                        icon: Icons.fingerprint,
                        title: 'Fingerprint',
                        subtitle: _currentUser!.fingerprintData != null
                            ? 'Fingerprint terdaftar'
                            : 'Daftarkan fingerprint',
                        trailing: _currentUser!.fingerprintData != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _removeFingerprint,
                                    child: const Text('Hapus',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              )
                            : null,
                        onTap: _currentUser!.fingerprintData == null &&
                                _isBiometricAvailable
                            ? _registerFingerprint
                            : null,
                        enabled: _isBiometricAvailable,
                      ),
                      _buildSettingsTile(
                        icon: Icons.qr_code,
                        title: 'QR Code',
                        subtitle: 'Lihat QR code untuk check-in',
                        onTap: _showQRCode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // App Info
                  _buildSectionCard(
                    'Aplikasi',
                    [
                      _buildSettingsTile(
                        icon: Icons.info,
                        title: 'Tentang Aplikasi',
                        subtitle: 'HospitalLink v1.0.0',
                        onTap: () => _showAboutApp(),
                      ),
                      _buildSettingsTile(
                        icon: Icons.help,
                        title: 'Bantuan',
                        subtitle: 'FAQ dan dukungan',
                        onTap: () => _showHelp(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              _currentUser!.fullName.isNotEmpty
                  ? _currentUser!.fullName[0].toUpperCase()
                  : 'U',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser!.fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentUser!.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (_currentUser!.nik != null) ...[
            const SizedBox(height: 4),
            Text(
              'NIK: ${_currentUser!.nik}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: enabled ? Colors.blue.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: enabled ? Colors.blue.shade700 : Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: enabled ? Colors.black : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: enabled
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color:
                        enabled ? Colors.grey.shade400 : Colors.grey.shade300,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang HospitalLink'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HospitalLink v1.0.0'),
            SizedBox(height: 8),
            Text(
              'Aplikasi terintegrasi untuk layanan kesehatan yang memudahkan pasien dalam mengakses berbagai fasilitas rumah sakit.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              '© 2025 HospitalLink Team',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bantuan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Butuh bantuan?'),
            SizedBox(height: 8),
            Text(
              'Hubungi customer service kami:\n'
              '📞 (021) 1234-5678\n'
              '📧 support@hospitallink.id\n'
              '⏰ Senin-Jumat 08:00-17:00',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
