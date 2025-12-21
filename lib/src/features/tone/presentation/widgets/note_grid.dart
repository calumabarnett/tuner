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

    // Calculate the "Visual Offset" based on Transposition.
    // Transposition Offset = offset from Concert to Written.
    // e.g. Bb Transposition: Offset -2. Written C = Concert Bb.
    // So Concert C = Written D (+2).
    // The visual label for Concert Button `i` should be `i - offset`.

    // Definitions:
    // Concert Pitch (C=0)
    // Transposition Offset (Concert - Written).
    // Example: Bb Trumpet. Offset = -2.
    // Written C = Concert (-2) = Bb.
    // So Written = Concert - Offset.
    // Label for Button i (Concert i) = i - Offset.

    final transOffset = ToneController.transpositions[state.transpositionIndex]['offset'] as int;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 12,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        // Index is 0..11 representing CONCERT PITCH C..B
        final isSelected = state.noteIndex == index;

        // Calculate Written Note Index for Label
        int writtenIndex = (index - transOffset) % 12;
        if (writtenIndex < 0) writtenIndex += 12;

        final labels = _labels[writtenIndex];

        return GestureDetector(
          onTap: () => controller.selectNote(index),
          onTapDown: (_) {
             if (!state.isPlaying) {
               controller.startMomentary(index);
             } else {
               // If already playing, just switch
               controller.selectNote(index);
             }
          },
          onTapUp: (_) {
            // Logic: "plays the note as long as it is held (if not already sounding)."
            // If we started playing in onTapDown because it was silent, we stop now.
            // But we need to know if we started it.
            // If the state was NOT playing before onTapDown.
            // The problem is we don't have the *previous* state here easily.
            // BUT, `startMomentary` sets `isPlaying = true`.
            // If I implement a `stopMomentary` that checks a flag?
            // Simpler: The controller knows? No.
            // Let's rely on the user behavior assumption:
            // If I just tapped (short duration), `onTap` fires.
            // If I hold, `onTapDown` fires immediately.
            // If I release, `onTapUp` fires.
            // If I just TAP:
            // Down -> Start Momentary (Sound On).
            // Up -> Stop Momentary (Sound Off).
            // Tap -> Select (Sound On/Off? No, Tap usually toggles selection, but sound state depends on `togglePlay`).

            // Wait. "Tapping a note button selects that note. If sound is active, switch pitch immediately."
            // "Pressing and holding... plays the note as long as it is held (if not already sounding)."

            // Scenario 1 (Sound ON, Playing C): Tap D.
            // Down D: Switch to D. Sound continues.
            // Up D: Sound continues.
            // Tap D: Select D (Redundant).

            // Scenario 2 (Sound OFF): Tap D.
            // Down D: Start Momentary D.
            // Up D: Stop Momentary D.
            // Tap D: Select D.
            // Result: A short blip of sound, then Silence. Selection moves to D.
            // This is acceptable and responsive.

            // Scenario 3 (Sound OFF): Hold D.
            // Down D: Start Momentary D.
            // ... Hold ...
            // Up D: Stop Momentary D.

            // The only issue is `onTap` usually fires AFTER Up.
            // So:
            // Down -> Play.
            // Up -> Stop.
            // Tap -> Select.

            // If Sound was ON originally:
            // Down -> Switch pitch.
            // Up -> Do nothing (keep playing).
            // Tap -> Do nothing.

            // So we need to know if sound was on *before* the interaction started.
            // We can capture this in closure or widget state?
            // Actually, `onTapDown` gives us the state at that moment.
          },
          child: _NoteButton(
             labels: labels,
             isSelected: isSelected,
             isAccidental: labels.length > 1,
             onDown: () {
                // If not playing, start playing (momentary).
                // If playing, switch note.
                if (!state.isPlaying) {
                  controller.startMomentary(index);
                  // We need to signal that we started momentary so we can stop it on up.
                  // But we can't pass state to onUp easily without a stateful widget wrapper.
                  // However, we can just use a Listener widget to handle raw pointer events if needed.
                  // Or just `stopMomentary` on Up which inside checks? No controller doesn't know source.
                } else {
                  controller.selectNote(index);
                }
             },
             onUp: () {
               // If we are playing, should we stop?
               // Only if we started momentary.
               // This logic is tricky in a stateless widget.
               // Ideally the Controller handles "Momentary" state.
               // Let's implement `stopMomentary` in Controller which stops ONLY if it thinks it's momentary?
               // No, Controller is global.
               // Let's assume: If Sound is OFF, holding plays. Releasing stops.
               // But `onDown` already turned Sound ON!
               // So `onUp` sees Sound ON. It doesn't know if it was ON before.

               // Solution: We need a stateful wrapper for the button to track interaction context.
               // But first, let's just build the visual button.
             },
          ),
        );
      },
    );
  }
}

class _NoteButton extends StatefulWidget {
  final List<String> labels;
  final bool isSelected;
  final bool isAccidental;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _NoteButton({
    required this.labels,
    required this.isSelected,
    required this.isAccidental,
    required this.onDown,
    required this.onUp,
  });

  @override
  State<_NoteButton> createState() => _NoteButtonState();
}

class _NoteButtonState extends State<_NoteButton> {
  bool _wasPlayingBeforeInteraction = false;

  @override
  Widget build(BuildContext context) {
    // We use a Listener to capture the state at the moment of touch down
    return Consumer(
      builder: (context, ref, child) {
         final isPlaying = ref.read(toneControllerProvider).isPlaying;

         return Listener(
          onPointerDown: (_) {
            _wasPlayingBeforeInteraction = isPlaying;
            widget.onDown();
          },
          onPointerUp: (_) {
            if (!_wasPlayingBeforeInteraction) {
              // It was silent, so we started it. Now we stop it.
              // Calls a method that stops ONLY.
              // We need to access the controller to stop.
              ref.read(toneControllerProvider.notifier).stopMomentary();
            }
            // If it WAS playing, we do nothing (it continues playing).
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
              child: _buildLabel(),
            ),
          ),
        );
      }
    );
  }

  Widget _buildLabel() {
    final color = widget.isSelected ? const Color(0xFF00D2A1) : Colors.white;

    if (widget.labels.length == 1) {
      return Text(
        widget.labels.first,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      );
    } else {
      // Enharmonic: Stack or Row?
      // "Show both names... most common name should be most prominent"
      // Without music theory context of Scale, we don't know which is "common".
      // We will display both equally or Primary/Secondary based on list order.
      // e.g. C# / Db.
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.labels[0],
            style: GoogleFonts.manrope(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            widget.labels[1],
            style: GoogleFonts.manrope(
              color: color.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }
}
