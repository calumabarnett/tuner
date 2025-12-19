// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../common_widgets/koda_app_bar.dart';
import '../../../common_widgets/shape_painter.dart';
import '../../../theme/koda_theme.dart';

class RhythmScreen extends StatelessWidget {
  const RhythmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme for this screen (Dark text theme on Rhythm color background)
    final rhythmTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.rhythm,
    );

    return Theme(
      data: rhythmTheme,
      child: Hero(
        tag: 'tool_card_rhythm',
        child: Scaffold(
          backgroundColor: KodaColors.rhythm,
          appBar: const KodaAppBar(),
          body: Stack(
            children: [
              // Decoration
              Positioned.fill(
                child: CustomPaint(
                  painter: ShapePainter(
                    shape: KodaShape.square,
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
