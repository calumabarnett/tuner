// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/koda_theme.dart';
import '../application/tone_controller.dart';
import 'widgets/note_grid.dart';
import 'widgets/transposition_sheet.dart';
import 'widgets/wave_ring.dart';

class ToneScreen extends ConsumerWidget {
  const ToneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We override the theme to ensure Tone colors are primary
    final toneTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.tone,
    );

    final state = ref.watch(toneControllerProvider);
    final controller = ref.read(toneControllerProvider.notifier);

    // Calculate display note name
    // State stores CONCERT index (0-11).
    // Transposition Offset (Concert - Written).
    // Written = Concert - Offset.
    final transOffset = ToneController.transpositions[state.transpositionIndex]['offset'] as int;
    int writtenIndex = (state.noteIndex - transOffset) % 12;
    if (writtenIndex < 0) writtenIndex += 12;

    final noteNames = _getNoteNames(writtenIndex);
    final mainNoteName = noteNames[0];
    final subNoteName = noteNames.length > 1 ? noteNames[1] : null;

    // Transposition Name
    final transName = ToneController.transpositions[state.transpositionIndex]['name'] as String;

    return Theme(
      data: toneTheme,
      child: Scaffold(
        backgroundColor: KodaColors.tone,
        body: SafeArea(
          child: Column(
            children: [
              // --- Zone A: Identity & Ring (Flexible Height) ---
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // The Wave Ring
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: WaveRing(isPlaying: state.isPlaying),
                    ),

                    // Center Content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Transposition Button
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const TranspositionSheet(),
                            );
                          },
                          child: Text(
                            transName,
                            style: GoogleFonts.manrope(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Note Name
                        Text(
                          mainNoteName,
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 64, // Big!
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                        if (subNoteName != null)
                          Text(
                            subNoteName,
                            style: GoogleFonts.sora(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Octave Control
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => controller.setOctave(state.octave - 1),
                              icon: const Icon(Icons.remove, color: Colors.white),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.octave}',
                              style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.setOctave(state.octave + 1),
                              icon: const Icon(Icons.add, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Zone B: Grid & Controls ---
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const Expanded(
                        child: NoteGrid(),
                      ),

                      // Play/Pause Button
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: GestureDetector(
                          onTap: controller.togglePlay,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              state.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: KodaColors.tone,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getNoteNames(int index) {
    const names = [
      ['C'], ['C♯', 'D♭'], ['D'], ['D♯', 'E♭'],
      ['E'], ['F'], ['F♯', 'G♭'], ['G'],
      ['G♯', 'A♭'], ['A'], ['A♯', 'B♭'], ['B']
    ];
    return names[index];
  }
}
