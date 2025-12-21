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
    final double globalCents = note.midiNumber * 100 + note.centsDeviation;
    final bool isInTune = note.centsDeviation.abs() < MusicTheory.tuningTolerance;
    const mintGreen = Color(0xFF00D2A1);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use smallest dimension to ensure circle fits
        final double size = math.min(constraints.maxWidth, constraints.maxHeight);

        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: globalCents, end: globalCents),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return SizedBox(
              width: size,
              height: size,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // 1. Static Background (Ring, Ticks, Labels)
                  // Wrapped in RepaintBoundary to cache the expensive painting
                  // of ticks and text labels.
                  const RepaintBoundary(
                    child: CustomPaint(
                      painter: StaticGaugePainter(),
                    ),
                  ),
                  // 2. Dynamic Foreground (Orb)
                  CustomPaint(
                    painter: GaugeIndicatorPainter(
                      globalCents: value,
                      isInTune: isInTune,
                    ),
                  ),
                  // 3. Child (Text) - Passed from outside builder
                  if (child != null) child,
                ],
              ),
            );
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: size * 0.15,
                child: _CentsText(
                  cents: note.centsDeviation,
                  color: isInTune ? mintGreen : Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _CentsText extends StatelessWidget {
  final double cents;
  final Color color;
  const _CentsText({required this.cents, required this.color});

  @override
  Widget build(BuildContext context) {
    final int c = cents.round();
    final sign = c > 0 ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        '$sign$c ct',
        style: GoogleFonts.jetBrainsMono(
          color: color,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Paints the static elements of the gauge (Ring, Ticks, Tolerance Arc).
/// This painter should be cached via RepaintBoundary.
class StaticGaugePainter extends CustomPainter {
  const StaticGaugePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Maximize ring. Leave small padding for stroke width.
    final radius = (size.width / 2) - 10.0;
    const mintGreen = Color(0xFF00D2A1);

    // 1. Draw Ring (White, 100% opacity)
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, ringPaint);

    // 2. Tolerance Range Arc (Always Green)
    double centsToAngle(double c) {
      // 0 -> -pi/2
      return -math.pi / 2 + (c / 50.0) * math.pi;
    }

    final tolerancePaint = Paint()
      ..color = mintGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0 // Exactly same as ring
      ..strokeCap = StrokeCap.butt;

    final startAngle = centsToAngle(-MusicTheory.tuningTolerance);
    final sweepAngle = centsToAngle(MusicTheory.tuningTolerance) - startAngle;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      tolerancePaint,
    );

    // 3. Scale Ticks (Every 5 cents)
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = -50; i <= 50; i += 5) {
      if (i == 0) continue; // Target handled separately

      final angle = centsToAngle(i.toDouble());
      // Major ticks at 25?
      final isMajor = (i.abs() == 25);
      final tickLen = isMajor ? 16.0 : 8.0;

      final p1 = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - tickLen) * math.cos(angle),
        center.dy + (radius - tickLen) * math.sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);

      // Labels at +/- 25 inside
      if (isMajor) {
        final label = i > 0 ? '+25' : '-25';
        textPainter.text = TextSpan(
          text: label,
          style: GoogleFonts.sora( // Sora
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w300, // Lighter variant
          ),
        );
        textPainter.layout();

        // Position inside, past the tick
        final labelDist = radius - tickLen - 12;
        final lx = center.dx + labelDist * math.cos(angle) - textPainter.width / 2;
        final ly = center.dy + labelDist * math.sin(angle) - textPainter.height / 2;
        textPainter.paint(canvas, Offset(lx, ly));
      }
    }

    // 4. Target Marker (at 0) - Notch
    final targetMarkerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    // Notch protruding slightly in and out
    canvas.drawLine(
      Offset(center.dx, center.dy - radius - 8),
      Offset(center.dx, center.dy - radius + 12),
      targetMarkerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant StaticGaugePainter oldDelegate) {
    return false; // Static elements never change
  }
}

/// Paints the dynamic indicator orb.
class GaugeIndicatorPainter extends CustomPainter {
  final double globalCents;
  final bool isInTune;

  GaugeIndicatorPainter({required this.globalCents, required this.isInTune});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10.0;
    const mintGreen = Color(0xFF00D2A1);

    // Indigo background colors for stroke cutout effect
    const standardBg = Color(0xFF4D5BCE);
    const successBg = Color(0xFF6874E8);
    // Use the correct background color for the stroke so it blends in
    final strokeColor = isInTune ? successBg : standardBg;

    // Decode globalCents
    final nearestNoteCents = (globalCents / 100.0).round() * 100.0;
    final centsDeviation = globalCents - nearestNoteCents;

    double centsToAngle(double c) {
      return -math.pi / 2 + (c / 50.0) * math.pi;
    }

    // 5. Indicator Orb
    final indicatorAngle = centsToAngle(centsDeviation);

    final orbPaint = Paint()
      ..color = isInTune ? mintGreen : Colors.white
      ..style = PaintingStyle.fill;

    final orbStrokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Cutout border

    const orbRadius = 14.0; // Increased size
    final orbX = center.dx + radius * math.cos(indicatorAngle);
    final orbY = center.dy + radius * math.sin(indicatorAngle);
    final orbCenter = Offset(orbX, orbY);

    canvas.drawCircle(orbCenter, orbRadius, orbPaint);
    canvas.drawCircle(orbCenter, orbRadius, orbStrokePaint);
  }

  @override
  bool shouldRepaint(covariant GaugeIndicatorPainter oldDelegate) {
    return oldDelegate.globalCents != globalCents || oldDelegate.isInTune != isInTune;
  }
}
