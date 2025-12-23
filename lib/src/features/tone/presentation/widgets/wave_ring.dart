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
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We animate the "amplitude" (0.0 to 1.0) based on isPlaying.
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: widget.isPlaying ? 1.0 : 0.0,
        end: widget.isPlaying ? 1.0 : 0.0,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      onEnd: () {
        if (!widget.isPlaying) {
          _controller.stop();
        }
      },
      builder: (context, amplitude, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _WavePainter(
                animationValue: _controller.value,
                amplitude: amplitude,
                color: widget.color,
                strokeWidth: widget.strokeWidth,
              ),
              child: Container(),
            );
          },
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double animationValue;
  final double amplitude; // 0.0 to 1.0
  final Color color;
  final double strokeWidth;

  _WavePainter({
    required this.animationValue,
    required this.amplitude,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color // Solid white (or passed color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double radius = min(size.width, size.height) / 2 - strokeWidth * 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    final Path path = Path();
    const int segments = 100;

    // Wave parameters
    // Max deviation from circle
    final double maxOffset = 10.0 * amplitude;

    for (int i = 0; i <= segments; i++) {
      final double angle = (i / segments) * 2 * pi;

      double offset = 0;
      if (amplitude > 0.01) {
        // Wave 1: 3 lobes
        final double w1 = sin(angle * 3 + animationValue * 2 * pi);
        // Wave 2: 5 lobes
        final double w2 = sin(angle * 5 - animationValue * 2 * pi);

        offset = (w1 + w2) * maxOffset * 0.5;
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
           oldDelegate.amplitude != amplitude ||
           oldDelegate.color != color;
  }
}
