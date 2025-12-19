// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../common_widgets/koda_app_bar.dart';
import '../../../common_widgets/shape_painter.dart';
import '../../../theme/koda_theme.dart';
import '../../rhythm/presentation/rhythm_screen.dart';
import '../../tone/presentation/tone_screen.dart';
import '../../tuner/presentation/tuner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KodaAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(
              child: _HomeCard(
                title: 'Tuner',
                color: KodaColors.tuner,
                shape: KodaShape.circle,
                onTap: () => _navigateTo(context, const TunerScreen()),
                heroTag: 'tool_card_tuner',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _HomeCard(
                title: 'Rhythm',
                color: KodaColors.rhythm,
                shape: KodaShape.square,
                onTap: () => _navigateTo(context, const RhythmScreen()),
                heroTag: 'tool_card_rhythm',
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _HomeCard(
                title: 'Tone',
                color: KodaColors.tone,
                shape: KodaShape.wave,
                onTap: () => _navigateTo(context, const ToneScreen()),
                heroTag: 'tool_card_tone',
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: screen,
          );
        },
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final String title;
  final Color color;
  final KodaShape shape;
  final VoidCallback onTap;
  final String? heroTag;

  const _HomeCard({
    required this.title,
    required this.color,
    required this.shape,
    required this.onTap,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    // Material provides the background color and ink splash support.
    Widget cardContent = Material(
      color: color,
      borderRadius: BorderRadius.zero, // Or add radius if "tiles" implies it? "Rules: strictly 2D". Square is better.
      child: InkWell(
        onTap: onTap,
        child: ClipRect(
          child: Stack(
            children: [
              // Decoration
              Positioned.fill(
                child: CustomPaint(
                  painter: ShapePainter(
                    shape: shape,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              // Title
              Positioned(
                top: 24,
                left: 24,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 24, // Match Koda AppBar title size
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (heroTag != null) {
      // Hero wraps the Material card
      cardContent = Hero(
        tag: heroTag!,
        child: cardContent,
      );
    }

    return cardContent;
  }
}
