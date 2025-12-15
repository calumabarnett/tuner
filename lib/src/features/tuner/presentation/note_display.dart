import 'package:flutter/material.dart';

class NoteDisplay extends StatelessWidget {
  final String noteName;
  final int octave;
  final bool isSharp;
  final bool isFlat;
  final bool isInTune;

  const NoteDisplay({
    super.key,
    required this.noteName,
    required this.octave,
    this.isSharp = false,
    this.isFlat = false,
    this.isInTune = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isInTune
        ? theme.colorScheme.secondary
        : (isSharp || isFlat ? theme.colorScheme.error : theme.textTheme.displayLarge?.color);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              noteName[0], // The letter (e.g., 'A')
              style: theme.textTheme.displayLarge?.copyWith(
                color: color,
                fontSize: 120,
              ),
            ),
            if (noteName.length > 1)
              Text(
                noteName.substring(1), // The accidental (e.g., '#')
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontSize: 60,
                ),
              ),
            const SizedBox(width: 8),
            Text(
              '$octave',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white38,
              ),
            ),
          ],
        ),
        if (isInTune)
          Text(
            'PERFECT',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.secondary,
              letterSpacing: 2.0,
            ),
          ),
      ],
    );
  }
}
