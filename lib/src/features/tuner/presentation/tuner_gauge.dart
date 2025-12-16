import 'dart:math' as math;

import 'package:flutter/material.dart';

class TunerGauge extends StatelessWidget {
  final double centsDeviation;

  const TunerGauge({super.key, required this.centsDeviation});

  @override
  Widget build(BuildContext context) {
    // Clamp deviation to -50 to +50 for visualization
    final double clampedDeviation = centsDeviation.clamp(-50.0, 50.0);

    // Normalized position from -1.0 to 1.0
    final double normalized = clampedDeviation / 50.0;

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: CustomPaint(
        painter: GaugePainter(normalizedDeviation: normalized),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double normalizedDeviation; // -1.0 to 1.0

  GaugePainter({required this.normalizedDeviation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Draw Arc Background
    paint.color = Colors.white10;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Draw Center Marker
    paint.color = Colors.white24;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 10),
      Offset(center.dx, center.dy - radius + 20),
      paint,
    );

    // Draw Needle
    // Angle: -PI/2 (top) corresponds to 0 deviation.
    // -PI (left) is -50 cents, 0 (right) is +50 cents.
    // So angle = -PI/2 + (normalized * PI/2)
    final angle = -math.pi / 2 + (normalizedDeviation * (math.pi / 2));

    final needlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..color = (normalizedDeviation.abs() < 0.1)
          ? const Color(0xFF03DAC6) // Teal for in-tune
          : const Color(0xFFCF6679); // Red for out-of-tune

    final needleLength = radius * 0.9;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(angle),
      center.dy + needleLength * math.sin(angle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw Pivot
    canvas.drawCircle(center, 8, needlePaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.normalizedDeviation != normalizedDeviation;
  }
}
