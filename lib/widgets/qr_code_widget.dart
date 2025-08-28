import 'package:flutter/material.dart';
import 'dart:math';

class QRCodeWidget extends StatelessWidget {
  final String data;
  final double size;

  const QRCodeWidget({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: QRCodePainter(data: data),
    );
  }
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
