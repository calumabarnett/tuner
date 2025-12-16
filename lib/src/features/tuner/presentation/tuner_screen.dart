import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuner/src/features/settings/presentation/settings_screen.dart';
import 'package:tuner/src/features/tuner/domain/tuner_provider.dart';
import 'package:tuner/src/features/tuner/presentation/note_display.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_gauge.dart';
import 'package:tuner/src/utils/music_theory.dart';

class TunerScreen extends ConsumerStatefulWidget {
  const TunerScreen({super.key});

  @override
  ConsumerState<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends ConsumerState<TunerScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // We request microphone permission on start.
    // In a real app, this should probably be user-initiated or handled more gracefully.
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(tunerNoteProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Settings Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48), // Spacer to balance layout
                  Text(
                    'TUNER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3.0,
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.3),
                    ),
                  ),
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
            ),

            Expanded(
              child: noteAsync.when(
                data: (note) {
                  if (note == null) {
                    return Center(
                      child: Text(
                        'Listening...',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    );
                  }
                  final bool isInTune = note.centsDeviation.abs() < MusicTheory.tuningTolerance;
                  // Round to integer
                  final int frequency = note.frequency.round();
                  final int cents = note.centsDeviation.round();

                  return Column(
                    children: [
                      const Spacer(),
                      NoteDisplay(
                        noteName: note.noteName,
                        octave: note.octave,
                        isSharp: note.centsDeviation > 0,
                        isFlat: note.centsDeviation < 0,
                        isInTune: isInTune,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '$frequency Hz',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyLarge?.color?.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${cents > 0 ? "+" : ""}$cents cents',
                        style: TextStyle(
                          color: isInTune
                              ? theme.colorScheme.secondary
                              : theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: TunerGauge(centsDeviation: note.centsDeviation),
                      ),
                      const SizedBox(height: 48),
                    ],
                  );
                },
                error: (err, stack) => Center(
                  child: Text('Error: $err', style: TextStyle(color: theme.colorScheme.error)),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
