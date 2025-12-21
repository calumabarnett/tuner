// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../domain/beat_state.dart';

class SolarSystemRing extends StatefulWidget {
  final List<BeatState> beatStates;
  final bool isPlaying;
  final int bpm;
  final int? startTimeMicroseconds;
  final Function(int) onOrbTap;

  const SolarSystemRing({
    super.key,
    required this.beatStates,
    required this.isPlaying,
    required this.bpm,
    this.startTimeMicroseconds,
    required this.onOrbTap,
  });

  @override
  State<SolarSystemRing> createState() => _SolarSystemRingState();
}

class _SolarSystemRingState extends State<SolarSystemRing>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _playheadAngle = -math.pi / 2;
  double _pulse = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    if (widget.isPlaying) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(SolarSystemRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_ticker.isActive) {
      _ticker.start();
    } else if (!widget.isPlaying && _ticker.isActive) {
      _ticker.stop();
      setState(() {
         // Reset to top
         _playheadAngle = -math.pi / 2;
         _pulse = 0.0;
      });
    }
  }

  void _onTick(Duration elapsed) {
    if (widget.startTimeMicroseconds == null) return;

    final nowMicros = DateTime.now().microsecondsSinceEpoch;
    final elapsedMicros = nowMicros - widget.startTimeMicroseconds!;

    final beatDurationMicros = 60000000 / widget.bpm;
    final totalBeats = elapsedMicros / beatDurationMicros;

    final beatsCount = widget.beatStates.length;
    // Avoid division by zero
    if (beatsCount == 0) return;

    final barProgress = totalBeats % beatsCount;

    final angle = -math.pi / 2 + (barProgress / beatsCount) * 2 * math.pi;

    // Pulse calculation
    final beatPhase = totalBeats % 1.0;

    final currentBeatIndex = totalBeats.floor() % beatsCount;
    final isAccent = widget.beatStates[currentBeatIndex] == BeatState.accent;
    final intensity = isAccent ? 1.0 : 0.4;

    double p = 0.0;
    if (beatPhase < 0.2) {
      p = 1.0 - (beatPhase / 0.2);
    } else if (beatPhase > 0.9) {
      p = (beatPhase - 0.9) / 0.1;
    }

    setState(() {
      _playheadAngle = angle;
      _pulse = p * intensity;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = math.min(constraints.maxWidth, constraints.maxHeight);
      return GestureDetector(
        onTapUp: (details) => _handleTap(details, size),
        child: CustomPaint(
          size: Size(size, size),
          painter: _RingPainter(
            beatStates: widget.beatStates,
            playheadAngle: _playheadAngle,
            isPlaying: widget.isPlaying,
            pulse: _pulse,
          ),
        ),
      );
    });
  }

  void _handleTap(TapUpDetails details, double size) {
     final center = Offset(size / 2, size / 2);
     final radius = size / 2 - 20;

     final count = widget.beatStates.length;
     const hitThreshold = 30.0;

     for (int i = 0; i < count; i++) {
        final angle = -math.pi / 2 + (i / count) * 2 * math.pi;
        final orbX = center.dx + radius * math.cos(angle);
        final orbY = center.dy + radius * math.sin(angle);

        final dx = details.localPosition.dx - orbX;
        final dy = details.localPosition.dy - orbY;

        if (math.sqrt(dx*dx + dy*dy) < hitThreshold) {
           widget.onOrbTap(i);
           return;
        }
     }
  }
}

class _RingPainter extends CustomPainter {
  final List<BeatState> beatStates;
  final double playheadAngle;
  final bool isPlaying;
  final double pulse;

  _RingPainter({
    required this.beatStates,
    required this.playheadAngle,
    required this.isPlaying,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw Ring
    const baseOpacity = 0.2;
    final pulseOpacity = 0.3 * pulse;
    final totalOpacity = (baseOpacity + pulseOpacity).clamp(0.0, 1.0);

    const baseWidth = 4.0;
    final pulseWidth = 4.0 * pulse;

    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(totalOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseWidth + pulseWidth;

    canvas.drawCircle(center, radius, ringPaint);

    // Draw Orbs
    final count = beatStates.length;
    for (int i = 0; i < count; i++) {
       final angle = -math.pi / 2 + (i / count) * 2 * math.pi;
       final orbCenter = Offset(
         center.dx + radius * math.cos(angle),
         center.dy + radius * math.sin(angle),
       );

       final state = beatStates[i];
       _drawOrb(canvas, orbCenter, state);
    }

    // Draw Playhead
    if (isPlaying) {
      const playheadRadius = 10.0;
      final phCenter = Offset(
         center.dx + radius * math.cos(playheadAngle),
         center.dy + radius * math.sin(playheadAngle),
      );

      final phPaint = Paint()..color = Colors.white;
      canvas.drawCircle(phCenter, playheadRadius, phPaint);
    }
  }

  void _drawOrb(Canvas canvas, Offset center, BeatState state) {
    const radius = 8.0;

    final paint = Paint();
    if (state == BeatState.accent) {
       paint.color = Colors.white;
       paint.style = PaintingStyle.fill;
    } else if (state == BeatState.standard) {
       paint.color = Colors.white;
       paint.style = PaintingStyle.stroke;
       paint.strokeWidth = 2.0;
    } else { // Mute
       paint.color = Colors.white.withOpacity(0.1);
       paint.style = PaintingStyle.fill;
    }

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) {
    return old.playheadAngle != playheadAngle ||
           old.beatStates != beatStates ||
           old.pulse != pulse;
  }
}
