import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuner/src/features/tuner/domain/tuner_provider.dart';
import 'package:tuner/src/features/tuner/presentation/note_display.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_gauge.dart';

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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              const Text(
                'TUNER',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                  color: Colors.white24,
                ),
              ),
              const Spacer(flex: 2),
              noteAsync.when(
                data: (note) {
                  if (note == null) {
                    return const Text(
                      'Listening...',
                      style: TextStyle(color: Colors.white38, fontSize: 18),
                    );
                  }
                  final bool isInTune = note.centsDeviation.abs() < 5.0;
                  return Column(
                    children: [
                      NoteDisplay(
                        noteName: note.noteName,
                        octave: note.octave,
                        isSharp: note.centsDeviation > 0,
                        isFlat: note.centsDeviation < 0,
                        isInTune: isInTune,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '${note.frequency.toStringAsFixed(1)} Hz',
                        style: const TextStyle(color: Colors.white30),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${note.centsDeviation > 0 ? "+" : ""}${note.centsDeviation.toStringAsFixed(1)} cents',
                         style: TextStyle(
                           color: isInTune ? const Color(0xFF03DAC6) : Colors.white54,
                           fontWeight: FontWeight.bold,
                         ),
                      ),
                      const SizedBox(height: 60),
                      TunerGauge(centsDeviation: note.centsDeviation),
                    ],
                  );
                },
                error: (err, stack) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                loading: () => const CircularProgressIndicator(),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
