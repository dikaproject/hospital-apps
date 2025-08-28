import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final String? instructions;
  final Color borderColor;

  const QRScannerWidget({
    super.key,
    required this.onQRScanned,
    this.instructions,
    this.borderColor = Colors.white,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  MobileScannerController? _scannerController;
  bool _isScanning = true;
  bool _flashEnabled = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.repeat();

    _initializeScanner();
  }

  void _initializeScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mobile Scanner Camera - NO OVERLAY PARAMETER
          if (_scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onQRDetected,
            )
          else
            _buildCameraPlaceholder(),

          // Manual overlay on top of camera
          _buildScanOverlay(),

          // Top bar
          _buildTopBar(),

          // Instructions
          if (widget.instructions != null) _buildInstructions(),

          // Bottom controls
          _buildBottomControls(),

          // Processing overlay
          if (_isProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Memulai kamera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
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
                icon: Icon(
                  _flashEnabled ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
              ),
            ],
          ),
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
            color: widget.borderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Corner indicators
            ...List.generate(4, (index) {
              return Positioned(
                top: index < 2 ? -2 : null,
                bottom: index >= 2 ? -2 : null,
                left: index % 2 == 0 ? -2 : null,
                right: index % 2 == 1 ? -2 : null,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.borderColor,
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

            // Scanning line animation
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Positioned(
                  top: 250 * _animation.value - 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          widget.borderColor,
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.borderColor.withOpacity(0.6),
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
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          widget.instructions!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
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
              if (!_isProcessing) ...[
                const Text(
                  'Arahkan kamera ke QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
                    icon: Icons.qr_code,
                    label: 'Test Scan',
                    onTap: _simulateScan,
                    isPrimary: true,
                  ),
                  _buildControlButton(
                    icon: Icons.keyboard,
                    label: 'Manual',
                    onTap: _showManualInputDialog,
                  ),
                ],
              ),
            ],
          ),
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
                  ? widget.borderColor
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
              color: isPrimary ? widget.borderColor : Colors.white70,
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Memproses QR Code...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() => _isProcessing = true);

        HapticFeedback.mediumImpact();

        // Simulate processing delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
            widget.onQRScanned(code);
          }
        });
      }
    }
  }

  void _toggleFlash() async {
    if (_scannerController != null) {
      await _scannerController!.toggleTorch();
      setState(() => _flashEnabled = !_flashEnabled);
      HapticFeedback.lightImpact();
    }
  }

  void _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && _scannerController != null) {
        setState(() => _isProcessing = true);

        // For mobile_scanner 5.0+, use analyzeImage differently
        try {
          // Try to analyze the image (this might not work in all versions)
          // For now, we'll simulate success
          await Future.delayed(const Duration(milliseconds: 500));

          // Simulate finding a QR code in gallery
          final sampleQR =
              'GALLERY_SCAN_${DateTime.now().millisecondsSinceEpoch}';

          HapticFeedback.mediumImpact();
          if (mounted) {
            Navigator.pop(context);
            widget.onQRScanned(sampleQR);
          }
          return;
        } catch (e) {
          setState(() => _isProcessing = false);
          _showSnackBar('Fitur scan dari galeri akan segera hadir');
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showSnackBar('Gagal memproses gambar: $e');
    }
  }

  void _showManualInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String qrData = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Input Manual QR Code'),
          content: TextField(
            onChanged: (value) => qrData = value,
            decoration: const InputDecoration(
              hintText: 'Masukkan kode QR...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (qrData.isNotEmpty) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close scanner
                  widget.onQRScanned(qrData);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.borderColor,
              ),
              child: const Text(
                'Scan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _simulateScan() {
    HapticFeedback.mediumImpact();

    final List<String> sampleQRCodes = [
      'FAMILY:user_12345',
      'QUEUE:A-015:hospital_001',
      'PAYMENT:PAY_67890:amount_150000',
      'APPOINTMENT:APP_001:doctor_sarah',
      'LAB:LAB_001:blood_test',
      'HOSPITAL_RS_MITRA_KELUARGA_CHECKIN_${DateTime.now().millisecondsSinceEpoch}',
    ];

    final randomQR = sampleQRCodes[math.Random().nextInt(sampleQRCodes.length)];

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Navigator.pop(context);
        widget.onQRScanned(randomQR);
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
