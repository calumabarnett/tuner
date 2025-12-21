// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuner/src/features/tuner/domain/permission_provider.dart';
import 'package:tuner/src/features/tuner/domain/tuner_provider.dart';
import 'package:tuner/src/features/tuner/presentation/note_display.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_gauge.dart';
import 'package:tuner/src/utils/music_theory.dart';

class TunerScreen extends ConsumerStatefulWidget {
  const TunerScreen({super.key});

  @override
  ConsumerState<TunerScreen> createState() => _TunerScreenState();
}

class _TunerScreenState extends ConsumerState<TunerScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Request permission on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(microphonePermissionProvider.notifier).request();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(microphonePermissionProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(microphonePermissionProvider);

    // Standard: 0xFF4D5BCE, Success: 0xFF6874E8
    const standardColor = Color(0xFF4D5BCE);
    const successColor = Color(0xFF6874E8);

    return permissionAsync.when(
      loading: () => Container(
        color: standardColor,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      error: (err, stack) => Container(
        color: standardColor,
        child: Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.white)),
        ),
      ),
      data: (status) {
        if (!status.isGranted) {
          final isPermanent = status.isPermanentlyDenied;
          return Container(
            color: standardColor,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mic_off, size: 48, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Microphone Required',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isPermanent
                      ? 'Please enable microphone access in settings to tune your instrument.'
                      : 'This app needs microphone access to detect pitch.',
                  style: GoogleFonts.manrope(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (isPermanent) {
                      openAppSettings();
                    } else {
                      ref.read(microphonePermissionProvider.notifier).request();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: standardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    isPermanent ? 'Open Settings' : 'Grant Permission',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final noteAsync = ref.watch(tunerNoteProvider);

        return noteAsync.when(
          data: (note) {
            final bool isInTune = note != null &&
                note.centsDeviation.abs() < MusicTheory.tuningTolerance;

            final backgroundColor = isInTune ? successColor : standardColor;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
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
      },
    );
  }
}
