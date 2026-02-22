// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class RhythmPulse extends StatefulWidget {
  final int bpm;
  final bool isPlaying;

  const RhythmPulse({
    super.key,
    required this.bpm,
    required this.isPlaying,
  });

  @override
  State<RhythmPulse> createState() => _RhythmPulseState();
}

class _RhythmPulseState extends State<RhythmPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (60000 / widget.bpm).round()),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RhythmPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bpm != widget.bpm) {
      _controller.duration = Duration(milliseconds: (60000 / widget.bpm).round());
      if (widget.isPlaying) {
        _controller.repeat();
      }
    }
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing Ring
            if (widget.isPlaying)
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(_opacityAnimation.value),
                      width: 4,
                    ),
                  ),
                ),
              ),
            // Static Ring
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
