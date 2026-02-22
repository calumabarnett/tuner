// ignore_for_file: deprecated_member_use
import 'dart:math';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic size to fit on one row
        // count dots + (count - 1) spacing
        const double maxDotSize = 40.0;
        const double spacing = 8.0;
        final double totalAvailableWidth = constraints.maxWidth;

        double dotSize = (totalAvailableWidth - (count - 1) * spacing) / count;
        dotSize = min(maxDotSize, dotSize).clamp(20.0, maxDotSize);

        return Semantics(
          label: 'Beat grid for the current measure',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (index) {
              final isAccented = accents[index];
              final isActive = activeBeat == index;

              return Padding(
                padding: EdgeInsets.only(right: index == count - 1 ? 0 : spacing),
                child: GestureDetector(
                  onTap: () => onToggleAccent(index),
                  child: Semantics(
                    button: true,
                    label: 'Beat ${index + 1}${isAccented ? ", accented" : ""}${isActive ? ", active" : ""}',
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Active Ring (Glow)
                        if (isActive)
                          Container(
                            width: dotSize + 6,
                            height: dotSize + 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        // The Beat Dot
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            color: isAccented
                                ? Colors.white
                                : Colors.transparent,
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
                                fontSize: dotSize > 30 ? 16 : (dotSize > 25 ? 12 : 10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
