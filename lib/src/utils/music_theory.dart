import 'dart:math';

/// A class representing a musical note.
class MusicalNote {
  final String noteName;
  final int octave;
  final double centsDeviation;
  final double frequency;

  const MusicalNote({
    required this.noteName,
    required this.octave,
    required this.centsDeviation,
    required this.frequency,
  });

  @override
  String toString() {
    return '$noteName$octave ${centsDeviation.toStringAsFixed(1)} cents';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MusicalNote &&
      other.noteName == noteName &&
      other.octave == octave &&
      (other.centsDeviation - centsDeviation).abs() < 0.01 &&
      (other.frequency - frequency).abs() < 0.01;
  }

  @override
  int get hashCode => noteName.hashCode ^ octave.hashCode ^ centsDeviation.hashCode ^ frequency.hashCode;
}

class MusicTheory {
  static const List<String> _noteNames = [
    'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'
  ];

  static const double _a4Frequency = 440.0;

  /// Converts a frequency in Hz to a [MusicalNote].
  /// Returns null if the frequency is non-positive or too low to be useful.
  static MusicalNote? getNoteFromFrequency(double frequency) {
    if (frequency <= 0) return null;

    // Formula: MIDI Note Number = 69 + 12 * log2(f / 440)
    final double midiNoteDouble = 69 + 12 * (log(frequency / _a4Frequency) / ln2);
    final int midiNote = midiNoteDouble.round();

    final double cents = (midiNoteDouble - midiNote) * 100;

    // MIDI 0 is C-1 (approx 8.17 Hz)
    // midiNote % 12 gives the index in _noteNames (where C is 0)
    int noteIndex = midiNote % 12;
    if (noteIndex < 0) noteIndex += 12; // Handle negative midi notes safely

    final String noteName = _noteNames[noteIndex];
    // Octave: MIDI 60 is C4. (60 / 12) - 1 = 4.
    final int octave = (midiNote / 12).floor() - 1;

    return MusicalNote(
      noteName: noteName,
      octave: octave,
      centsDeviation: cents,
      frequency: frequency,
    );
  }
}
