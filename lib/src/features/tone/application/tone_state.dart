import 'package:equatable/equatable.dart';

class ToneState extends Equatable {
  final bool isPlaying;
  final int noteIndex; // 0 = C, 1 = C#/Db, ..., 11 = B
  final int octave; // 2 to 6
  final int transpositionIndex; // 0 = Concert Pitch, 1 = Bb, etc. (Index into a definition list)

  const ToneState({
    this.isPlaying = false,
    this.noteIndex = 0, // Default C
    this.octave = 4, // Default C4
    this.transpositionIndex = 0, // Default Concert Pitch
  });

  ToneState copyWith({
    bool? isPlaying,
    int? noteIndex,
    int? octave,
    int? transpositionIndex,
  }) {
    return ToneState(
      isPlaying: isPlaying ?? this.isPlaying,
      noteIndex: noteIndex ?? this.noteIndex,
      octave: octave ?? this.octave,
      transpositionIndex: transpositionIndex ?? this.transpositionIndex,
    );
  }

  @override
  List<Object> get props => [isPlaying, noteIndex, octave, transpositionIndex];
}
