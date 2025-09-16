import 'package:flutter/material.dart';
import '../../widgets/qr_scanner_widget.dart';
import '../../services/qr_service.dart';

abstract class BaseQRScannerScreen extends StatelessWidget {
  final String title;
  final String? instructions;
  final Color? themeColor;

  const BaseQRScannerScreen({
    super.key,
    required this.title,
    this.instructions,
    this.themeColor,
  });

  // Abstract methods
  void onQRScanned(String qrData, BuildContext context);
  void onScanError(String error, BuildContext context) {}
  List<Widget> buildAdditionalActions(BuildContext context) => [];

  // Handle machine QR scans
  Future<void> handleMachineQR(String qrData, BuildContext context) async {
    try {
      String action = 'UNKNOWN';
      String location = 'Hospital';

      // Determine action based on QR content
      if (qrData.startsWith('PRINT_MACHINE:')) {
        action = 'PRINT_QUEUE';
        location = 'Print Machine';
      } else if (qrData.startsWith('CHECKIN:')) {
        action = 'CHECK_IN';
        location = 'Check-in Counter';
      } else if (qrData.startsWith('SCHEDULE:')) {
        action = 'SCHEDULE_INFO';
        location = 'Information Kiosk';
      }

      if (action != 'UNKNOWN') {
        final result = await QRService.handleQRScan(
          qrData: qrData,
          action: action,
          location: location,
        );

        _showActionResult(context, result);
      } else {
        onQRScanned(qrData, context);
      }
    } catch (e) {
      onScanError('Gagal memproses QR: $e', context);
    }
  }

  void _showActionResult(BuildContext context, Map<String, dynamic> result) {
    switch (result['action']) {
      case 'PRINT_QUEUE':
        _showPrintQueueResult(context, result);
        break;
      case 'CHECK_IN':
        _showCheckInResult(context, result);
        break;
      case 'SCHEDULE_INFO':
        _showScheduleInfoResult(context, result);
        break;
    }
  }

  void _showPrintQueueResult(
      BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.print, color: Color(0xFF2ECC71)),
            SizedBox(width: 12),
            Text('Antrean Berhasil Dicetak'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F8F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Nomor Antrean Anda'),
                  const SizedBox(height: 8),
                  Text(
                    result['queueNumber'] ?? 'A001',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                  Text('Posisi: ${result['position'] ?? 1}'),
                  Text('Estimasi: ~${result['estimatedWaitTime'] ?? 15} menit'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              result['instructions'] ??
                  'Silakan tunggu nomor antrean Anda dipanggil',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to queue detail if needed
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71)),
            child: const Text('Lihat Detail',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCheckInResult(BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2ECC71)),
            SizedBox(width: 12),
            Text('Check-in Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lokasi: ${result['location'] ?? 'Hospital'}'),
            Text('Waktu: ${result['checkInTime'] ?? DateTime.now()}'),
            if (result['confirmationCode'] != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('Kode Konfirmasi'),
                    Text(
                      result['confirmationCode'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showScheduleInfoResult(
      BuildContext context, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.schedule, color: Color(0xFF3498DB)),
            SizedBox(width: 12),
            Text('Informasi Jadwal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display schedule info from result['schedule']
            Text('Jadwal berhasil dimuat'),
            // Add more schedule details here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = themeColor ?? const Color(0xFF2E7D89);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: buildAdditionalActions(context),
      ),
      body: QRScannerWidget(
        onQRScanned: (qrData) => handleMachineQR(qrData, context),
        instructions: instructions,
        borderColor: color,
      ),
    );
  }
}
