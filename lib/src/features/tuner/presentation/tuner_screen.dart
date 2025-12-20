// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
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
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(tunerNoteProvider);

    // Standard: 0xFF4D5BCE, Success: 0xFF6874E8
    const standardColor = Color(0xFF4D5BCE);
    const successColor = Color(0xFF6874E8);

    return noteAsync.when(
      data: (note) {
        final bool isInTune = note != null &&
            note.centsDeviation.abs() < MusicTheory.tuningTolerance;

        // Immediate color change, no transition
        final backgroundColor = isInTune ? successColor : standardColor;

        return Container(
          color: backgroundColor,
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              if (note != null) ...[
                // Note Display (Centered)
                Center(
                  child: NoteDisplay(
                    noteName: note.noteName,
                    octave: note.octave,
                    frequency: note.frequency.round(),
                    isInTune: isInTune,
                  ),
                ),
                // Gauge (Surrounding)
                // We want the gauge to be as big as possible.
                // Padding ensures it doesn't touch the screen edges.
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: TunerGauge(note: note),
                    ),
                  ),
                ),
              ] else ...[
                 Center(
                   child: Text(
                     'Listening...',
                     style: GoogleFonts.manrope(
                       color: Colors.white.withOpacity(0.7),
                       fontSize: 24,
                     ),
                   ),
                 ),
              ]
            ],
          ),
        );
      },
      error: (err, stack) => Container(
        color: standardColor,
        child: Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
      ),
      loading: () => Container(
        color: standardColor,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
