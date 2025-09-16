import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;
  final String? instructions;
  final Color? borderColor;

  const QRScannerWidget({
    super.key,
    required this.onQRScanned,
    this.instructions,
    this.borderColor,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  
  bool _isScanning = false;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startScanning();
  }

  void _setupAnimations() {
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scanAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
    
    _scanController.repeat();
  }

  void _startScanning() {
    setState(() => _isScanning = true);
    
    // Simulate scanning for demo
    _scanTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isScanning) {
        _simulateQRDetection();
      }
    });
  }

  void _simulateQRDetection() {
    // Simulate different types of QR codes for testing
    final qrTypes = [
      'PRINT_MACHINE:{"specialty":"GENERAL","location":"Lobby A"}',
      'CHECKIN:{"counter":"A","location":"Main Entrance"}',
      'SCHEDULE:{"doctorId":"123","date":"2025-01-15"}',
    ];
    
    final randomQR = qrTypes[Random().nextInt(qrTypes.length)];
    
    HapticFeedback.lightImpact();
    widget.onQRScanned(randomQR);
    
    setState(() => _isScanning = false);
    _scanTimer?.cancel();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera view simulation
        Container(
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
        ),
        
        // Scan overlay
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.borderColor ?? const Color(0xFF4ECDC4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Scanning line
                if (_isScanning)
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Positioned(
                        top: 125 + (_scanAnimation.value * 100),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                widget.borderColor ?? const Color(0xFF4ECDC4),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.borderColor ?? const Color(0xFF4ECDC4))
                                    .withOpacity(0.6),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                
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
                        color: widget.borderColor ?? const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.only(
                          topLeft: index == 0 ? const Radius.circular(12) : Radius.zero,
                          topRight: index == 1 ? const Radius.circular(12) : Radius.zero,
                          bottomLeft: index == 2 ? const Radius.circular(12) : Radius.zero,
                          bottomRight: index == 3 ? const Radius.circular(12) : Radius.zero,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        
        // Instructions
        if (widget.instructions != null)
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
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
          ),
        
        // Status indicator
        Positioned(
          top: 100,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isScanning 
                  ? const Color(0xFF2ECC71).withOpacity(0.9)
                  : Colors.grey.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isScanning) ...[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Memindai...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Arahkan ke QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}