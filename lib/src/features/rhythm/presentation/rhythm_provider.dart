import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rhythm_engine.dart';

class RhythmState extends Equatable {
  final int bpm;
  final bool isPlaying;
  final int timeSignatureNumerator;
  final List<int> beatPatterns; // 0: Normal, 1: Accent, 2: Muted
  final int currentBeatIndex;

  const RhythmState({
    this.bpm = 120,
    this.isPlaying = false,
    this.timeSignatureNumerator = 4,
    this.beatPatterns = const [1, 0, 0, 0],
    this.currentBeatIndex = 0,
  });

  RhythmState copyWith({
    int? bpm,
    bool? isPlaying,
    int? timeSignatureNumerator,
    List<int>? beatPatterns,
    int? currentBeatIndex,
  }) {
    return RhythmState(
      bpm: bpm ?? this.bpm,
      isPlaying: isPlaying ?? this.isPlaying,
      timeSignatureNumerator:
          timeSignatureNumerator ?? this.timeSignatureNumerator,
      beatPatterns: beatPatterns ?? this.beatPatterns,
      currentBeatIndex: currentBeatIndex ?? this.currentBeatIndex,
    );
  }

  @override
  List<Object> get props => [
        bpm,
        isPlaying,
        timeSignatureNumerator,
        beatPatterns,
        currentBeatIndex
      ];
}

class RhythmNotifier extends Notifier<RhythmState> {
  late final RhythmEngine _engine;

  @override
  RhythmState build() {
    _engine = RhythmEngine();
    _engine.init(); // Fire and forget init
    _engine.onBeat = _onBeat;
    return const RhythmState();
  }

  void _onBeat(int beatIndex) {
    state = state.copyWith(currentBeatIndex: beatIndex);
  }

  void togglePlay() {
    if (state.isPlaying) {
      _engine.stop();
      state = state.copyWith(isPlaying: false);
    } else {
      _engine.setBpm(state.bpm);
      _engine.updateBeatPattern(state.beatPatterns);
      _engine.play();
      state = state.copyWith(isPlaying: true);
    }
  }

  void setBpm(int bpm) {
    if (bpm < 1 || bpm > 300) return;
    _engine.setBpm(bpm);
    state = state.copyWith(bpm: bpm);
  }

  void incrementBpm() => setBpm(state.bpm + 1);
  void decrementBpm() => setBpm(state.bpm - 1);

  void setTimeSignature(int numerator) {
    // Generate default pattern
    // e.g. 4 -> 1,0,0,0
    // 3 -> 1,0,0
    // 5 -> 1,0,0,1,0 (3+2) or just 1,0,0,0,0
    // Prompt: "Selecting a complex meter (e.g., 7/8) should apply a sensible default accent pattern (e.g., 3+2+2)."

    List<int> newPattern;
    if (numerator == 4) {
      newPattern = [1, 0, 0, 0];
    } else if (numerator == 3) {
      newPattern = [1, 0, 0];
    } else if (numerator == 6) {
      newPattern = [1, 0, 0, 1, 0, 0]; // 3+3
    } else if (numerator == 5) {
      newPattern = [1, 0, 0, 1, 0]; // 3+2
    } else if (numerator == 7) {
      newPattern = [1, 0, 0, 1, 0, 1, 0]; // 3+2+2
    } else {
      newPattern = List.generate(numerator, (i) => i == 0 ? 1 : 0);
    }

    state = state.copyWith(
      timeSignatureNumerator: numerator,
      beatPatterns: newPattern,
      currentBeatIndex: 0,
    );
    _engine.updateBeatPattern(newPattern);
    if (state.isPlaying) {
       // Restart play to sync pattern? Or just update.
       // Engine handles updateBeatPattern.
       // We might want to reset beat index in engine or let it flow?
       // Usually changing TS resets the measure.
       // Engine updateBeatPattern resets if index out of bounds, but ideally we reset to 1.
    }
  }

  void toggleBeatAccent(int index) {
    if (index < 0 || index >= state.beatPatterns.length) return;
    final newPatterns = List<int>.from(state.beatPatterns);
    // Cycle: 0 (Normal) -> 1 (Accent) -> 2 (Muted) -> 0
    // Wait, prompt says: "Tapping ... cycles: Accent (1) -> Standard (0) -> Muted (2)"?
    // "Accent: Solid White (High pitch). Standard: Outlined White Stroke. Muted: Dimmed."
    // Let's assume order: Accent -> Standard -> Muted -> Accent
    // Current default is 1 (Accent) for first beat.

    final current = newPatterns[index];
    int next;
    if (current == 1) {
      next = 0; // Accent -> Standard
    } else if (current == 0) {
      next = 2; // Standard -> Muted
    } else {
      next = 1; // Muted -> Accent
    }

    newPatterns[index] = next;
    state = state.copyWith(beatPatterns: newPatterns);
    _engine.updateBeatPattern(newPatterns);
  }
}

final rhythmProvider = NotifierProvider<RhythmNotifier, RhythmState>(() {
  return RhythmNotifier();
});
