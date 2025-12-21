import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/koda_theme.dart';
import '../../rhythm/presentation/rhythm_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../tone/presentation/tone_screen.dart';
import '../../tuner/presentation/tuner_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TunerScreen(),
    RhythmScreen(),
    ToneScreen(),
  ];

  Color _getIndicatorColor(int index) {
    switch (index) {
      case 0:
        return KodaColors.tuner;
      case 1:
        return KodaColors.rhythm;
      case 2:
        return KodaColors.tone;
      default:
        return KodaColors.tuner;
    }
  }

  @override
  Widget build(BuildContext context) {
    // NavigationBarTheme can be used or properties directly.
    // We use properties directly for dynamic values.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koda'),
        centerTitle: true,
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
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return IconThemeData(
                color: Theme.of(context).colorScheme.onSurfaceVariant);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          indicatorColor: _getIndicatorColor(_currentIndex),
          animationDuration: Duration.zero,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.mic),
              label: 'Tuner',
            ),
            NavigationDestination(
              icon: Icon(Icons.music_note),
              label: 'Rhythm',
            ),
            NavigationDestination(
              icon: Icon(Icons.graphic_eq),
              label: 'Tone',
            ),
          ],
        ),
      ),
    );
  }
}
