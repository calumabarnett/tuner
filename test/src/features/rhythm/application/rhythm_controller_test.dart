import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tuner/src/features/rhythm/application/rhythm_controller.dart';
import 'package:tuner/src/features/rhythm/data/rhythm_audio_service.dart';

class MockRhythmAudioService extends Mock implements RhythmAudioService {}

void main() {
  late MockRhythmAudioService mockAudioService;
  late ProviderContainer container;

  setUp(() {
    mockAudioService = MockRhythmAudioService();
    when(() => mockAudioService.init()).thenAnswer((_) async {});
    when(() => mockAudioService.start(
          bpm: any(named: 'bpm'),
          beatsPerMeasure: any(named: 'beatsPerMeasure'),
          beatUnit: any(named: 'beatUnit'),
          subdivision: any(named: 'subdivision'),
          accents: any(named: 'accents'),
        )).thenAnswer((_) async {});
    when(() => mockAudioService.stop()).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        rhythmAudioServiceProvider.overrideWithValue(mockAudioService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state is correct', () {
    final state = container.read(rhythmControllerProvider);
    expect(state.bpm, 120);
    expect(state.beatsPerMeasure, 4);
    expect(state.accents[0], true);
    expect(state.isPlaying, false);
  });

  test('togglePlay starts and stops audio', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.togglePlay();
    expect(container.read(rhythmControllerProvider).isPlaying, true);
    verify(() => mockAudioService.start(
          bpm: 120,
          beatsPerMeasure: 4,
          beatUnit: 4,
          subdivision: 1,
          accents: any(named: 'accents'),
        )).called(1);

    controller.togglePlay();
    expect(container.read(rhythmControllerProvider).isPlaying, false);
    verify(() => mockAudioService.stop()).called(1);
  });

  test('setBeatsPerMeasure updates state and accents', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.setBeatsPerMeasure(3);
    final state = container.read(rhythmControllerProvider);
    expect(state.beatsPerMeasure, 3);
    expect(state.accents.length, 3);
  });

  test('toggleAccent updates accents list', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.toggleAccent(1);
    expect(container.read(rhythmControllerProvider).accents[1], true);

    controller.toggleAccent(1);
    expect(container.read(rhythmControllerProvider).accents[1], false);
  });

  test('setPreset updates signature and resets accents', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.setPreset(6, 8);
    final state = container.read(rhythmControllerProvider);
    expect(state.beatsPerMeasure, 6);
    expect(state.beatUnit, 8);
    expect(state.accents[0], true);
    expect(state.accents[1], false);
  });
}
