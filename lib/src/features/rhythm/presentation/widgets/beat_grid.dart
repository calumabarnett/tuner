// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BeatGrid extends StatelessWidget {
  final int count;
  final List<bool> accents;
  final int activeBeat; // 0 to count-1
  final Function(int) onToggleAccent;

  const BeatGrid({
    super.key,
    required this.count,
    required this.accents,
    required this.activeBeat,
    required this.onToggleAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Beat grid for the current measure',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: List.generate(count, (index) {
          final isAccented = accents[index];
          final isActive = activeBeat == index;

          return GestureDetector(
            onTap: () => onToggleAccent(index),
            child: Semantics(
              button: true,
              label: 'Beat ${index + 1}${isAccented ? ", accented" : ""}${isActive ? ", active" : ""}',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isAccented
                      ? Colors.white
                      : (isActive ? Colors.white.withOpacity(0.5) : Colors.transparent),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.jetBrainsMono(
                      color: isAccented ? const Color(0xFFFF6B6B) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
