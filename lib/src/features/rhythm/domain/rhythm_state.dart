import 'package:equatable/equatable.dart';
import 'beat_state.dart';
import 'time_signature.dart';
import 'sound_profile.dart';

class RhythmState extends Equatable {
  final bool isPlaying;
  final int bpm;
  final TimeSignature timeSignature;
  final List<BeatState> beatPattern;
  final SoundProfile soundProfile;

  // Audio sync timestamp. Null if stopped.
  // Using microseconds for high precision sync.
  final int? startTimeMicroseconds;

  const RhythmState({
    required this.isPlaying,
    required this.bpm,
    required this.timeSignature,
    required this.beatPattern,
    required this.soundProfile,
    this.startTimeMicroseconds,
  });

  factory RhythmState.initial() {
    return const RhythmState(
      isPlaying: false,
      bpm: 120,
      timeSignature: TimeSignature.fourFour,
      beatPattern: [
        BeatState.accent,
        BeatState.standard,
        BeatState.standard,
        BeatState.standard
      ],
      soundProfile: SoundProfile.digitalClick,
      startTimeMicroseconds: null,
    );
  }

  RhythmState copyWith({
    bool? isPlaying,
    int? bpm,
    TimeSignature? timeSignature,
    List<BeatState>? beatPattern,
    SoundProfile? soundProfile,
    int? startTimeMicroseconds,
  }) {
    return RhythmState(
      isPlaying: isPlaying ?? this.isPlaying,
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      beatPattern: beatPattern ?? this.beatPattern,
      soundProfile: soundProfile ?? this.soundProfile,
      startTimeMicroseconds: startTimeMicroseconds ?? this.startTimeMicroseconds,
    );
  }

  @override
  List<Object?> get props => [
        isPlaying,
        bpm,
        timeSignature,
        beatPattern,
        soundProfile,
        startTimeMicroseconds,
      ];
}
