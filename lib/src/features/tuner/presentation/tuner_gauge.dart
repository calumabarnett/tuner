// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuner/src/utils/music_theory.dart';

class TunerGauge extends StatelessWidget {
  final MusicalNote note;

  const TunerGauge({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    // We animate on "global cents" to handle wrap-around correctly.
    // globalCents = midiNumber * 100 + centsDeviation.
    // For example:
    // A4 (69) + 45 cents = 6945.
    // A#4 (70) - 45 cents = 6955.
    // The difference is 10 cents, so animation will be smooth and short (clockwise).

    final double globalCents = note.midiNumber * 100 + note.centsDeviation;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: globalCents, end: globalCents), // begin is updated on first build only?
      // Actually, if we want continuity, we rely on TweenAnimationBuilder's implicit state.
      // If we pass a new 'end', it animates from current value to new 'end'.
      // The 'begin' is only used if there is no previous value.
      // However, if we reconstruct the widget tree (which might happen if parent rebuilds),
      // we need to make sure state is preserved. Parent uses const constructor?
      // TunerScreen rebuilds often. If TunerGauge is in the tree, Flutter preserves state if key is same.
      // We don't provide a key, so element type match is enough.
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 320,
          height: 320,
          child: CustomPaint(
            painter: GaugePainter(
              globalCents: value,
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
              child: _CentsText(cents: note.centsDeviation),
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
  final double globalCents;
  GaugePainter({required this.globalCents});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 40.0;

    // Decode globalCents to local deviation relative to the nearest 100.
    // E.g. 6945 -> 45. 6955 -> -45?
    // 6955 / 100 = 69.55. Round -> 70.
    // 6955 - 7000 = -45.
    // 6945 / 100 = 69.45. Round -> 69.
    // 6945 - 6900 = +45.
    final nearestNoteCents = (globalCents / 100.0).round() * 100.0;
    final centsDeviation = globalCents - nearestNoteCents;

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
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 8),
      Offset(center.dx, center.dy - radius + 12),
      targetMarkerPaint,
    );

    // 5. Indicator Orb
    // We use the decoded centsDeviation for position on the ring.
    // Does it need clamping?
    // If globalCents is animating 6945 -> 6955.
    // It passes through 6950 which is +50 deviation relative to 69, or -50 relative to 70.
    // 6950 -> Round is 70. 6950 - 7000 = -50.
    // 6949 -> Round is 69. 6949 - 6900 = +49.
    // So visual jump from +49 to -50.
    // +49 angle: -pi/2 + (49/50)pi = ~pi/2 (bottom left)
    // -50 angle: -pi/2 + (-50/50)pi = -3pi/2 (bottom right? wait)
    // Let's recheck angle mapping.
    // 0 -> -pi/2 (Top)
    // +50 -> -pi/2 + pi = pi/2 (Bottom)
    // -50 -> -pi/2 - pi = -3pi/2.
    // -3pi/2 is equivalent to pi/2 in modulo 2pi.
    // So visually +50 and -50 meet at the bottom.
    // So the jump from +49 to -50 is just 1 unit of movement?
    // +49 -> pi/2 - epsilon.
    // -50 -> -3pi/2.
    // pi/2 and -3pi/2 are the same point on circle.
    // So the jump is visual continuity!
    // Perfect.

    // We clamp to -50/50 just in case floating point errors or overshoots make it weird?
    // Actually we shouldn't clamp strictly if we want it to wrap.
    // But centsToAngle works linearly.
    // If centsDeviation is -50, angle is -3pi/2.
    // If centsDeviation is +50, angle is pi/2.
    // They are same visual spot.

    final indicatorAngle = centsToAngle(centsDeviation);

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
    return oldDelegate.globalCents != globalCents;
  }
}
