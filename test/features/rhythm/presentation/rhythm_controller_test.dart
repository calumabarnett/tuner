// ignore_for_file: deprecated_member_use
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tuner/src/features/rhythm/data/rhythm_engine.dart';
import 'package:tuner/src/features/rhythm/domain/beat_state.dart';
import 'package:tuner/src/features/rhythm/domain/rhythm_state.dart';
import 'package:tuner/src/features/rhythm/domain/time_signature.dart';
import 'package:tuner/src/features/rhythm/presentation/rhythm_controller.dart';

class MockRhythmEngine extends Mock implements RhythmEngine {}

void main() {
  late MockRhythmEngine mockEngine;
  late RhythmController controller;

  setUpAll(() {
    registerFallbackValue(<BeatState>[]);
  });

  setUp(() {
    mockEngine = MockRhythmEngine();
    when(() => mockEngine.init()).thenAnswer((_) async {});
    when(() => mockEngine.startTimeMicroseconds).thenReturn(0);
    when(() => mockEngine.setBpm(any())).thenReturn(null);
    when(() => mockEngine.setPattern(any())).thenReturn(null);
    when(() => mockEngine.start()).thenReturn(null);
    when(() => mockEngine.stop()).thenReturn(null);

    controller = RhythmController(mockEngine);
  });

  test('initial state is correct', () {
    expect(controller.debugState, RhythmState.initial());
  });

  test('setBpm updates state and engine', () {
    controller.setBpm(140);
    expect(controller.debugState.bpm, 140);
    verify(() => mockEngine.setBpm(140)).called(1);
  });

  test('togglePlay starts engine if stopped', () {
    controller.togglePlay(); // Start
    expect(controller.debugState.isPlaying, true);
    verify(() => mockEngine.start()).called(1);

    controller.togglePlay(); // Stop
    expect(controller.debugState.isPlaying, false);
    verify(() => mockEngine.stop()).called(1);
  });

  test('setTimeSignature updates pattern with defaults', () {
    // 7/8 -> 2+2+3
    controller.setTimeSignature(const TimeSignature(7, 8));
    final pattern = controller.debugState.beatPattern;
    expect(pattern.length, 7);
    expect(pattern[0], BeatState.accent);
    expect(pattern[1], BeatState.standard);
    expect(pattern[2], BeatState.accent);
    expect(pattern[3], BeatState.standard);
    expect(pattern[4], BeatState.accent);
  });
}
