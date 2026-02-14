// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/koda_theme.dart';
import '../domain/rhythm_provider.dart';
import 'rhythm_gauge.dart';

class RhythmScreen extends ConsumerWidget {
  const RhythmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rhythmState = ref.watch(rhythmProvider);
    final rhythmNotifier = ref.read(rhythmProvider.notifier);

    // Coral Red
    final rhythmTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.rhythm,
    );

    return Theme(
      data: rhythmTheme,
      child: Scaffold(
        backgroundColor: KodaColors.rhythm,
        body: SafeArea(
          child: Column(
            children: [
              // 1. Rhythm Gauge & Zone A (Center Info)
              Expanded(
                flex: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RhythmGauge(
                          beatsPerBar: rhythmState.timeSignatureNumerator,
                          beatPatterns: rhythmState.beatPatterns,
                          currentBeatIndex: rhythmState.currentBeatIndex,
                          bpm: rhythmState.bpm,
                          isPlaying: rhythmState.isPlaying,
                          onOrbTap: (index) {
                            rhythmNotifier.cycleBeatPattern(index);
                          },
                        ),
                        // Zone A: BPM & Pulse Unit
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showBpmDialog(context, rhythmState.bpm, rhythmNotifier);
                              },
                              child: Text(
                                '${rhythmState.bpm}',
                                style: GoogleFonts.sora(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '♩ = Crotchet', // Placeholder mapping
                                style: GoogleFonts.jetBrainsMono(
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
                ),
              ),

              // 2. Zone B: Controls
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Slider & Steppers Row
                      Row(
                        children: [
                          _buildStepperButton(
                            icon: Icons.remove,
                            onTap: () {
                              rhythmNotifier.setBpm(rhythmState.bpm - 1);
                            },
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white.withOpacity(0.3),
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.1),
                                trackHeight: 4.0,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                              ),
                              child: Slider(
                                value: rhythmState.bpm.toDouble(),
                                min: 30,
                                max: 250,
                                onChanged: (val) {
                                  rhythmNotifier.setBpm(val.round());
                                },
                              ),
                            ),
                          ),
                          _buildStepperButton(
                            icon: Icons.add,
                            onTap: () {
                              rhythmNotifier.setBpm(rhythmState.bpm + 1);
                            },
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Bottom Controls: Config & Transport
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Config Button (Time Sig)
                            IconButton(
                              onPressed: () {
                                _showTimeSignaturePicker(context, ref);
                              },
                              icon: const Icon(Icons.settings, color: Colors.white),
                              iconSize: 32,
                            ),

                            // Play/Stop
                            GestureDetector(
                              onTap: () {
                                rhythmNotifier.togglePlay();
                              },
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  rhythmState.isPlaying ? Icons.stop : Icons.play_arrow,
                                  color: KodaColors.rhythm,
                                  size: 40,
                                ),
                              ),
                            ),

                            // Placeholder for visual symmetry or other action
                            const SizedBox(width: 48),
                          ],
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

  Widget _buildStepperButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showBpmDialog(BuildContext context, int currentBpm, RhythmNotifier notifier) {
    final controller = TextEditingController(text: currentBpm.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: KodaColors.rhythm,
          title: Text(
            'Set BPM',
            style: GoogleFonts.sora(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: GoogleFonts.manrope(color: Colors.white, fontSize: 24),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            autofocus: true,
            onSubmitted: (value) {
              final newBpm = int.tryParse(value);
              if (newBpm != null) {
                notifier.setBpm(newBpm);
              }
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () {
                final newBpm = int.tryParse(controller.text);
                if (newBpm != null) {
                  notifier.setBpm(newBpm);
                }
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTimeSignaturePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KodaColors.rhythm,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Time Signature',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _TimeSigOption(num: 4, den: 4, label: '4/4'),
                  _TimeSigOption(num: 3, den: 4, label: '3/4'),
                  _TimeSigOption(num: 2, den: 4, label: '2/4'),
                  _TimeSigOption(num: 6, den: 8, label: '6/8'),
                  _TimeSigOption(num: 5, den: 4, label: '5/4'),
                  _TimeSigOption(num: 7, den: 8, label: '7/8'),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _TimeSigOption extends ConsumerWidget {
  final int num;
  final int den;
  final String label;

  const _TimeSigOption({required this.num, required this.den, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(rhythmProvider.notifier).setTimeSignature(num, den);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
