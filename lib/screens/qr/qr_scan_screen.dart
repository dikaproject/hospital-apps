import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../queue/queue_detail_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  bool _isScanning = false;
  bool _isCameraReady = false;
  bool _showQRCode = false;
  String? _scannedData;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeCamera();
  }

  void _setupAnimations() {
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanController.repeat();
    _pulseController.repeat(reverse: true);
  }

  void _initializeCamera() {
    // Simulate camera initialization
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isCameraReady = true);
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCameraView(),
            _buildTopBar(),
            _buildScanOverlay(),
            if (_showQRCode) _buildMyQROverlay(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A1A1A),
            Color(0xFF2C2C2C),
            Color(0xFF1A1A1A),
          ],
        ),
      ),
      child: _isCameraReady
          ? Stack(
              children: [
                // Simulate camera feed with pattern
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                  ),
                  child: CustomPaint(
                    painter: CameraFeedPainter(),
                  ),
                ),
                // Scanning line animation
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: MediaQuery.of(context).size.height * 0.3 +
                            (_scanAnimation.value * 100),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                Color(0xFF4ECDC4),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ECDC4).withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
            ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            const Spacer(),
            const Text(
              'Scan QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _toggleFlash,
              icon: const Icon(Icons.flash_off, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF4ECDC4),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            ...List.generate(4, (index) {
              return Positioned(
                top: index < 2 ? 0 : null,
                bottom: index >= 2 ? 0 : null,
                left: index % 2 == 0 ? 0 : null,
                right: index % 2 == 1 ? 0 : null,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4),
                    borderRadius: BorderRadius.only(
                      topLeft:
                          index == 0 ? const Radius.circular(12) : Radius.zero,
                      topRight:
                          index == 1 ? const Radius.circular(12) : Radius.zero,
                      bottomLeft:
                          index == 2 ? const Radius.circular(12) : Radius.zero,
                      bottomRight:
                          index == 3 ? const Radius.circular(12) : Radius.zero,
                    ),
                  ),
                ),
              );
            }),
            // Center guide
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        color: Color(0xFF4ECDC4),
                        size: 30,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyQROverlay() {
    final user = AuthService.getCurrentUser();

    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'QR Code Saya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => setState(() => _showQRCode = false),
                    icon: const Icon(Icons.close, color: Color(0xFF7F8C8D)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: QRCodePainter(
                      data: user?.qrCode ?? 'USER_QR_${user?.id}'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'Pasien HospitalLink',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'NIK: ${user?.nik ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8C8D),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareQRCode,
                      icon: const Icon(Icons.share, size: 16),
                      label: const Text('Bagikan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(color: Color(0xFF3498DB)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveQRCode,
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Simpan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D89),
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_isScanning && _isCameraReady) ...[
              const Text(
                'Arahkan kamera ke QR Code rumah sakit',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ] else if (_isScanning) ...[
              const Text(
                'Memindai QR Code...',
                style: TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: Icons.photo_library,
                  label: 'Galeri',
                  onTap: _pickFromGallery,
                ),
                _buildControlButton(
                  icon: _isScanning ? Icons.stop : Icons.play_arrow,
                  label: _isScanning ? 'Stop' : 'Scan',
                  onTap: _toggleScan,
                  isPrimary: true,
                ),
                _buildControlButton(
                  icon: Icons.qr_code,
                  label: 'QR Saya',
                  onTap: () => setState(() => _showQRCode = true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isPrimary
                  ? const Color(0xFF4ECDC4)
                  : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              border: isPrimary
                  ? null
                  : Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(
              icon,
              color: isPrimary ? Colors.white : Colors.white70,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isPrimary ? const Color(0xFF4ECDC4) : Colors.white70,
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleScan() {
    setState(() => _isScanning = !_isScanning);

    if (_isScanning) {
      // Simulate QR detection after 3 seconds
      _scanTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isScanning) {
          _simulateQRDetection();
        }
      });
    } else {
      _scanTimer?.cancel();
    }
  }

  void _simulateQRDetection() {
    // Simulate detecting hospital QR code
    final hospitalQRData =
        'HOSPITAL_RS_MITRA_KELUARGA_CHECKIN_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _isScanning = false;
      _scannedData = hospitalQRData;
    });

    HapticFeedback.lightImpact();
    _showCheckInDialog(hospitalQRData);
  }

  void _showCheckInDialog(String qrData) {
    final user = AuthService.getCurrentUser();
    final confirmationCode = _generateConfirmationCode();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('QR Terdeteksi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RS Mitra Keluarga',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Check-in Counter A',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pasien: ${user?.fullName ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Text(
                    'NIK: ${user?.nik ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFC107)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Kode Konfirmasi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF856404),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    confirmationCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF856404),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tunjukkan kode ini ke petugas',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF856404),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () => _processCheckIn(confirmationCode),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _processCheckIn(String confirmationCode) {
    Navigator.pop(context); // Close dialog

    // Show processing
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
        ),
      ),
    );

    // Simulate processing
    Timer(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      _showCheckInSuccess(confirmationCode);
    });
  }

  void _showCheckInSuccess(String confirmationCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Check-in Berhasil!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anda telah berhasil check-in di RS Mitra Keluarga',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF7F8C8D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Nomor Antrean',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'A-23',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Estimasi: ~20 menit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7F8C8D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Tutup'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _navigateToQueueDetail();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lihat Detail'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToQueueDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QueueDetailScreen(
          queueNumber: 'A-23',
          isFromAutoQueue: false,
        ),
      ),
    );
  }

  String _generateConfirmationCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
          6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _toggleFlash() => _showSnackBar('Flash toggle akan segera hadir!');
  void _pickFromGallery() =>
      _showSnackBar('Pilih dari galeri akan segera hadir!');
  void _shareQRCode() => _showSnackBar('Bagikan QR akan segera hadir!');
  void _saveQRCode() => _showSnackBar('QR berhasil disimpan ke galeri!');

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

// Custom Painters
class CameraFeedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 1;

    // Draw grid pattern to simulate camera feed
    final spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint..color = Colors.grey[700]!,
      );
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint..color = Colors.grey[700]!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRCodePainter extends CustomPainter {
  final String data;

  QRCodePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final cellSize = size.width / 25; // 25x25 grid for QR

    // Generate simple QR pattern (simplified for demo)
    final random = Random(data.hashCode);
    for (int i = 0; i < 25; i++) {
      for (int j = 0; j < 25; j++) {
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

    // Draw positioning squares
    _drawPositioningSquare(canvas, paint, 0, 0, cellSize);
    _drawPositioningSquare(canvas, paint, 18 * cellSize, 0, cellSize);
    _drawPositioningSquare(canvas, paint, 0, 18 * cellSize, cellSize);
  }

  void _drawPositioningSquare(
      Canvas canvas, Paint paint, double x, double y, double cellSize) {
    // Outer square
    canvas.drawRect(
      Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7),
      paint,
    );
    // Inner white square
    canvas.drawRect(
      Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5),
      Paint()..color = Colors.white,
    );
    // Center black square
    canvas.drawRect(
      Rect.fromLTWH(
          x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
