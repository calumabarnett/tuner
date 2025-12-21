// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteDisplay extends StatelessWidget {
  final String noteName;
  final int octave;
  final int frequency;
  final bool isInTune;

  const NoteDisplay({
    super.key,
    required this.noteName,
    required this.octave,
    required this.frequency,
    required this.isInTune,
  });

  @override
  Widget build(BuildContext context) {
    // Mint Green for In Tune, otherwise White
    final Color textColor = isInTune ? const Color(0xFF00D2A1) : Colors.white;

    // Improve semantics: "C#" -> "C Sharp"
    final String semanticNote = noteName.replaceAll('#', ' Sharp');
    final String semanticLabel = '$semanticNote $octave';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: semanticLabel,
          excludeSemantics: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                noteName,
                style: GoogleFonts.sora(
                  fontSize: 96,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 4),
              Text(
                '$octave',
                style: GoogleFonts.sora(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$frequency Hz',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textColor, // Same color behavior as note
          ),
        ),
      ],
    );
  }
}
