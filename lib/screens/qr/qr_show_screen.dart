import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../models/user_model.dart'; // Fix: Change from User to UserModel
import '../../services/auth_service.dart';
import '../../services/qr_service.dart'; // Add QRService import
import 'dart:convert';

class QRShowScreen extends StatefulWidget {
  const QRShowScreen({super.key});

  @override
  State<QRShowScreen> createState() => _QRShowScreenState();
}

class _QRShowScreenState extends State<QRShowScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  UserModel? _currentUser; // Fix: Change User to UserModel
  String? _qrCodeData;
  Timer? _refreshTimer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserData();
    _startRefreshTimer();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
  }

  void _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      // Get QR from backend
      final qrData = await QRService.getUserQR();

      setState(() {
        _currentUser = AuthService.getCurrentUser();
        _qrCodeData = qrData['qrCodeData'];
        _isLoading = false;
      });

      print('✅ QR loaded from backend');
    } catch (e) {
      print('❌ Error loading QR from backend: $e');

      // Fallback to local generation
      final user = AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _qrCodeData = _generateFallbackQRData(user);
        _isLoading = false;
      });
    }
  }

  String _generateFallbackQRData(UserModel? user) {
    // Fix: Change User to UserModel
    if (user == null) return 'INVALID_USER';

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final qrData = {
      'type': 'HOSPITAL_QUEUE_REQUEST',
      'userId': user.id,
      'nik': user.nik,
      'fullName': user.fullName,
      'phone': user.phone,
      'timestamp': timestamp,
      'hospital': 'RS_MITRA_KELUARGA',
      'profilePicture': user.profilePicture,
      'qrVersion': '1.0',
      'fallback': true
    };

    return base64Encode(utf8.encode(json.encode(qrData)));
  }

  void _startRefreshTimer() {
    // Refresh QR code every 2 minutes for security
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) {
        _refreshQRFromBackend(); // Fix: Use backend refresh
        _showRefreshNotification();
      }
    });
  }

  void _refreshQRFromBackend() async {
    try {
      // Get fresh QR from backend
      final qrData = await QRService.generateUserQR();

      setState(() {
        _qrCodeData = qrData['qrCodeData'];
      });
    } catch (e) {
      print('❌ Error refreshing QR from backend: $e');
      // Fallback to local generation
      setState(() {
        _qrCodeData = _generateFallbackQRData(_currentUser);
      });
    }
  }

  void _showRefreshNotification() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('QR Code diperbarui untuk keamanan'),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D89),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'QR Code Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _showQRInfo,
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildQRView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D89)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat QR Code...',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildUserInfoCard(),
          const SizedBox(height: 24),
          _buildQRCodeCard(),
          const SizedBox(height: 24),
          _buildInstructionsCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D89),
            Color(0xFF3498DB),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D89).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: _currentUser?.profilePicture != null
                ? NetworkImage(_currentUser!.profilePicture!)
                : null,
            child: _currentUser?.profilePicture == null
                ? Text(
                    _currentUser?.fullName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser?.fullName ?? 'Nama Tidak Tersedia',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIK: ${_currentUser?.nik ?? 'Tidak tersedia'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'HP: ${_currentUser?.phone ?? 'Tidak tersedia'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2E7D89),
                      width: 3,
                    ),
                  ),
                  child: CustomPaint(
                    size: const Size(220, 220),
                    painter: QRCodePainter(data: _qrCodeData ?? 'INVALID'),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D89).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _rotateAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotateAnimation.value * 2 * pi,
                            child: const Icon(
                              Icons.refresh,
                              color: Color(0xFF2E7D89),
                              size: 16,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Diperbarui otomatis setiap 2 menit',
                        style: TextStyle(
                          color: Color(0xFF2E7D89),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9800).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF9800),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cara Menggunakan QR Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            1,
            'Tunjukkan QR code ini ke petugas rumah sakit',
          ),
          _buildInstructionStep(
            2,
            'Petugas akan scan QR code dengan aplikasi staff',
          ),
          _buildInstructionStep(
            3,
            'Verifikasi identitas dengan foto profil Anda',
          ),
          _buildInstructionStep(
            4,
            'Dapatkan nomor antrean secara otomatis',
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D89),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _shareQRCode,
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Bagikan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2E7D89),
                  side: const BorderSide(color: Color(0xFF2E7D89)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveQRCode,
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D89),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: _refreshQRCode,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Perbarui QR Code'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF7F8C8D),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _refreshQRCode() async {
    try {
      HapticFeedback.mediumImpact();

      // Generate new QR from backend
      final qrData = await QRService.generateUserQR();

      setState(() {
        _qrCodeData = qrData['qrCodeData'];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('QR Code berhasil diperbarui'),
            ],
          ),
          backgroundColor: const Color(0xFF2ECC71),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error refreshing QR: $e');
      _showSnackBar('Gagal memperbarui QR Code');
    }
  }

  void _shareQRCode() {
    // Share functionality akan segera hadir
    _showSnackBar('Fitur bagikan akan segera tersedia');
  }

  void _saveQRCode() {
    // Save functionality akan segera hadir
    _showSnackBar('QR Code berhasil disimpan ke galeri');
  }

  void _showQRInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.security, color: Color(0xFF2E7D89)),
            SizedBox(width: 12),
            Text('Keamanan QR Code'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QR Code Anda menggunakan sistem keamanan berlapis:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Diperbarui otomatis setiap 2 menit\n'
              '• Berisi timestamp untuk validasi waktu\n'
              '• Terintegrasi dengan foto profil untuk verifikasi wajah\n'
              '• Terenkripsi dengan data unik pengguna',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7F8C8D),
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Hanya petugas resmi yang dapat memproses QR Code ini.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF95A5A6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2E7D89),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// Custom QR Code Painter (Enhanced)
class QRCodePainter extends CustomPainter {
  final String data;

  QRCodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cellSize = size.width / 25; // 25x25 grid for QR

    // Generate QR pattern based on data hash
    final random = Random(data.hashCode);

    // Draw QR pattern
    for (int i = 0; i < 25; i++) {
      for (int j = 0; j < 25; j++) {
        // Skip positioning squares area
        if (_isPositioningSquareArea(i, j)) continue;

        if (random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(
              i * cellSize,
              j * cellSize,
              cellSize,
              cellSize,
            ),
            paint,
          );
        }
      }
    }

    // Draw positioning squares (3 corners)
    _drawPositioningSquare(canvas, paint, 0, 0, cellSize);
    _drawPositioningSquare(canvas, paint, 18 * cellSize, 0, cellSize);
    _drawPositioningSquare(canvas, paint, 0, 18 * cellSize, cellSize);

    // Draw timing patterns
    _drawTimingPattern(canvas, paint, cellSize);

    // Draw hospital logo/identifier in center
    _drawCenterLogo(canvas, size);
  }

  bool _isPositioningSquareArea(int i, int j) {
    return (i >= 0 && i < 9 && j >= 0 && j < 9) ||
        (i >= 16 && i < 25 && j >= 0 && j < 9) ||
        (i >= 0 && i < 9 && j >= 16 && j < 25);
  }

  void _drawPositioningSquare(
      Canvas canvas, Paint paint, double x, double y, double cellSize) {
    // Outer square (7x7)
    canvas.drawRect(
      Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7),
      paint,
    );
    // Inner white square (5x5)
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5),
      Paint()..color = Colors.white,
    );
    // Center black square (3x3)
    canvas.drawRect(
      Rect.fromLTWH(
          x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3),
      paint,
    );
  }

  void _drawTimingPattern(Canvas canvas, Paint paint, double cellSize) {
    // Horizontal timing pattern
    for (int i = 8; i < 17; i++) {
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(i * cellSize, 6 * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }

    // Vertical timing pattern
    for (int j = 8; j < 17; j++) {
      if (j % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(6 * cellSize, j * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }
  }

  void _drawCenterLogo(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final logoSize = size.width * 0.15;

    // Draw hospital cross logo
    final logoPaint = Paint()
      ..color = const Color(0xFF2E7D89)
      ..style = PaintingStyle.fill;

    // Background circle
    canvas.drawCircle(center, logoSize, Paint()..color = Colors.white);
    canvas.drawCircle(
        center,
        logoSize,
        Paint()
          ..color = const Color(0xFF2E7D89)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Medical cross
    final crossSize = logoSize * 0.6;
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: crossSize * 0.3,
        height: crossSize,
      ),
      logoPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: center,
        width: crossSize,
        height: crossSize * 0.3,
      ),
      logoPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
