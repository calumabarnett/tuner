import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/tone_controller.dart';

class TranspositionSheet extends ConsumerWidget {
  const TranspositionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toneControllerProvider);
    final controller = ref.read(toneControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Select Transposition',
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Divider(),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ToneController.transpositions.length,
              itemBuilder: (context, index) {
                final item = ToneController.transpositions[index];
                final isSelected = state.transpositionIndex == index;

                return ListTile(
                  title: Text(
                    item['name'] as String,
                    style: GoogleFonts.manrope(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF00D2A1) : Colors.black,
                    ),
                  ),
                  trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF00D2A1)) : null,
                  onTap: () {
                    controller.setTransposition(index);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
