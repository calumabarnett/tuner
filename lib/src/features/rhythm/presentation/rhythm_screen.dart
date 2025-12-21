// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuner/src/theme/koda_theme.dart';
import '../domain/time_signature.dart';
import 'components/ruler_slider.dart';
import 'components/solar_system_ring.dart';
import 'components/transport_controls.dart';
import 'rhythm_controller.dart';

class RhythmScreen extends ConsumerWidget {
  const RhythmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rhythmState = ref.watch(rhythmProvider);
    final controller = ref.read(rhythmProvider.notifier);

    // Theme override for this screen
    final rhythmTheme = Theme.of(context).copyWith(
      scaffoldBackgroundColor: KodaColors.rhythm,
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white
      ),
    );

    return Theme(
      data: rhythmTheme,
      child: Scaffold(
        backgroundColor: KodaColors.rhythm,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Zone A: Identity (Solar System)
              Expanded(
                flex: 5,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // The Ring
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: SolarSystemRing(
                          beatStates: rhythmState.beatPattern,
                          isPlaying: rhythmState.isPlaying,
                          bpm: rhythmState.bpm,
                          startTimeMicroseconds: rhythmState.startTimeMicroseconds,
                          onOrbTap: (index) => controller.cycleBeatState(index),
                        ),
                      ),
                      // The Center Info
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _BpmDisplay(
                            bpm: rhythmState.bpm,
                            onBpmChanged: (val) => controller.setBpm(val),
                          ),
                          const SizedBox(height: 8),
                          // Pulse Unit
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '♩ = 1/${rhythmState.timeSignature.denominator}',
                              style: GoogleFonts.jetBrainsMono(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tap Tempo Button
                          GestureDetector(
                            onTap: () => controller.tapTempo(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.transparent, // Hit target
                              child: Text(
                                'TAP',
                                style: GoogleFonts.manrope(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Zone B: Controls
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Ruler Slider
                    RulerSlider(
                      value: rhythmState.bpm,
                      onChanged: (val) => controller.setBpm(val),
                    ),
                    const SizedBox(height: 24),
                    // Transport
                    TransportControls(
                      isPlaying: rhythmState.isPlaying,
                      onPlayPause: () => controller.togglePlay(),
                      onConfig: () => _showConfigSheet(context, ref),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfigSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C2C), // Dark sheet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ConfigSheet(),
    );
  }
}

class _BpmDisplay extends StatefulWidget {
  final int bpm;
  final ValueChanged<int> onBpmChanged;

  const _BpmDisplay({required this.bpm, required this.onBpmChanged});

  @override
  State<_BpmDisplay> createState() => _BpmDisplayState();
}

class _BpmDisplayState extends State<_BpmDisplay> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
       return SizedBox(
         width: 120,
         child: TextField(
           controller: _controller,
           focusNode: _focusNode,
           keyboardType: TextInputType.number,
           textAlign: TextAlign.center,
           style: GoogleFonts.sora(
             fontSize: 48,
             fontWeight: FontWeight.w800,
             color: Colors.white
           ),
           decoration: const InputDecoration(border: InputBorder.none),
           onSubmitted: (val) => _submit(val),
           onTapOutside: (_) => _submit(_controller.text),
         ),
       );
    }

    return GestureDetector(
      onTap: () {
         _controller = TextEditingController(text: widget.bpm.toString());
         setState(() => _isEditing = true);
         // Request focus next frame
         Future.delayed(Duration.zero, () {
           _focusNode.requestFocus();
         });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
           // Minus
           IconButton(
             icon: const Icon(Icons.remove, color: Colors.white),
             onPressed: () => widget.onBpmChanged(widget.bpm - 1),
           ),
           Text(
             '${widget.bpm}',
             style: GoogleFonts.sora(
               fontSize: 48,
               fontWeight: FontWeight.w800,
               color: Colors.white,
             ),
           ),
           // Plus
           IconButton(
             icon: const Icon(Icons.add, color: Colors.white),
             onPressed: () => widget.onBpmChanged(widget.bpm + 1),
           ),
        ],
      ),
    );
  }

  void _submit(String val) {
    final int? newBpm = int.tryParse(val);
    if (newBpm != null) widget.onBpmChanged(newBpm);
    setState(() => _isEditing = false);
  }
}

class _ConfigSheet extends ConsumerWidget {
  const _ConfigSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rhythmProvider);
    final controller = ref.read(rhythmProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('Time Signature', style: GoogleFonts.manrope(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
           const SizedBox(height: 24),

           Row(
             children: [
               Expanded(
                 child: Column(
                   children: [
                     Text('Beats', style: GoogleFonts.manrope(color: Colors.white70)),
                     const SizedBox(height: 8),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                           onPressed: () {
                              if (state.timeSignature.numerator > 1) {
                                controller.setTimeSignature(
                                  TimeSignature(state.timeSignature.numerator - 1, state.timeSignature.denominator)
                                );
                              }
                           },
                         ),
                         const SizedBox(width: 8),
                         Text('${state.timeSignature.numerator}', style: GoogleFonts.sora(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                         const SizedBox(width: 8),
                         IconButton(
                           icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                           onPressed: () {
                              if (state.timeSignature.numerator < 16) {
                                controller.setTimeSignature(
                                  TimeSignature(state.timeSignature.numerator + 1, state.timeSignature.denominator)
                                );
                              }
                           },
                         ),
                       ],
                     ),
                   ],
                 ),
               ),
               Container(width: 1, height: 60, color: Colors.white24),
               Expanded(
                 child: Column(
                   children: [
                     Text('Unit', style: GoogleFonts.manrope(color: Colors.white70)),
                     const SizedBox(height: 8),
                     DropdownButton<int>(
                       value: state.timeSignature.denominator,
                       dropdownColor: const Color(0xFF333333),
                       underline: const SizedBox(),
                       style: GoogleFonts.sora(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                       icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                       onChanged: (val) {
                         if (val != null) {
                           controller.setTimeSignature(
                             TimeSignature(state.timeSignature.numerator, val)
                           );
                         }
                       },
                       items: [2, 4, 8, 16].map((d) {
                         return DropdownMenuItem(value: d, child: Text('$d'));
                       }).toList(),
                     ),
                   ],
                 ),
               ),
             ],
           ),
           const SizedBox(height: 48),
        ],
      ),
    );
  }
}
