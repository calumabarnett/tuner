import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/utils/music_theory.dart';

void main() {
  group('MusicTheory Tests', () {
    test('A4 (440Hz) is correctly identified', () {
      final note = MusicTheory.getNoteFromFrequency(440.0);
      expect(note, isNotNull);
      expect(note!.noteName, 'A');
      expect(note.octave, 4);
      expect(note.centsDeviation, closeTo(0, 0.1));
    });

    test('C4 (Middle C ~261.63Hz) is correctly identified', () {
      // MIDI 60 is C4
      // 440 * 2^((60-69)/12) = 261.625565
      final note = MusicTheory.getNoteFromFrequency(261.63);
      expect(note, isNotNull);
      expect(note!.noteName, 'C');
      expect(note.octave, 4);
      expect(note.centsDeviation, closeTo(0, 0.1));
    });

    test('A#4 / Bb4 (~466.16Hz) is correctly identified', () {
      final note = MusicTheory.getNoteFromFrequency(466.16);
      expect(note, isNotNull);
      expect(note!.noteName, 'A#');
      expect(note.octave, 4);
      expect(note.centsDeviation, closeTo(0, 0.1));
    });

    test('Handling slightly sharp note (A4 + 10 cents)', () {
       // 440 * 2^(10/1200) = 442.54 roughly
       final note = MusicTheory.getNoteFromFrequency(442.55);
       expect(note, isNotNull);
       expect(note!.noteName, 'A');
       expect(note.octave, 4);
       // Should be roughly +10 cents
       expect(note.centsDeviation, closeTo(10, 0.1));
    });

    test('Handling slightly flat note (A4 - 10 cents)', () {
       // 440 * 2^(-10/1200) = 437.47 roughly
       final note = MusicTheory.getNoteFromFrequency(437.47);
       expect(note, isNotNull);
       expect(note!.noteName, 'A');
       expect(note.octave, 4);
       // Should be roughly -10 cents
       expect(note.centsDeviation, closeTo(-10, 0.1));
    });

    test('Low frequency edge case', () {
      final note = MusicTheory.getNoteFromFrequency(27.5); // A0
      expect(note, isNotNull);
      expect(note!.noteName, 'A');
      expect(note.octave, 0);
    });

    test('Zero or negative frequency returns null', () {
      expect(MusicTheory.getNoteFromFrequency(0), isNull);
      expect(MusicTheory.getNoteFromFrequency(-100), isNull);
    });
  });
}
