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

    // Grid is STATIC. Button 0 is always C.
    // The Labels are fixed.

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
            // Index 0..11 represents Written C..B
            // State tracks Written Note Index.
            final isSelected = state.noteIndex == index;

            final labels = _labels[index];
            // Format: "C" or "C#/Db"
            final labelText = labels.join('/');

            return Semantics(
              button: true,
              selected: isSelected,
              label:
                  'Select ${labelText.replaceAll('♯', ' Sharp').replaceAll('♭', ' Flat')}',
              child: GestureDetector(
                onTap: () => controller.selectNote(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.white : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          labelText,
                          style: GoogleFonts.manrope(
                            color: isSelected
                                ? const Color(0xFF00D2A1)
                                : Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }
}
