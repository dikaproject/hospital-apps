import 'package:flutter/material.dart';
import '../screens/qr/qr_show_screen.dart';

class QRScannerFactory {
  
  // Main entry point untuk QR functionality
  static Widget createQRScreen({
    String? purpose, // 'queue', 'checkin', 'general'
  }) {
    // Sekarang hanya return show QR screen
    return const QRShowScreen();
  }

  // For future staff/admin QR scanner
  static Widget createStaffQRScanner() {
    // This will be implemented for staff side
    throw UnimplementedError('Staff QR Scanner will be implemented in admin panel');
  }
}