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

    // Logic: State stores CONCERT pitch (0-11).
    // Transposition Offset = Concert - Written.
    // Written = Concert - Offset.
    // We want to display WRITTEN note.
    final transOffset = ToneController.transpositions[state.transpositionIndex]['offset'] as int;

    // Written Index
    int writtenIndex = (state.noteIndex - transOffset) % 12;
    if (writtenIndex < 0) writtenIndex += 12;

    final writtenNoteNames = _getNoteNames(writtenIndex);
    // Combine names if multiple (e.g. C# / Db)
    final mainNoteText = writtenNoteNames.join(' / ');

    // Concert Pitch Display
    final concertNoteNames = _getNoteNames(state.noteIndex);
    final concertName = concertNoteNames.join(' / ');

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
                        // Transposition Button (Pill Style)
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (_) => const TranspositionSheet(),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.transpositionIndex == 0 ? 'Concert Pitch' : 'Key: $transName',
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Written Note Name
                        // Auto-size or wrapping if "C# / Db" is too long?
                        // "C# / Db" is short enough for 72px font on most screens? Maybe not.
                        // Let's use FittedBox or check length.
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text(
                              mainNoteText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),

                        // Subtitle: Concert Pitch (if transposed)
                        // Use Visibility to reserve space
                        Visibility(
                          visible: state.transpositionIndex != 0,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Concert: $concertName',
                              style: GoogleFonts.manrope(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Octave Control
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => controller.setOctave(state.octave - 1),
                              icon: const Icon(Icons.remove, color: Colors.white),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.octave}',
                                style: GoogleFonts.jetBrainsMono(
                                  color: Colors.white,
                                  fontSize: 18,
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
                      // Note Grid
                      const Expanded(
                        child: NoteGrid(),
                      ),

                      // Play/Pause Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                        child: GestureDetector(
                          onTap: controller.togglePlay,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
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
