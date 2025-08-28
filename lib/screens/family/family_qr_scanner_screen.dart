import 'package:flutter/material.dart';
import '../qr/base_qr_scanner_screen.dart';

class FamilyQRScannerScreen extends BaseQRScannerScreen {
  final Function(String) onFamilyQRScanned;

  const FamilyQRScannerScreen({
    super.key,
    required this.onFamilyQRScanned,
  }) : super(
          title: 'Scan QR Keluarga',
          instructions:
              'Scan QR Code dari anggota keluarga yang ingin ditambahkan',
          themeColor: const Color(0xFF9B59B6),
        );

  @override
  void onQRScanned(String qrData, BuildContext context) {
    // Validate family QR format
    if (_isValidFamilyQR(qrData)) {
      onFamilyQRScanned(qrData);
      Navigator.pop(context);
    } else {
      onScanError('QR Code bukan untuk keluarga', context);
    }
  }

  @override
  void onScanError(String error, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('QR Code Tidak Valid'),
          ],
        ),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  List<Widget> buildAdditionalActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.help_outline),
        onPressed: () => _showHelpDialog(context),
      ),
    ];
  }

  bool _isValidFamilyQR(String qrData) {
    // Implement family QR validation logic
    // For example: check if it starts with "FAMILY:" or contains specific format
    return qrData.startsWith('FAMILY:') || qrData.contains('family_id');
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cara Menggunakan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Minta anggota keluarga menampilkan QR Code mereka'),
            SizedBox(height: 8),
            Text('2. Arahkan kamera ke QR Code'),
            SizedBox(height: 8),
            Text('3. Tunggu hingga QR Code terbaca otomatis'),
            SizedBox(height: 8),
            Text('4. Masukkan kode konfirmasi yang mereka berikan'),
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
}
