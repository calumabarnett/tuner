// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/koda_theme.dart';
import '../application/rhythm_controller.dart';
import 'widgets/rhythm_pulse.dart';

class RhythmScreen extends ConsumerWidget {
  const RhythmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rhythmControllerProvider);
    final controller = ref.read(rhythmControllerProvider.notifier);

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
              // --- Zone A: Pulse & BPM ---
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RhythmPulse(
                      bpm: state.bpm,
                      isPlaying: state.isPlaying,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${state.bpm}',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontSize: 84,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'BPM',
                          style: GoogleFonts.manrope(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- Zone B: Controls ---
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withOpacity(0.3),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.1),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: state.bpm.toDouble(),
                          min: RhythmController.minBpm.toDouble(),
                          max: RhythmController.maxBpm.toDouble(),
                          onChanged: (value) => controller.setBpm(value.toInt()),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // +/- and Tap Tempo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ControlButton(
                            onPressed: controller.decrementBpm,
                            icon: Icons.remove,
                            label: ' -1 ',
                          ),
                          GestureDetector(
                            onTap: controller.tapTempo,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: Text(
                                'TAP TEMPO',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          _ControlButton(
                            onPressed: controller.incrementBpm,
                            icon: Icons.add,
                            label: ' +1 ',
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Play/Pause Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: GestureDetector(
                          onTap: controller.togglePlay,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              // Strictly 2D - No shadows
                            ),
                            child: Icon(
                              state.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: KodaColors.rhythm,
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
}

class _ControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  const _ControlButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          tooltip: label,
          icon: Icon(icon, color: Colors.white, size: 32),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}
