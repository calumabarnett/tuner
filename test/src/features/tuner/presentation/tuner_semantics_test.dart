import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/tuner/presentation/note_display.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_gauge.dart';
import 'package:tuner/src/utils/music_theory.dart';

void main() {
  group('NoteDisplay Semantics', () {
    testWidgets('combines note name and octave with descriptive label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoteDisplay(
              noteName: 'C#',
              octave: 4,
              frequency: 277,
              isInTune: true,
            ),
          ),
        ),
      );

      // Ensure semantics are generated
      final handle = tester.ensureSemantics();

      // Should find a node with label "C Sharp 4"
      // Note: "C#" should be converted to "C Sharp" for better accessibility
      expect(find.bySemanticsLabel('C Sharp 4'), findsOneWidget);

      handle.dispose();
    });

    testWidgets('handles natural notes correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NoteDisplay(
              noteName: 'A',
              octave: 4,
              frequency: 440,
              isInTune: true,
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('A 4'), findsOneWidget);
      handle.dispose();
    });
  });

  group('TunerGauge Semantics', () {
    testWidgets('describes positive cents as sharp', (tester) async {
      const note = MusicalNote(
        noteName: 'A',
        octave: 4,
        centsDeviation: 5.0,
        frequency: 441.2,
        midiNumber: 69,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TunerGauge(note: note),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('5 cents sharp'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('describes negative cents as flat', (tester) async {
      const note = MusicalNote(
        noteName: 'A',
        octave: 4,
        centsDeviation: -3.0,
        frequency: 439.2,
        midiNumber: 69,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TunerGauge(note: note),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('3 cents flat'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('describes zero cents as perfect', (tester) async {
      const note = MusicalNote(
        noteName: 'A',
        octave: 4,
        centsDeviation: 0.0,
        frequency: 440.0,
        midiNumber: 69,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TunerGauge(note: note),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('0 cents perfect'), findsOneWidget);
      handle.dispose();
    });
  });
}
