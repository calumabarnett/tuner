import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/tone/presentation/widgets/wave_ring.dart';

void main() {
  testWidgets('WaveRing should stop animation when not playing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WaveRing(isPlaying: false),
        ),
      ),
    );

    // Currently, WaveRing starts repeating in initState.
    // So pumpAndSettle should fail (timeout) because of the infinite loop.
    // We catch the error to confirm the "bug".

    bool timedOut = false;
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
    } catch (e) {
      timedOut = true;
    }

    // Now that we optimized it, it should NOT timeout.
    expect(timedOut, isFalse, reason: 'Animation should stop when not playing');
  });

  testWidgets('WaveRing animates when playing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WaveRing(isPlaying: true),
        ),
      ),
    );

    // Should be animating (infinite loop)
    // pumpAndSettle should timeout because the controller repeats
    bool timedOut = false;
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
    } catch (_) {
      timedOut = true;
    }
    expect(timedOut, isTrue, reason: 'Animation should run indefinitely when playing');
  });
}
