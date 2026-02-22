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
    when(() => mockAudioService.start(any())).thenAnswer((_) async {});
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
    expect(state.isPlaying, false);
  });

  test('togglePlay starts and stops audio', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.togglePlay();
    expect(container.read(rhythmControllerProvider).isPlaying, true);
    verify(() => mockAudioService.start(120)).called(1);

    controller.togglePlay();
    expect(container.read(rhythmControllerProvider).isPlaying, false);
    verify(() => mockAudioService.stop()).called(1);
  });

  test('setBpm updates state and restarts audio if playing', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.setBpm(140);
    expect(container.read(rhythmControllerProvider).bpm, 140);
    verifyNever(() => mockAudioService.start(any()));

    controller.togglePlay();
    controller.setBpm(160);
    expect(container.read(rhythmControllerProvider).bpm, 160);
    verify(() => mockAudioService.start(160)).called(1);
  });

  test('setBpm clamps values', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.setBpm(10);
    expect(container.read(rhythmControllerProvider).bpm, 30);

    controller.setBpm(500);
    expect(container.read(rhythmControllerProvider).bpm, 300);
  });

  test('increment and decrement work', () {
    final controller = container.read(rhythmControllerProvider.notifier);

    controller.incrementBpm();
    expect(container.read(rhythmControllerProvider).bpm, 121);

    controller.decrementBpm();
    expect(container.read(rhythmControllerProvider).bpm, 120);
  });
}
