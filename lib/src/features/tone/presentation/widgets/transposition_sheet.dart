// ignore_for_file: deprecated_member_use
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Transposition',
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
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
                final name = item['name'] as String;

                // Consistency: Ensure pairs are shown with '/' if they have it?
                // The `transpositions` list has "Db / C#" format manually entered.
                // I should ensure they are consistent with Grid (e.g. C# / Db vs Db / C#).
                // Grid uses C#/Db. Controller uses Db / C#.
                // I will trust the Controller string for now, but formatted nicely.

                return ListTile(
                  title: Text(
                    index == 0 ? 'Concert Pitch (C)' : 'Key of $name',
                    style: GoogleFonts.manrope(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF00D2A1) : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    index == 0 ? 'Standard Tuning' : 'Written C sounds like Concert $name',
                     style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.grey[600],
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
