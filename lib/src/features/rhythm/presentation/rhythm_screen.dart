// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../theme/koda_theme.dart';

class RhythmScreen extends StatelessWidget {
  const RhythmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rhythmTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.rhythm,
    );

    return Theme(
      data: rhythmTheme,
      child: Container(
        color: KodaColors.rhythm,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Text(
            'Rhythm',
            style: rhythmTheme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
