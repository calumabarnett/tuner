// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuner/src/utils/music_theory.dart';

class TunerGauge extends StatelessWidget {
  final double centsDeviation;

  const TunerGauge({super.key, required this.centsDeviation});

  @override
  Widget build(BuildContext context) {
    // Smoothed visual value
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: centsDeviation),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 320,
          height: 320,
          child: CustomPaint(
            painter: GaugePainter(
              centsDeviation: value,
            ),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: _CentsText(cents: centsDeviation),
            ),
          ),
        ],
      ),
    );
  }
}

class _CentsText extends StatelessWidget {
  final double cents;
  const _CentsText({required this.cents});

  @override
  Widget build(BuildContext context) {
    final int c = cents.round();
    final sign = c > 0 ? '+' : '';
    return Text(
      '$sign$c ct',
      style: GoogleFonts.jetBrainsMono(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double centsDeviation;
  GaugePainter({required this.centsDeviation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Reduce radius to create padding for labels (labels are outside the ring)
    // 320 width / 2 = 160. Text is ~20px high.
    // If radius is 120, we have 40px margin.
    final radius = (size.width / 2) - 40.0;

    // 1. Draw Ring (White, 0.2 opacity)
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, ringPaint);

    // 2. Tolerance Range Arc (+/- 5 cents)
    double centsToAngle(double c) {
      // Map 100 cents range (+/- 50) to 360 degrees.
      // -50 -> 270 deg (-pi/2 - pi) or actually just continuous.
      // 0 -> -pi/2 (Top)
      // Angle = -pi/2 + (c / 50.0) * pi
      return -math.pi / 2 + (c / 50.0) * math.pi;
    }

    final tolerancePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    final startAngle = centsToAngle(-MusicTheory.tuningTolerance);
    final sweepAngle = centsToAngle(MusicTheory.tuningTolerance) - startAngle;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      tolerancePaint,
    );

    // 3. Scale Ticks
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = -50; i <= 50; i += 10) {
      if (i == 0) continue; // Skip 0 (Target handled separately)
      final angle = centsToAngle(i.toDouble());
      final tickLen = (i % 25 == 0) ? 12.0 : 6.0;

      final p1 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - tickLen) * math.cos(angle),
        center.dy + (radius - tickLen) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 4. Target Marker (at 0) - Distinct notch/arc
    final targetMarkerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    // Draw distinct notch at top
    // Notch goes from radius - 12 (inside) to radius + 8 (outside)
    // Wait, previously I said radius - 12 and radius + 8.
    // If we want it at the top, dy - radius.
    // Outside: dy - radius - 8. Inside: dy - radius + 12.
    // Let's make it protrude slightly out and in.
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 8),
      Offset(center.dx, center.dy - radius + 12),
      targetMarkerPaint,
    );

    // 5. Indicator Orb
    final clampedDeviation = centsDeviation.clamp(-50.0, 50.0);
    final indicatorAngle = centsToAngle(clampedDeviation);

    final orbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    const orbRadius = 8.0;
    final orbX = center.dx + radius * math.cos(indicatorAngle);
    final orbY = center.dy + radius * math.sin(indicatorAngle);
    canvas.drawCircle(Offset(orbX, orbY), orbRadius, orbPaint);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.centsDeviation != centsDeviation;
  }
}
