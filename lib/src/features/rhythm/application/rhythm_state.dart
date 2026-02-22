import 'package:equatable/equatable.dart';

class RhythmState extends Equatable {
  final int bpm;
  final bool isPlaying;
  final int beatsPerMeasure;
  final int beatUnit;
  final int subdivision;
  final List<bool> accents;

  const RhythmState({
    this.bpm = 120,
    this.isPlaying = false,
    this.beatsPerMeasure = 4,
    this.beatUnit = 4,
    this.subdivision = 1,
    this.accents = const [true, false, false, false],
  });

  RhythmState copyWith({
    int? bpm,
    bool? isPlaying,
    int? beatsPerMeasure,
    int? beatUnit,
    int? subdivision,
    List<bool>? accents,
  }) {
    return RhythmState(
      bpm: bpm ?? this.bpm,
      isPlaying: isPlaying ?? this.isPlaying,
      beatsPerMeasure: beatsPerMeasure ?? this.beatsPerMeasure,
      beatUnit: beatUnit ?? this.beatUnit,
      subdivision: subdivision ?? this.subdivision,
      accents: accents ?? this.accents,
    );
  }

  @override
  List<Object?> get props => [
        bpm,
        isPlaying,
        beatsPerMeasure,
        beatUnit,
        subdivision,
        accents,
      ];
}
