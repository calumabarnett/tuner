// ignore_for_file: deprecated_member_use
import 'dart:math';
import 'package:flutter/material.dart';

class WaveRing extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double strokeWidth;

  const WaveRing({
    super.key,
    required this.isPlaying,
    this.color = Colors.white,
    this.strokeWidth = 4.0,
  });

  @override
  State<WaveRing> createState() => _WaveRingState();
}

class _WaveRingState extends State<WaveRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didUpdateWidget(WaveRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Even if not playing, we keep the controller running for smooth transitions
    // or we could stop it to save resources.
    // The prompt says "When the note is sounding, animate".
    // But for a smooth UI, usually we just animate opacity or amplitude.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WavePainter(
            animationValue: _controller.value,
            isPlaying: widget.isPlaying,
            color: widget.color,
            strokeWidth: widget.strokeWidth,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final bool isPlaying;
  final Color color;
  final double strokeWidth;

  _WavePainter({
    required this.animationValue,
    required this.isPlaying,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double radius = min(size.width, size.height) / 2 - strokeWidth * 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Path path = Path();
    const int segments = 100;

    // We create a loopable noise/wave effect.
    // 3 sine waves of different frequencies added together.

    for (int i = 0; i <= segments; i++) {
      final double angle = (i / segments) * 2 * pi;

      double offset = 0;
      if (isPlaying) {
        // Create a wave effect that travels around the ring
        // Wave 1: 3 lobes, moving forward
        final double w1 = sin(angle * 3 + animationValue * 2 * pi);
        // Wave 2: 5 lobes, moving backward slowly
        final double w2 = sin(angle * 5 - animationValue * 2 * pi);

        // Amplitude modulation
        offset = (w1 + w2) * 5.0;
      }

      final double r = radius + offset;
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.isPlaying != isPlaying;
  }
}
