// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class NoteDisplay extends StatelessWidget {
  final String noteName;
  final int octave;
  final int frequency;
  final bool isSharp;
  final bool isFlat;
  final bool isInTune;

  const NoteDisplay({
    super.key,
    required this.noteName,
    required this.octave,
    required this.frequency,
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

    final octaveColor = theme.textTheme.headlineMedium?.color?.withOpacity(0.5);

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
                color: octaveColor,
              ),
            ),
          ],
        ),
        Text(
          '$frequency Hz',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32, // Reserved space for "PERFECT"
          child: isInTune
              ? Center(
                  child: Text(
                    'PERFECT',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.secondary,
                      letterSpacing: 2.0,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
