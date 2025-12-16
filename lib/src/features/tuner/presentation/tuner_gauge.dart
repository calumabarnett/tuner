// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tuner/src/utils/music_theory.dart';

class TunerGauge extends StatelessWidget {
  final double centsDeviation;

  const TunerGauge({super.key, required this.centsDeviation});

  @override
  Widget build(BuildContext context) {
    // Use unified tolerance
    final bool isFlat = centsDeviation < -MusicTheory.tuningTolerance;
    final bool isSharp = centsDeviation > MusicTheory.tuningTolerance;
    final bool isInTune = !isFlat && !isSharp;

    final int cents = centsDeviation.round();
    final String centsText = '${cents > 0 ? "+" : ""}$cents ct';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // LED Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LedIndicator(
              isActive: isFlat,
              color: const Color(0xFFCF6679), // Red-ish
              label: '♭',
            ),
            _LedIndicator(
              isActive: isInTune,
              color: const Color(0xFF03DAC6), // Teal/Green-ish
              label: '●',
            ),
            _LedIndicator(
              isActive: isSharp,
              color: const Color(0xFFCF6679),
              label: '♯',
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Gauge Canvas
        SizedBox(
          height: 120,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: centsDeviation),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CustomPaint(
                      painter: KorgGaugePainter(
                        centsDeviation: value,
                        theme: Theme.of(context),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  centsText,
                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LedIndicator extends StatelessWidget {
  final bool isActive;
  final Color color;
  final String label;

  const _LedIndicator({
    required this.isActive,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: const [],
            border: Border.all(
              color: isActive ? color : color.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class KorgGaugePainter extends CustomPainter {
  final double centsDeviation;
  final ThemeData theme;

  KorgGaugePainter({required this.centsDeviation, required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    // Pivot is virtual, located far below the component to create a flat arc.
    final pivotY = size.height * 2.5;
    final radius = pivotY - 20; // Top padding

    // Scale range: +/- 50 cents
    // Visual Angle range: +/- 40 degrees
    const maxCents = 50.0;
    const maxAngleDeg = 40.0;

    double centsToRad(double cents) {
      final clamped = cents.clamp(-maxCents, maxCents);
      return (clamped / maxCents) * (maxAngleDeg * math.pi / 180);
    }

    final paint = Paint()
      ..color = theme.textTheme.bodyLarge?.color?.withOpacity(0.5) ?? Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw Tolerance Range Indicator
    // Highlight the range [-tuningTolerance, +tuningTolerance]
    final tolerancePaint = Paint()
      ..color = theme.colorScheme.secondary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.butt;

    // Angle mapping: 0 deviation is UP (-PI/2 in drawArc).
    // Positive deviation is RIGHT (clockwise).
    final startAngle = -math.pi / 2 + centsToRad(-MusicTheory.tuningTolerance);
    final sweepAngle = centsToRad(MusicTheory.tuningTolerance) - centsToRad(-MusicTheory.tuningTolerance);

    // Draw the arc centered roughly on the ticks
    final arcRect = Rect.fromCircle(center: Offset(centerX, pivotY), radius: radius - 8);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, tolerancePaint);

    // Draw Ticks
    for (int c = -50; c <= 50; c += 10) {
      final theta = centsToRad(c.toDouble());
      final isMajor = (c == 0 || c.abs() == 20);

      final tickLength = isMajor ? 12.0 : 6.0;

      final outerX = centerX + radius * math.sin(theta);
      final outerY = pivotY - radius * math.cos(theta);

      final innerX = centerX + (radius - tickLength) * math.sin(theta);
      final innerY = pivotY - (radius - tickLength) * math.cos(theta);

      // Highlight "in tune" range ticks?
      if (c == 0) {
        paint.strokeWidth = 2.5;
        paint.color = theme.textTheme.bodyLarge?.color ?? Colors.black;
      } else {
        paint.strokeWidth = 1.5;
        paint.color = theme.textTheme.bodyLarge?.color?.withOpacity(0.5) ?? Colors.grey;
      }

      canvas.drawLine(Offset(innerX, innerY), Offset(outerX, outerY), paint);

      // Labels for +/- 20
      if (c.abs() == 20) {
         final label = c > 0 ? '+20' : '-20';
         textPainter.text = TextSpan(
           text: label,
           style: theme.textTheme.bodySmall?.copyWith(
             fontSize: 10,
             color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
           ),
         );
         textPainter.layout();

         // Position below the tick
         final labelDist = radius - tickLength - 12;
         final labelX = centerX + labelDist * math.sin(theta) - textPainter.width / 2;
         final labelY = pivotY - labelDist * math.cos(theta) - textPainter.height / 2;

         textPainter.paint(canvas, Offset(labelX, labelY));
      }

      // Tolerance markers (triangle at 0)
      if (c == 0) {
         // Draw a small triangle pointing down at the 0 tick
         final triDist = radius + 8;
         final triX = centerX + triDist * math.sin(theta);
         final triY = pivotY - triDist * math.cos(theta);

         final path = Path();
         path.moveTo(triX, triY);
         path.lineTo(triX - 4, triY - 6);
         path.lineTo(triX + 4, triY - 6);
         path.close();

         canvas.drawPath(path, Paint()..color = theme.textTheme.bodyLarge?.color ?? Colors.black);
      }
    }

    // Draw Tolerance Range Arc (optional, maybe distinct line for +/- 5 cents)
    // Let's draw a thicker arc segment at the top for +/- 5 cents
    /*
    final rangePaint = Paint()
      ..color = theme.colorScheme.secondary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final startAngle = -math.pi/2 + centsToRad(-5);
    final sweepAngle = centsToRad(5) - centsToRad(-5);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, pivotY), radius: radius + 2),
      startAngle,
      sweepAngle,
      false,
      rangePaint
    );
    */

    // Draw Needle
    final needleAngle = centsToRad(centsDeviation);
    final needlePaint = Paint()
      ..color = theme.textTheme.bodyLarge?.color ?? Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Needle goes from bottom of widget up to the ticks
    // Widget height is size.height.
    // Let's make needle start at bottom center.
    // And end near the ticks.

    // Needle tip
    final tipRadius = radius - 5;
    final tipX = centerX + tipRadius * math.sin(needleAngle);
    final tipY = pivotY - tipRadius * math.cos(needleAngle);

    // Needle base (bottom of widget)
    // We want the needle to look like it pivots from the virtual pivot,
    // but we only draw the visible part.
    final baseRadius = pivotY - size.height;
    final baseX = centerX + baseRadius * math.sin(needleAngle);
    final baseY = pivotY - baseRadius * math.cos(needleAngle);

    canvas.drawLine(Offset(baseX, baseY), Offset(tipX, tipY), needlePaint);
  }

  @override
  bool shouldRepaint(covariant KorgGaugePainter oldDelegate) {
    return oldDelegate.centsDeviation != centsDeviation || oldDelegate.theme != theme;
  }
}
