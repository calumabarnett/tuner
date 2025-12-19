import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
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
            icon: Icon(Icons.grid_view),
            label: 'Rhythm',
          ),
          NavigationDestination(
            icon: Icon(Icons.graphic_eq),
            label: 'Tone',
          ),
        ],
      ),
    );
  }
}
