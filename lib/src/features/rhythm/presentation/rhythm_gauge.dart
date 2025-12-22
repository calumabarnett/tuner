// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'rhythm_provider.dart';

class RhythmGauge extends ConsumerWidget {
  const RhythmGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rhythmProvider);
    final beatDuration = Duration(milliseconds: (60000 / state.bpm).round());

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        final radius = (size / 2) - 40; // Padding for orbs
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Ring
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _GaugePainter(
                radius: radius,
                center: center,
              ),
            ),
            // Playhead
            TweenAnimationBuilder<double>(
              key: ValueKey(state.currentBeatIndex), // Reset on beat
              tween: Tween(begin: 0.0, end: 1.0),
              duration: state.isPlaying ? beatDuration : Duration.zero,
              curve: Curves.linear,
              builder: (context, value, child) {
                 final totalBeats = state.timeSignatureNumerator;
                 final currentBeat = state.currentBeatIndex;
                 // Angle per beat
                 final anglePerBeat = 2 * pi / totalBeats;
                 // Start angle (Top = -pi/2)
                 final startAngle = -pi / 2 + (currentBeat * anglePerBeat);
                 // Current interpolated angle
                 final currentAngle = startAngle + (value * anglePerBeat);

                 // If not playing, show at start of current beat
                 final displayAngle = state.isPlaying ? currentAngle : startAngle;

                 return CustomPaint(
                   size: Size(constraints.maxWidth, constraints.maxHeight),
                   painter: _PlayheadPainter(
                     radius: radius,
                     center: center,
                     angle: displayAngle,
                   ),
                 );
              },
            ),
            // Orbs
            ...List.generate(state.timeSignatureNumerator, (index) {
              final angle = -pi / 2 + (index * 2 * pi / state.timeSignatureNumerator);
              final orbPos = Offset(
                center.dx + radius * cos(angle),
                center.dy + radius * sin(angle),
              );
              final beatType = state.beatPatterns[index];

              return Positioned(
                left: orbPos.dx - 16,
                top: orbPos.dy - 16,
                child: GestureDetector(
                  onTap: () {
                    ref.read(rhythmProvider.notifier).toggleBeatAccent(index);
                  },
                  child: _OrbWidget(type: beatType),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _OrbWidget extends StatelessWidget {
  final int type;
  const _OrbWidget({required this.type});

  @override
  Widget build(BuildContext context) {
    Color fillColor = Colors.transparent;
    Color borderColor = Colors.white;

    if (type == 1) { // Accent
      fillColor = Colors.white;
    } else if (type == 0) { // Standard
      // default transparent
    } else if (type == 2) { // Muted
      borderColor = Colors.transparent;
      fillColor = Colors.white.withOpacity(0.1);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double radius;
  final Offset center;

  _GaugePainter({required this.radius, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PlayheadPainter extends CustomPainter {
    final double radius;
    final Offset center;
    final double angle;

    _PlayheadPainter({required this.radius, required this.center, required this.angle});

    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()
           ..color = Colors.white
           ..style = PaintingStyle.fill;

        final pos = Offset(
            center.dx + radius * cos(angle),
            center.dy + radius * sin(angle),
        );

        canvas.drawCircle(pos, 10.0, paint); // Playhead slightly larger
    }

    @override
    bool shouldRepaint(_PlayheadPainter old) => old.angle != angle;
}
