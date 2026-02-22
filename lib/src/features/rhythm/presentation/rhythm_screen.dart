// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/koda_theme.dart';
import '../application/rhythm_controller.dart';
import '../application/rhythm_state.dart';
import 'widgets/beat_grid.dart';
import 'widgets/note_icon.dart';
import 'widgets/rhythm_pulse.dart';

class RhythmScreen extends ConsumerStatefulWidget {
  const RhythmScreen({super.key});

  @override
  ConsumerState<RhythmScreen> createState() => _RhythmScreenState();
}

class _RhythmScreenState extends ConsumerState<RhythmScreen> with SingleTickerProviderStateMixin {
  late AnimationController _measureController;
  int _currentBeat = 0;

  @override
  void initState() {
    super.initState();
    _measureController = AnimationController(vsync: this);
    _measureController.addListener(_updateBeat);
    _syncController();
  }

  @override
  void dispose() {
    _measureController.removeListener(_updateBeat);
    _measureController.dispose();
    super.dispose();
  }

  void _updateBeat() {
    final state = ref.read(rhythmControllerProvider);
    if (!state.isPlaying) return;

    final int newBeat = (_measureController.value * state.beatsPerMeasure).floor().clamp(0, state.beatsPerMeasure - 1);

    if (newBeat != _currentBeat) {
      setState(() {
        _currentBeat = newBeat;
      });
    }
  }

  void _syncController() {
    final state = ref.read(rhythmControllerProvider);
    if (state.isPlaying) {
      final measureDurationMs = ((60000 / state.bpm) * state.beatsPerMeasure).round();
      _measureController.duration = Duration(milliseconds: measureDurationMs);
      setState(() {
        _currentBeat = 0;
      });
      // Small delay to allow audio buffer to start
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted && ref.read(rhythmControllerProvider).isPlaying) {
          _measureController.repeat();
        }
      });
    } else {
      _measureController.stop();
      _measureController.reset();
      setState(() {
        _currentBeat = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rhythmControllerProvider);
    final controller = ref.read(rhythmControllerProvider.notifier);

    ref.listen(rhythmControllerProvider, (previous, next) {
      if (previous?.isPlaying != next.isPlaying ||
          previous?.bpm != next.bpm ||
          previous?.beatsPerMeasure != next.beatsPerMeasure) {
        _syncController();
      }
    });

    final rhythmTheme = KodaTheme.dark.copyWith(
      scaffoldBackgroundColor: KodaColors.rhythm,
    );

    return Theme(
      data: rhythmTheme,
      child: Scaffold(
        backgroundColor: KodaColors.rhythm,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isSmallScreen = constraints.maxHeight < 600;

              return Column(
                children: [
                  // --- Zone A: BPM & Measure Info ---
                  Expanded(
                    flex: isSmallScreen ? 5 : 6,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        RhythmPulse(
                          bpm: state.bpm,
                          isPlaying: state.isPlaying,
                          scale: isSmallScreen ? 0.7 : 1.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${state.bpm}',
                              style: GoogleFonts.sora(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 64 : 84,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'BPM',
                              style: GoogleFonts.manrope(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- Zone B: Beat Grid ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
                    child: BeatGrid(
                      count: state.beatsPerMeasure,
                      accents: state.accents,
                      activeBeat: _currentBeat,
                      onToggleAccent: controller.toggleAccent,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Zone C: Advanced Controls ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // Time Signature & Subdivision Selectors
                        Row(
                          children: [
                            Expanded(
                              child: _SelectorCard(
                                label: 'SIGNATURE',
                                value: '${state.beatsPerMeasure}/${state.beatUnit}',
                                onTap: () => _showSignaturePicker(context, state, controller),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SelectorCard(
                                label: 'SUBDIVISION',
                                value: _getSubdivisionLabel(state.subdivision, state.beatUnit),
                                icon: NoteIcon(unit: state.beatUnit, subdivision: state.subdivision, size: 16),
                                onTap: () => _showSubdivisionPicker(context, state, controller),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // BPM Slider
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
                            min: 30,
                            max: 300,
                            onChanged: (value) => controller.setBpm(value.toInt()),
                          ),
                        ),

                        // Fine BPM and Tap
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _IconButton(
                              onPressed: controller.decrementBpm,
                              icon: Icons.remove,
                              tooltip: 'Decrease BPM',
                            ),
                            _ActionButton(
                              label: 'TAP TEMPO',
                              onTap: controller.tapTempo,
                            ),
                            _IconButton(
                              onPressed: controller.incrementBpm,
                              icon: Icons.add,
                              tooltip: 'Increase BPM',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

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
              );
            },
          ),
        ),
      ),
    );
  }

  String _getUnitName(int unit) {
    switch (unit) {
      case 2: return 'Minim';
      case 4: return 'Crotchet';
      case 8: return 'Quaver';
      case 16: return 'Semiquaver';
      default: return 'Beat';
    }
  }

  String _getSubdivisionLabel(int sub, int unit) {
    if (sub == 1) return 'None';

    switch (unit) {
      case 2:
        if (sub == 2) return 'Crotchets';
        if (sub == 4) return 'Quavers';
        break;
      case 4:
        if (sub == 2) return 'Quavers';
        if (sub == 4) return 'Semiquavers';
        break;
      case 8:
        if (sub == 2) return 'Semiquavers';
        break;
    }
    if (sub == 3) return 'Triplets';
    return 'Subdivisions';
  }

  void _showSignaturePicker(BuildContext context, RhythmState initialState, RhythmController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KodaColors.darkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(rhythmControllerProvider);
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Time Signature',
                      style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PickerColumn(
                        label: 'Beats',
                        value: state.beatsPerMeasure,
                        min: 1,
                        max: 16,
                        onChanged: (v) => controller.setBeatsPerMeasure(v),
                      ),
                      Text('/', style: GoogleFonts.sora(fontSize: 48, color: Colors.white)),
                      _PickerColumn(
                        label: 'Unit (${_getUnitName(state.beatUnit)})',
                        value: state.beatUnit,
                        options: const [2, 4, 8, 16],
                        onChanged: (v) => controller.setBeatUnit(v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _PresetChip(label: '4/4', onTap: () => controller.setPreset(4, 4)),
                      _PresetChip(label: '3/4', onTap: () => controller.setPreset(3, 4)),
                      _PresetChip(label: '6/8', onTap: () => controller.setPreset(6, 8)),
                      _PresetChip(label: '7/8', onTap: () => controller.setPreset(7, 8)),
                      _PresetChip(label: '5/4', onTap: () => controller.setPreset(5, 4)),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSubdivisionPicker(BuildContext context, RhythmState state, RhythmController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: KodaColors.darkBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final List<int> subOptions = [1];
        if (state.beatUnit <= 8) subOptions.add(2);
        if (state.beatUnit <= 8) subOptions.add(3);
        if (state.beatUnit <= 4) subOptions.add(4);

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Subdivisions',
                  style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              ...subOptions.map((sub) {
                return ListTile(
                  leading: NoteIcon(unit: state.beatUnit, subdivision: sub),
                  title: Text(_getSubdivisionLabel(sub, state.beatUnit), style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    controller.setSubdivision(sub);
                    Navigator.pop(context);
                  },
                  trailing: state.subdivision == sub ? const Icon(Icons.check, color: KodaColors.rhythm) : null,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _SelectorCard extends StatelessWidget {
  final String label;
  final String value;
  final Widget? icon;
  final VoidCallback onTap;

  const _SelectorCard({required this.label, required this.value, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(label, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(value, style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String tooltip;

  const _IconButton({required this.onPressed, required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, color: Colors.white, size: 28),
      style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _PickerColumn extends StatelessWidget {
  final String label;
  final int value;
  final int? min;
  final int? max;
  final List<int>? options;
  final Function(int) onChanged;

  const _PickerColumn({
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            _MiniButton(icon: Icons.remove, onPressed: () {
              if (options != null) {
                final idx = options!.indexOf(value);
                if (idx > 0) onChanged(options![idx - 1]);
              } else if (min != null && value > min!) {
                onChanged(value - 1);
              }
            }),
            Container(
              width: 50,
              alignment: Alignment.center,
              child: Text('$value', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            _MiniButton(icon: Icons.add, onPressed: () {
               if (options != null) {
                final idx = options!.indexOf(value);
                if (idx < options!.length - 1) onChanged(options![idx + 1]);
              } else if (max != null && value < max!) {
                onChanged(value + 1);
              }
            }),
          ],
        )
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MiniButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: onPressed,
      style: IconButton.styleFrom(backgroundColor: Colors.white10),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
    );
  }
}
