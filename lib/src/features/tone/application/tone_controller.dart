import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tone_audio_service.dart';
import 'tone_state.dart';

final toneControllerProvider = NotifierProvider<ToneController, ToneState>(ToneController.new);

class ToneController extends Notifier<ToneState> {
  late final ToneAudioService _audioService;

  // Transposition Definitions (Name, Semitone Offset from Concert Pitch)
  // Updated to include consistent enharmonic pairs.
  // Using unicode sharps/flats to match Grid if possible, or standard.
  // The Grid uses: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
  // And displays "C♯/D♭".
  // So we should use "C♯ / D♭" here for consistency in the menu.

  static const List<Map<String, dynamic>> transpositions = [
    {'name': 'Concert Pitch (C)', 'offset': 0},
    {'name': 'D♭ / C♯', 'offset': 1},
    {'name': 'D', 'offset': 2},
    {'name': 'E♭ / D♯', 'offset': 3},
    {'name': 'E', 'offset': 4},
    {'name': 'F', 'offset': 5},
    {'name': 'G♭ / F♯', 'offset': 6},
    {'name': 'G', 'offset': 7},
    {'name': 'A♭ / G♯', 'offset': 8},
    {'name': 'A', 'offset': 9},
    {'name': 'B♭ / A♯', 'offset': 10},
    {'name': 'B', 'offset': 11},
  ];

  @override
  ToneState build() {
    _audioService = ref.read(toneAudioServiceProvider);
    _initAudio();
    return const ToneState();
  }

  Future<void> _initAudio() async {
    await _audioService.init();
  }

  void togglePlay() {
    if (state.isPlaying) {
      _audioService.stop();
      state = state.copyWith(isPlaying: false);
    } else {
      // Ensure frequency is set before unmuting
      _playCurrentNote();
      state = state.copyWith(isPlaying: true);
    }
  }

  void selectNote(int index) {
    state = state.copyWith(noteIndex: index);
    if (state.isPlaying) {
      _playCurrentNote();
    }
  }

  void setOctave(int octave) {
    if (octave < 2 || octave > 6) return;
    state = state.copyWith(octave: octave);
    if (state.isPlaying) {
      _playCurrentNote();
    }
  }

  void setTransposition(int index) {
    state = state.copyWith(transpositionIndex: index);
  }

  void startMomentary(int index) {
    selectNote(index);
    if (!state.isPlaying) {
       state = state.copyWith(isPlaying: true);
       _playCurrentNote();
    }
  }

  void stopMomentary() {
    state = state.copyWith(isPlaying: false);
    _audioService.stop();
  }

  void _playCurrentNote() {
    final freq = _calculateFrequency(state.noteIndex, state.octave);
    _audioService.play(freq);
  }

  double _calculateFrequency(int noteIndex, int octave) {
    // A4 = 440Hz.
    // A is index 9.
    final int semitonesFromA4 = (octave - 4) * 12 + (noteIndex - 9);
    return 440.0 * pow(2.0, semitonesFromA4 / 12.0);
  }
}
