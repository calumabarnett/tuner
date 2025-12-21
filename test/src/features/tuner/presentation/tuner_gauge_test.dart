import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_gauge.dart';
import 'package:tuner/src/utils/music_theory.dart';

void main() {
  testWidgets('TunerGauge renders correctly', (tester) async {
    const note = MusicalNote(
      noteName: 'A',
      octave: 4,
      centsDeviation: 0,
      frequency: 440.0,
      midiNumber: 69,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 300,
          height: 300,
          child: TunerGauge(note: note),
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.text('0 ct'), findsOneWidget);
  });
}
