// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';

class RhythmGauge extends StatelessWidget {
  final int beatsPerBar;
  final List<int> beatPatterns; // 1=Accent, 0=Normal, -1=Muted
  final int currentBeatIndex;
  final int bpm;
  final bool isPlaying;
  final Function(int index) onOrbTap;

  const RhythmGauge({
    super.key,
    required this.beatsPerBar,
    required this.beatPatterns,
    required this.currentBeatIndex,
    required this.bpm,
    required this.isPlaying,
    required this.onOrbTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        final double beatDurationMs = 60000 / bpm;

        return TweenAnimationBuilder<double>(
          // Target angle: index / count * 2pi
          // We animate from current -> current+1 over the duration of the beat.
          tween: Tween<double>(
            begin: currentBeatIndex.toDouble(),
            end: currentBeatIndex.toDouble() + 1.0
          ),
          duration: Duration(milliseconds: beatDurationMs.toInt()),
          curve: Curves.linear,
          key: ValueKey(currentBeatIndex), // Restart tween on beat change
          builder: (context, value, child) {
            final normalizedValue = value % beatsPerBar;
            final angle = (normalizedValue / beatsPerBar) * 2 * math.pi - (math.pi / 2); // -pi/2 to start top

            return GestureDetector(
              onTapUp: (details) {
                _handleTap(details, size, constraints.maxWidth, constraints.maxHeight);
              },
              child: SizedBox(
                width: size,
                height: size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: StaticRhythmPainter(
                        beatsPerBar: beatsPerBar,
                        beatPatterns: beatPatterns,
                        activeBeatIndex: currentBeatIndex,
                      ),
                    ),
                    if (isPlaying)
                      CustomPaint(
                        painter: PlayheadPainter(angle: angle),
                      ),
                    if (child != null) child,
                  ],
                ),
              ),
            );
          },
          child: null,
        );
      },
    );
  }

  void _handleTap(TapUpDetails details, double size, double maxWidth, double maxHeight) {
    final center = Offset(maxWidth / 2, maxHeight / 2);
    // Calculate touch relative to widget center
    final rel = details.localPosition - center;

    final radius = (size / 2) - 20.0;

    for (int i = 0; i < beatsPerBar; i++) {
      final angle = (i / beatsPerBar) * 2 * math.pi - (math.pi / 2);
      final orbPos = Offset(
        radius * math.cos(angle),
        radius * math.sin(angle),
      );

      if ((rel - orbPos).distance < 30.0) {
        onOrbTap(i);
        return;
      }
    }
  }
}

class StaticRhythmPainter extends CustomPainter {
  final int beatsPerBar;
  final List<int> beatPatterns;
  final int activeBeatIndex;

  StaticRhythmPainter({
    required this.beatsPerBar,
    required this.beatPatterns,
    required this.activeBeatIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 20.0;

    // 1. Draw Ring (White, 0.2 opacity)
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, ringPaint);

    // 2. Draw Orbs
    for (int i = 0; i < beatsPerBar; i++) {
      final angle = (i / beatsPerBar) * 2 * math.pi - (math.pi / 2);
      final orbCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final state = beatPatterns[i % beatPatterns.length];
      // 1=Accent, 0=Normal, -1=Muted

      final Paint orbPaint = Paint();
      final Paint strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      double orbRadius = 8.0;

      if (state == 1) {
        // Accent: Solid White
        orbPaint
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(orbCenter, orbRadius + 2, orbPaint);
      } else if (state == 0) {
        // Normal: Outlined
        canvas.drawCircle(orbCenter, orbRadius, strokePaint);
        // Fill center with barely visible white to grab taps
        orbPaint..color = Colors.white.withOpacity(0.01)..style=PaintingStyle.fill;
        canvas.drawCircle(orbCenter, orbRadius, orbPaint);

      } else {
        // Muted: Dimmed (0.1 opacity)
        orbPaint
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(orbCenter, orbRadius, orbPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StaticRhythmPainter oldDelegate) {
    return oldDelegate.beatsPerBar != beatsPerBar ||
           oldDelegate.beatPatterns != beatPatterns;
  }
}

class PlayheadPainter extends CustomPainter {
  final double angle;

  PlayheadPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 20.0;

    final playheadCenter = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // "The Playhead: A solid white orb"
    canvas.drawCircle(playheadCenter, 12.0, paint);
  }

  @override
  bool shouldRepaint(covariant PlayheadPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
