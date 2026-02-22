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
    return LayoutBuilder(
      builder: (context, constraints) {
        // We want all dots on one row.
        const double spacing = 8.0;
        final double totalAvailableWidth = constraints.maxWidth;

        // dotSize * count + spacing * (count - 1) = totalAvailableWidth
        // dotSize = (totalAvailableWidth - spacing * (count - 1)) / count
        double dotSize = (totalAvailableWidth - (count - 1) * spacing) / count;

        // Max dot size 48, min dot size 8 (to avoid negative/too small)
        dotSize = dotSize.clamp(8.0, 48.0);

        return Semantics(
          label: 'Beat grid for the current measure',
          child: SizedBox(
            height: 60, // Fixed height to prevent vertical jitter
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
                          // Active Highlight (Ring outside)
                          if (isActive)
                            Container(
                              width: dotSize + 8,
                              height: dotSize + 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
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
                              child: dotSize > 24
                                ? Text(
                                    '${index + 1}',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: isAccented ? const Color(0xFFFF6B6B) : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: dotSize * 0.5,
                                    ),
                                  )
                                : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
