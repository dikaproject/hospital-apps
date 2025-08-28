import 'package:flutter/material.dart';
import 'qr_code_widget.dart'; // Use our custom QR widget

class QRGeneratorWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final String? title;
  final String? description;
  final VoidCallback? onShare;

  const QRGeneratorWidget({
    super.key,
    required this.data,
    this.size = 200,
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.title,
    this.description,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (description != null) ...[
            Text(
              description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: QRCodeWidget(
              data: data,
              size: size,
            ),
          ),
          if (onShare != null) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onShare,
              icon: const Icon(Icons.share),
              label: const Text('Bagikan QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D89),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
