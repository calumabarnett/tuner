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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: GaugePainter(
                  globalCents: value,
                  isInTune: isInTune,
                ),
                child: child,
              ),
            );
          },
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Position text relative to the ring size.
              // Since we don't know exact pixels in child without logic,
              // we can rely on Painter to draw it? Or alignment.
              // User said "above the ring/orb".
              // If we maximize the ring, "above" is outside the widget.
              // But user also said "markers inside... so as not to take up space outside".
              // Let's position the Cents text inside the ring at the top.
              Positioned(
                top: size * 0.15, // Roughly inside the top of the ring
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
    return Text(
      '$sign$c ct',
      style: GoogleFonts.jetBrainsMono(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double globalCents;
  final bool isInTune;

  GaugePainter({required this.globalCents, required this.isInTune});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Maximize ring. Leave small padding for stroke width.
    final radius = (size.width / 2) - 10.0;

    const mintGreen = Color(0xFF00D2A1);
    // Indigo background color for stroke cutout effect
    const indigoBg = Color(0xFF4D5BCE);

    // Decode globalCents
    final nearestNoteCents = (globalCents / 100.0).round() * 100.0;
    final centsDeviation = globalCents - nearestNoteCents;

    // 1. Draw Ring (White, 100% opacity)
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, ringPaint);

    // 2. Tolerance Range Arc (Always Green)
    // +/- 5 cents at the top
    double centsToAngle(double c) {
      // 0 -> -pi/2
      return -math.pi / 2 + (c / 50.0) * math.pi;
    }

    final tolerancePaint = Paint()
      ..color = mintGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 // Slightly thicker than ring
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
          style: GoogleFonts.manrope(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
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

    // 5. Indicator Orb
    final indicatorAngle = centsToAngle(centsDeviation);

    final orbPaint = Paint()
      ..color = isInTune ? mintGreen : Colors.white
      ..style = PaintingStyle.fill;

    final orbStrokePaint = Paint()
      ..color = indigoBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Cutout border

    const orbRadius = 10.0; // Slightly larger orb
    final orbX = center.dx + radius * math.cos(indicatorAngle);
    final orbY = center.dy + radius * math.sin(indicatorAngle);
    final orbCenter = Offset(orbX, orbY);

    // Draw stroke (background color) then fill
    // Actually, to make it "stand out above the ring", we need the stroke to be the background color?
    // User said "add an indigo stroke to the orb so it stands out above the now 100% opacity ring".
    // If the ring is white, and orb is white, they merge.
    // Indigo stroke creates separation.

    // Draw stroke first? No, stroke is border.
    canvas.drawCircle(orbCenter, orbRadius, orbPaint);
    canvas.drawCircle(orbCenter, orbRadius, orbStrokePaint);
  }

  @override
  bool shouldRepaint(covariant GaugePainter oldDelegate) {
    return oldDelegate.globalCents != globalCents || oldDelegate.isInTune != isInTune;
  }
}
