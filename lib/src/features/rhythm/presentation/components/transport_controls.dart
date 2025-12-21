// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class TransportControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onConfig;

  const TransportControls({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0, left: 24, right: 24),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center Play Button
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.1),
                     blurRadius: 8,
                     offset: const Offset(0, 4),
                   ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 40,
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ),
          // Left Config Button
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              onPressed: onConfig,
            ),
          ),
        ],
      ),
    );
  }
}
