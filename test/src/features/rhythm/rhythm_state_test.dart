import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/rhythm/presentation/rhythm_provider.dart';

void main() {
  group('RhythmState', () {
    test('supports value equality', () {
      expect(
        const RhythmState(),
        equals(const RhythmState()),
      );
    });

    test('copyWith updates fields', () {
      const state = RhythmState();
      expect(
        state.copyWith(bpm: 100).bpm,
        equals(100),
      );
      expect(
        state.copyWith(isPlaying: true).isPlaying,
        isTrue,
      );
    });
  });
}
