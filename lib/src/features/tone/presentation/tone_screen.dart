// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../theme/koda_theme.dart';

class ToneScreen extends StatelessWidget {
  const ToneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final toneTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.tone,
    );

    return Theme(
      data: toneTheme,
      child: Container(
        color: KodaColors.tone,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'Tone',
            style: toneTheme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
