import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/tone/presentation/widgets/wave_ring.dart';

void main() {
  testWidgets('WaveRing stops animating when isPlaying is false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WaveRing(isPlaying: false),
        ),
      ),
    );

    // This should complete if there are no ongoing animations.
    // Current implementation: _controller.repeat() starts in initState.
    // So this is expected to fail with a timeout.
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
  });
}
