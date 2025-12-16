// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../common_widgets/shape_painter.dart';
import '../../../theme/koda_theme.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../tuner/presentation/tuner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _HomeCard(
              title: 'Tuner',
              color: KodaColors.tuner,
              shape: KodaShape.circle,
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 600),
                    reverseTransitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return FadeTransition(
                        opacity: animation,
                        child: const TunerScreen(),
                      );
                    },
                  ),
                );
              },
              heroTag: 'tool_card_tuner',
            ),
          ),
          Expanded(
            child: _HomeCard(
              title: 'Rhythm',
              color: KodaColors.rhythm,
              shape: KodaShape.square,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rhythm Coming Soon')),
                );
              },
            ),
          ),
          Expanded(
            child: _HomeCard(
              title: 'Tone',
              color: KodaColors.tone,
              shape: KodaShape.wave,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tone Coming Soon')),
                );
              },
            ),
          ),
        ],
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
    Widget cardContent = Container(
      width: double.infinity,
      color: color,
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
                  ),
            ),
          ),
        ],
      ),
    );

    if (heroTag != null) {
      cardContent = Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: cardContent,
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      child: cardContent,
    );
  }
}
