import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/rhythm/domain/beat_state.dart';
import 'package:tuner/src/features/rhythm/presentation/components/solar_system_ring.dart';

void main() {
  testWidgets('SolarSystemRing renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SolarSystemRing(
            beatStates: const [BeatState.accent, BeatState.standard],
            isPlaying: false,
            bpm: 120,
            onOrbTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(SolarSystemRing), findsOneWidget);
  });
}
