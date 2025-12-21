import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rhythm_engine.dart';
import '../domain/beat_state.dart';
import '../domain/rhythm_state.dart';
import '../domain/sound_profile.dart';
import '../domain/time_signature.dart';

class RhythmController extends StateNotifier<RhythmState> {
  final RhythmEngine _engine;
  DateTime? _lastTapTime;

  RhythmController(this._engine) : super(RhythmState.initial()) {
    _engine.init();
  }

  void togglePlay() {
    if (state.isPlaying) {
      _engine.stop();
      state = state.copyWith(
        isPlaying: false,
        startTimeMicroseconds: null,
      );
    } else {
      _engine.setBpm(state.bpm);
      _engine.setPattern(state.beatPattern);
      _engine.start();
      state = state.copyWith(
        isPlaying: true,
        startTimeMicroseconds: _engine.startTimeMicroseconds,
      );
    }
  }

  void setBpm(int bpm) {
    if (bpm < 20 || bpm > 300) return;
    _engine.setBpm(bpm);
    state = state.copyWith(bpm: bpm);
  }

  void setSoundProfile(SoundProfile profile) {
    _engine.setSoundProfile(profile);
    state = state.copyWith(soundProfile: profile);
  }

  void tapTempo() {
    final now = DateTime.now();
    if (_lastTapTime != null) {
      final diff = now.difference(_lastTapTime!).inMilliseconds;
      if (diff > 200 && diff < 3000) {
        final newBpm = (60000 / diff).round();
        setBpm(newBpm);
      }
    }
    _lastTapTime = now;
  }

  void setTimeSignature(TimeSignature signature) {
    final List<BeatState> newPattern = _generatePattern(signature);

    _engine.setPattern(newPattern);

    state = state.copyWith(
      timeSignature: signature,
      beatPattern: newPattern,
    );
  }

  void cycleBeatState(int index) {
    if (index < 0 || index >= state.beatPattern.length) return;

    final current = state.beatPattern[index];
    BeatState next;
    switch (current) {
      case BeatState.accent:
        next = BeatState.standard;
        break;
      case BeatState.standard:
        next = BeatState.mute;
        break;
      case BeatState.mute:
        next = BeatState.accent;
        break;
    }

    final newPattern = List<BeatState>.from(state.beatPattern);
    newPattern[index] = next;

    _engine.setPattern(newPattern);
    state = state.copyWith(beatPattern: newPattern);
  }

  List<BeatState> _generatePattern(TimeSignature sig) {
    final n = sig.numerator;
    final d = sig.denominator;
    // Default: all standard, first accent
    final pattern = List.filled(n, BeatState.standard);
    pattern[0] = BeatState.accent;

    if (d == 8) {
      if (n == 5) { // 3+2
         if (n > 3) pattern[3] = BeatState.accent;
      } else if (n == 7) { // 2+2+3
         if (n > 2) pattern[2] = BeatState.accent;
         if (n > 4) pattern[4] = BeatState.accent;
      } else if (n == 9) { // 3+3+3
         if (n > 3) pattern[3] = BeatState.accent;
         if (n > 6) pattern[6] = BeatState.accent;
      }
      else if (n == 12) { // 3+3+3+3
         if (n > 3) pattern[3] = BeatState.accent;
         if (n > 6) pattern[6] = BeatState.accent;
         if (n > 9) pattern[9] = BeatState.accent;
      }
    }

    return pattern;
  }
}

final rhythmProvider = StateNotifierProvider<RhythmController, RhythmState>((ref) {
  final engine = ref.watch(rhythmEngineProvider);
  return RhythmController(engine);
});
