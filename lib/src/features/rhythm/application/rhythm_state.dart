import 'package:equatable/equatable.dart';

class RhythmState extends Equatable {
  final int bpm;
  final bool isPlaying;

  const RhythmState({
    this.bpm = 120,
    this.isPlaying = false,
  });

  RhythmState copyWith({
    int? bpm,
    bool? isPlaying,
  }) {
    return RhythmState(
      bpm: bpm ?? this.bpm,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  @override
  List<Object?> get props => [bpm, isPlaying];
}
