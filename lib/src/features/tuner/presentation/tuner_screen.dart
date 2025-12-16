// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuner/src/features/tuner/domain/tuner_provider.dart';
import 'package:tuner/src/features/tuner/presentation/note_display.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_gauge.dart';
import 'package:tuner/src/utils/music_theory.dart';

import '../../../common_widgets/shape_painter.dart';
import '../../../theme/koda_theme.dart';

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

    // Create a specific theme for this screen (Dark text theme on Indigo background)
    // We base it on the dark theme because we want white text.
    final tunerTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.tuner,
      // Adjust color scheme if needed, e.g. for the gauge LEDs
    );

    return Theme(
      data: tunerTheme,
      child: Hero(
        tag: 'tool_card_tuner',
        child: Scaffold(
          backgroundColor: KodaColors.tuner,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Stack(
            children: [
              // Decoration
              Positioned.fill(
                child: CustomPaint(
                  painter: ShapePainter(
                    shape: KodaShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: noteAsync.when(
                  data: (note) {
                    if (note == null) {
                      return Center(
                        child: Text(
                          'Listening...',
                          style: tunerTheme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      );
                    }
                    final bool isInTune =
                        note.centsDeviation.abs() < MusicTheory.tuningTolerance;
                    final int frequency = note.frequency.round();

                    return Column(
                      children: [
                        const Spacer(),
                        NoteDisplay(
                          noteName: note.noteName,
                          octave: note.octave,
                          frequency: frequency,
                          isSharp: note.centsDeviation > 0,
                          isFlat: note.centsDeviation < 0,
                          isInTune: isInTune,
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
                    child: Text('Error: $err',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
