import 'dart:math' as math;
import 'package:flutter/material.dart';

enum KodaShape { circle, square, wave }

class ShapePainter extends CustomPainter {
  final KodaShape shape;
  final Color color;

  ShapePainter({required this.shape, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    switch (shape) {
      case KodaShape.circle:
        // A large circle in the bottom right
        final center = Offset(size.width * 0.9, size.height * 0.8);
        final radius = size.height * 0.7;
        canvas.drawCircle(center, radius, paint);
        break;
      case KodaShape.square:
        // A rotated square in the bottom right
        final center = Offset(size.width * 0.9, size.height * 0.8);
        final side = size.height * 1.0;
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(math.pi / 5); // Slight rotation
        canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: side, height: side),
            paint);
        canvas.restore();
        break;
      case KodaShape.wave:
        // A wave/organic shape in the bottom right
        final path = Path();
        path.moveTo(size.width * 0.3, size.height);
        path.quadraticBezierTo(
          size.width * 0.6, size.height * 0.4,
          size.width, size.height * 0.5,
        );
        path.lineTo(size.width, size.height);
        path.close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
