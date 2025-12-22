import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tone_audio_service.dart';
import 'tone_state.dart';

final toneControllerProvider = NotifierProvider<ToneController, ToneState>(ToneController.new);

class ToneController extends Notifier<ToneState> {
  late final ToneAudioService _audioService;

  // Transposition Definitions (Name, Semitone Offset from Concert Pitch)
  // "Key of X" means "Written C sounds like Concert X".
  // Offset = Concert - Written.
  // So: Concert = Written + Offset.

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
    // When changing transposition:
    // User wants "Written Note" to remain selected.
    // state.noteIndex is Written Note.
    // So we just update transpositionIndex.
    // The Audio Pitch (Concert) will change.

    state = state.copyWith(transpositionIndex: index);
    if (state.isPlaying) {
      _playCurrentNote();
    }
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
    final freq = _calculateFrequency(state.noteIndex, state.octave, state.transpositionIndex);
    _audioService.play(freq);
  }

  double _calculateFrequency(int writtenNoteIndex, int octave, int transIndex) {
    // Concert Note = Written Note + Offset
    final offset = transpositions[transIndex]['offset'] as int;

    // We calculate semitones from A4 (440Hz).
    // A4 is Concert A (Index 9).

    // Convert Written to Concert
    // Note: This logic adds offset. e.g. Written C (0) + Bb Offset (10) = Concert Bb (10).
    // Written C (0) + F Offset (5) = Concert F (5).
    // This seems correct for "Key of X".

    // Adjust octave if wrapping around?
    // e.g. Written B (11) + D (2) = 13 (C# in next octave).
    // Or do we just calculate total semitones?

    // Let's do total semitones relative to C4.
    // C4 is index 0 in octave 4.
    // Written Note 0 (C) Octave 4.

    // Total Semitones from C4 = (octave - 4) * 12 + writtenNoteIndex + offset.
    // A4 is +9 semitones from C4.
    // So Semitones from A4 = Total - 9.

    final int totalSemitonesFromC4 = (octave - 4) * 12 + writtenNoteIndex + offset;
    final int semitonesFromA4 = totalSemitonesFromC4 - 9;

    return 440.0 * pow(2.0, semitonesFromA4 / 12.0);
  }
}
