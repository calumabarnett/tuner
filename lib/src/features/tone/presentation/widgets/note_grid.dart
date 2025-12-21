// ignore_for_file: deprecated_member_use
import 'dart:async';
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
        final cellWidth = (constraints.maxWidth - 24) / 3;
        final cellHeight = (constraints.maxHeight - 36) / 4;
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
            final isSelected = state.noteIndex == index;

            // Written Note for Label
            int writtenIndex = (index - transOffset) % 12;
            if (writtenIndex < 0) writtenIndex += 12;

            final labels = _labels[writtenIndex];

            // Button Interaction:
            // We move interaction logic inside _NoteButton to manage the timer state locally.
            // We pass callbacks for actions.

            return _NoteButton(
               labels: labels,
               isSelected: isSelected,
               isPlayingGlobal: state.isPlaying,
               onTapSelect: () => controller.selectNote(index),
               onStartMomentary: () => controller.startMomentary(index),
               onStopMomentary: () => controller.stopMomentary(),
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
  final bool isPlayingGlobal;
  final VoidCallback onTapSelect;
  final VoidCallback onStartMomentary;
  final VoidCallback onStopMomentary;

  const _NoteButton({
    required this.labels,
    required this.isSelected,
    required this.isPlayingGlobal,
    required this.onTapSelect,
    required this.onStartMomentary,
    required this.onStopMomentary,
  });

  @override
  State<_NoteButton> createState() => _NoteButtonState();
}

class _NoteButtonState extends State<_NoteButton> {
  Timer? _holdTimer;
  bool _isHolding = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _handleDown() {
    if (widget.isPlayingGlobal) {
      // If sound is already ON (Toggle Mode), switch note immediately.
      widget.onTapSelect();
    } else {
      // Sound is OFF. Start timer to differentiate Tap vs Hold.
      _isHolding = false;
      _holdTimer?.cancel();
      _holdTimer = Timer(const Duration(milliseconds: 100), () {
        // Timer fired: It's a hold. Start playing.
        _isHolding = true;
        widget.onStartMomentary();
      });
    }
  }

  void _handleUpOrCancel() {
    if (widget.isPlayingGlobal) {
      // Toggle Mode: Do nothing on release.
    } else {
      // Sound WAS OFF.
      if (_holdTimer != null && _holdTimer!.isActive) {
        // Timer still active: It was a TAP (Short duration).
        _holdTimer!.cancel();
        // Just select, don't play.
        widget.onTapSelect();
      } else if (_isHolding) {
        // It was a HOLD. Stop playing.
        widget.onStopMomentary();
      }
      _isHolding = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _handleDown(),
      onPointerUp: (_) => _handleUpOrCancel(),
      onPointerCancel: (_) => _handleUpOrCancel(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: widget.labels.length > 1
             ? Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(
                      widget.labels[0],
                      style: GoogleFonts.manrope(
                        color: widget.isSelected ? const Color(0xFF00D2A1) : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                   ),
                   const SizedBox(height: 2),
                   Text(
                      widget.labels[1],
                      style: GoogleFonts.manrope(
                        color: widget.isSelected ? const Color(0xFF00D2A1).withOpacity(0.8) : Colors.white.withOpacity(0.8),
                        fontSize: 16, // Slightly smaller
                        fontWeight: FontWeight.w600,
                        height: 1.0,
                      ),
                   ),
                 ],
               )
             : Text(
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
}
