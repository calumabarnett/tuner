// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/tone_controller.dart';

class NoteGrid extends ConsumerWidget {
  const NoteGrid({super.key});

  static const List<List<String>> _labels = [
    ['C'], ['C♯', 'D♭'], ['D'], ['D♯', 'E♭'],
    ['E'], ['F'], ['F♯', 'G♭'], ['G'],
    ['G♯', 'A♭'], ['A'], ['A♯', 'B♭'], ['B']
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toneControllerProvider);
    final controller = ref.read(toneControllerProvider.notifier);

    final transOffset = ToneController.transpositions[state.transpositionIndex]['offset'] as int;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate cell size to fit 3x4 grid in available space
        // 3 columns, 4 rows
        // If height is constrained, we might need to adjust aspect ratio.
        // Or just let GridView sort it out.
        // Ideally, we want squares or near-squares.
        // constraint.maxHeight / 4 vs constraint.maxWidth / 3.

        // Let's use standard grid with aspect ratio 1.0 (Square).
        // If it overflows, GridView scrolls. But we want no scroll.
        // So we should calculate aspect ratio to FIT.
        // width / 3 = cellWidth. height / 4 = cellHeight.
        // childAspectRatio = cellWidth / cellHeight.

        final cellWidth = (constraints.maxWidth - 24) / 3; // 24 = spacing (12*2)
        final cellHeight = (constraints.maxHeight - 36) / 4; // 36 = spacing (12*3)
        final aspectRatio = cellWidth / cellHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            // Index 0..11 represents Concert Pitch C..B
            final isSelected = state.noteIndex == index;

            // Calculate Written Note for Label
            int writtenIndex = (index - transOffset) % 12;
            if (writtenIndex < 0) writtenIndex += 12;

            final labels = _labels[writtenIndex];

            return GestureDetector(
              onTap: () => controller.selectNote(index),
              onTapDown: (_) {
                 if (!state.isPlaying) {
                   controller.startMomentary(index);
                 } else {
                   controller.selectNote(index);
                 }
              },
              onTapUp: (_) {
                // We handle stopping in button state or verify here?
                // The complexity of momentary play:
                // We rely on the Button Widget's listener for robust Up detection
                // OR we can just do nothing here and let the button handle visual feedback?
                // NO. Logic must happen.
                // But `_NoteButton` uses `Listener`?
                // Actually, GestureDetector covers tap logic.
                // If I use `Listener` inside `_NoteButton` for Up event, that's better.
                // But `GestureDetector` `onTapUp` is also good.
                // The issue is `onTap` vs `onTapUp`.
              },
              child: _NoteButton(
                 labels: labels,
                 isSelected: isSelected,
                 onDown: () {
                    if (!state.isPlaying) {
                      controller.startMomentary(index);
                    } else {
                      controller.selectNote(index);
                    }
                 },
                 onUp: () {
                   // This callback is triggered by the Listener in _NoteButton
                   // Note: We need access to the CURRENT state to decide whether to stop.
                   // But `ref` here provides current state access? No, closure captures context.
                   // We need to check if we should stop.
                   // The logic "Stop ONLY if we started it" is hard to track purely here.
                   // But checking "isPlaying" is not enough.

                   // Let's rely on the controller method `stopMomentary`
                   // which unconditionally stops?
                   // If I was already playing (toggle mode), I don't want to stop.
                   // So the `_NoteButton` needs to know "Did I start it?".
                   // `_NoteButton` tracks `_wasPlayingBeforeInteraction`.
                 },
                 stopMomentaryCallback: () => controller.stopMomentary(),
              ),
            );
          },
        );
      }
    );
  }
}

class _NoteButton extends StatefulWidget {
  final List<String> labels;
  final bool isSelected;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final VoidCallback stopMomentaryCallback;

  const _NoteButton({
    required this.labels,
    required this.isSelected,
    required this.onDown,
    required this.onUp,
    required this.stopMomentaryCallback,
  });

  @override
  State<_NoteButton> createState() => _NoteButtonState();
}

class _NoteButtonState extends State<_NoteButton> {
  bool _startedPlay = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
         final isPlaying = ref.watch(toneControllerProvider).isPlaying;

         return Listener(
          onPointerDown: (_) {
            _startedPlay = !isPlaying; // If NOT playing, we are starting it.
            widget.onDown();
          },
          onPointerUp: (_) {
            if (_startedPlay) {
              // We started it, so we stop it.
              widget.stopMomentaryCallback();
              _startedPlay = false;
            }
          },
          onPointerCancel: (_) {
             if (_startedPlay) {
              widget.stopMomentaryCallback();
              _startedPlay = false;
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                // Only show primary name (first label) as per request
                widget.labels.first,
                style: GoogleFonts.manrope(
                  color: widget.isSelected ? const Color(0xFF00D2A1) : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
