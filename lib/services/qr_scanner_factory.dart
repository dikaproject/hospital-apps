import 'package:flutter/material.dart';
import '../screens/family/family_qr_scanner_screen.dart';

enum QRScannerType {
  family,
  queue,
  payment,
  medical,
}

class QRScannerFactory {
  static Widget createScanner({
    required QRScannerType type,
    required Function(String) onQRScanned,
    Map<String, dynamic>? additionalParams,
  }) {
    switch (type) {
      case QRScannerType.family:
        return FamilyQRScannerScreen(
          onFamilyQRScanned: onQRScanned,
        );

      case QRScannerType.queue:
        throw UnimplementedError('Queue QR scanner not implemented yet');

      case QRScannerType.payment:
        throw UnimplementedError('Payment QR scanner not implemented yet');

      case QRScannerType.medical:
        throw UnimplementedError('Medical QR scanner not implemented yet');
    }
  }

  static void navigateToScanner(
    BuildContext context, {
    required QRScannerType type,
    required Function(String) onQRScanned,
    Map<String, dynamic>? additionalParams,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => createScanner(
          type: type,
          onQRScanned: onQRScanned,
          additionalParams: additionalParams,
        ),
      ),
    );
  }
}
