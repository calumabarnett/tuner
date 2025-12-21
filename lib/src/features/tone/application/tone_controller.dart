import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tone_audio_service.dart';
import 'tone_state.dart';

class ToneController extends Notifier<ToneState> {
  late final ToneAudioService _audioService;

  // Transposition Definitions (Name, Semitone Offset from Concert Pitch)
  // Logic: "Transposed to X" means "Written C sounds like Concert X".
  // Offset = Concert - Written.
  // Example: Bb Instrument (Trumpet). Written C = Concert Bb.
  // Concert Bb is -2 semitones from C.
  // Offset = -2.
  static const List<Map<String, dynamic>> transpositions = [
    {'name': 'Concert Pitch (C)', 'offset': 0},
    {'name': 'Db / C#', 'offset': 1}, // Written C = Concert Db (+1)
    {'name': 'D', 'offset': 2}, // Written C = Concert D (+2)
    {'name': 'Eb', 'offset': 3}, // Written C = Concert Eb (+3) ... Wait. usually Eb Alto Sax: Written C = Concert Eb (Major 6th lower? or Minor 3rd higher?). Standard definition: "Transposition Interval" is interval from Written C to Concert Sound.
    // Bb Trumpet: Written C -> Concert Bb (Major 2nd DOWN). Offset -2.
    // Eb Alto Sax: Written C -> Concert Eb (Major 6th DOWN). Offset -9? Or +3?
    // Let's stick to the KEY names. If I select "Eb", I expect "Written C" to sound like "Concert Eb".
    // Whether it's Eb4 or Eb3 depends on the instrument range, but strictly pitch class: Eb is +3 semitones from C (or -9).
    // Let's use standard chromatic offsets relative to C.
    // Db: +1
    // D: +2
    // Eb: +3
    // E: +4
    // F: +5
    // Gb: +6
    // G: +7 (or -5)
    // Ab: +8 (or -4)
    // A: +9 (or -3)
    // Bb: +10 (or -2)
    // B: +11 (or -1)

    // However, typical instruments:
    // F Horn: Written C -> Concert F (Perfect 5th Down). -7.
    // Bb Trumpet: Written C -> Concert Bb (Maj 2nd Down). -2.
    // Eb Alto Sax: Written C -> Concert Eb (Maj 6th Down). +3 (relative to C4? No, Eb3).

    // The user asked for "any key to be selected". So let's just list keys chromatically.
    // It's safer to treat "Key of X" as "Written C = Concert X".
    // We will normalize to nearest octave offsets (-6 to +5 or 0 to 11).
    // Let's use 0 to 11 for simplicity, unless "downward" is expected.
    // Let's use specific known offsets for standard keys if possible, but generic for others?
    // No, consistent chromatic list is better.
    // C=0.
    // Db=1.
    // D=2.
    // Eb=3.
    // E=4.
    // F=5.
    // Gb=6.
    // G=7.
    // Ab=8.
    // A=9.
    // Bb=10.
    // B=11.

    // Wait, Bb Trumpet is usually considered -2.
    // If we use +10, Written C (0) -> Concert Bb (10).
    // Concert Bb (10) is higher than C (0).
    // Trumpet sounds LOWER.
    // But does it matter for a Pitch Pipe?
    // If I press "C", I hear "Bb".
    // If I hear a high Bb or low Bb, it's still Bb.
    // The user has Octave control.
    // So let's stick to 0-11 positive mod offsets for simplicity, effectively "Transposition Key".

    {'name': 'E', 'offset': 4},
    {'name': 'F', 'offset': 5},
    {'name': 'Gb / F#', 'offset': 6},
    {'name': 'G', 'offset': 7},
    {'name': 'Ab / G#', 'offset': 8},
    {'name': 'A', 'offset': 9},
    {'name': 'Bb', 'offset': 10},
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
    state = state.copyWith(transpositionIndex: index);
    // Note: Audio pitch (Concert) remains same?
    // State stores CONCERT pitch index (0-11).
    // UI calculates Written pitch.
    // If I change transposition:
    // Concert Pitch remains same (e.g. 440Hz).
    // Written Pitch changes (e.g. "A" becomes "B" if switching to Bb Transposition).
    // This matches requirement.
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

final toneControllerProvider = NotifierProvider<ToneController, ToneState>(ToneController.new);
