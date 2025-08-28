import 'package:flutter/material.dart';
import '../../widgets/qr_scanner_widget.dart';

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

  // Abstract methods untuk di-implement oleh child classes
  void onQRScanned(String qrData, BuildContext context);
  void onScanError(String error, BuildContext context) {}
  List<Widget> buildAdditionalActions(BuildContext context) => [];

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
        onQRScanned: (qrData) => onQRScanned(qrData, context),
        instructions: instructions,
        borderColor: color,
      ),
    );
  }
}
