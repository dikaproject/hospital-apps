import 'package:flutter/material.dart';
import '../qr/base_qr_scanner_screen.dart';

class QueueQRScannerScreen extends BaseQRScannerScreen {
  final Function(String) onQueueQRScanned;

  const QueueQRScannerScreen({
    super.key,
    required this.onQueueQRScanned,
  }) : super(
          title: 'Scan QR Antrian',
          instructions: 'Scan QR Code untuk check-in antrian rumah sakit',
          themeColor: const Color(0xFF3498DB),
        );

  @override
  void onQRScanned(String qrData, BuildContext context) {
    if (_isValidQueueQR(qrData)) {
      onQueueQRScanned(qrData);
      Navigator.pop(context);
    } else {
      onScanError('QR Code antrian tidak valid', context);
    }
  }

  @override
  void onScanError(String error, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  bool _isValidQueueQR(String qrData) {
    return qrData.startsWith('QUEUE:') || qrData.contains('hospital_id');
  }
}
