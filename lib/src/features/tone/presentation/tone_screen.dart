// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../common_widgets/koda_app_bar.dart';
import '../../../common_widgets/shape_painter.dart';
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
      child: Hero(
        tag: 'tool_card_tone',
        child: Scaffold(
          backgroundColor: KodaColors.tone,
          appBar: const KodaAppBar(),
          body: Stack(
            children: [
              // Decoration
              Positioned.fill(
                child: CustomPaint(
                  painter: ShapePainter(
                    shape: KodaShape.wave,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
