// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/koda_theme.dart';
import 'rhythm_gauge.dart';
import 'rhythm_provider.dart';

class RhythmScreen extends ConsumerWidget {
  const RhythmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force specific theme for this screen
    final rhythmTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.rhythm,
    );
    final state = ref.watch(rhythmProvider);
    final notifier = ref.read(rhythmProvider.notifier);

    return Theme(
      data: rhythmTheme,
      child: Scaffold(
        backgroundColor: KodaColors.rhythm,
        body: SafeArea(
          child: Column(
            children: [
              // Gauge Area + Zone A
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: RhythmGauge(),
                    ),
                    // Zone A: BPM Display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _showBpmDialog(context, notifier, state.bpm),
                          child: Text(
                            '${state.bpm}',
                            style: rhythmTheme.textTheme.displayLarge?.copyWith(
                              fontSize: 72,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '♩ = Crotchet',
                            style: rhythmTheme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Zone B: Controls
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Slider + Steppers
                      Row(
                        children: [
                          IconButton(
                            onPressed: notifier.decrementBpm,
                            icon: const Icon(Icons.remove, color: Colors.white),
                          ),
                          Expanded(
                            child: SliderTheme(
                                data: SliderThemeData(
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                                    thumbColor: Colors.white,
                                    trackHeight: 4.0,
                                ),
                                child: Slider(
                                    value: state.bpm.toDouble(),
                                    min: 30,
                                    max: 300,
                                    onChanged: (val) => notifier.setBpm(val.round()),
                                ),
                            ),
                          ),
                          IconButton(
                            onPressed: notifier.incrementBpm,
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Transport + Settings
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           // Settings
                           IconButton(
                             icon: const Icon(Icons.settings, color: Colors.white, size: 32),
                             onPressed: () => _showSettingsSheet(context, notifier, state.timeSignatureNumerator),
                           ),
                           const SizedBox(width: 32),
                           // Play/Stop
                           Container(
                             width: 80,
                             height: 80,
                             decoration: const BoxDecoration(
                               shape: BoxShape.circle,
                               color: Colors.white,
                             ),
                             child: IconButton(
                               icon: Icon(
                                 state.isPlaying ? Icons.stop : Icons.play_arrow,
                                 color: KodaColors.rhythm,
                                 size: 40,
                               ),
                               onPressed: notifier.togglePlay,
                             ),
                           ),
                           const SizedBox(width: 32),
                           // Dummy spacer to balance layout
                           const SizedBox(width: 48), // 32 (icon) + padding approx
                        ],
                      ),
                      const SizedBox(height: 48),
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

  void _showBpmDialog(BuildContext context, RhythmNotifier notifier, int currentBpm) {
    final controller = TextEditingController(text: currentBpm.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KodaColors.rhythm,
        title: const Text('Set BPM', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) notifier.setBpm(val);
              Navigator.pop(ctx);
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSettingsSheet(BuildContext context, RhythmNotifier notifier, int currentNumerator) {
    final options = [
      {'label': '3/4', 'val': 3},
      {'label': '4/4', 'val': 4},
      {'label': '5/4', 'val': 5},
      {'label': '6/8', 'val': 6},
      {'label': '7/8', 'val': 7},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: KodaColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
               'Time Signature',
               style: GoogleFonts.sora(
                 fontSize: 20,
                 fontWeight: FontWeight.bold,
                 color: KodaColors.lightInk,
               ),
             ),
             const SizedBox(height: 24),
             Wrap(
               spacing: 12,
               runSpacing: 12,
               children: options.map((opt) {
                 final val = opt['val'] as int;
                 final isSelected = val == currentNumerator;
                 return ChoiceChip(
                   label: Text(
                     opt['label'] as String,
                     style: TextStyle(
                       color: isSelected ? Colors.white : KodaColors.lightInk,
                       fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                     ),
                   ),
                   selected: isSelected,
                   selectedColor: KodaColors.rhythm,
                   backgroundColor: KodaColors.lightBackground,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(20),
                     side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                   ),
                   onSelected: (bool selected) {
                     if (selected) {
                       notifier.setTimeSignature(val);
                       Navigator.pop(ctx);
                     }
                   },
                 );
               }).toList(),
             ),
             const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
