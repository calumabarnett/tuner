import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tuner/src/features/tone/application/tone_controller.dart';
import 'package:tuner/src/features/tone/data/tone_audio_service.dart';

class MockToneAudioService extends Mock implements ToneAudioService {}

void main() {
  late MockToneAudioService mockAudioService;
  late ProviderContainer container;

  setUp(() {
    mockAudioService = MockToneAudioService();
    when(() => mockAudioService.init()).thenAnswer((_) async {});
    when(() => mockAudioService.play(any())).thenAnswer((_) async {});
    when(() => mockAudioService.stop()).thenAnswer((_) {});
    when(() => mockAudioService.setFrequency(any())).thenAnswer((_) {});

    container = ProviderContainer(
      overrides: [
        toneAudioServiceProvider.overrideWithValue(mockAudioService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('ToneController initializes and audio service init is called', () {
    container.read(toneControllerProvider);
    // build is called immediately? Notifier build is lazy?
    // Notifier build is called on first read/watch.
    verify(() => mockAudioService.init()).called(1);
  });

  test('togglePlay calls play/stop', () {
    final controller = container.read(toneControllerProvider.notifier);

    // Initially false
    expect(container.read(toneControllerProvider).isPlaying, false);

    // Toggle On
    controller.togglePlay();
    expect(container.read(toneControllerProvider).isPlaying, true);
    verify(() => mockAudioService.play(any())).called(1);

    // Toggle Off
    controller.togglePlay();
    expect(container.read(toneControllerProvider).isPlaying, false);
    verify(() => mockAudioService.stop()).called(1);
  });

  test('selectNote updates state and updates audio if playing', () {
    final controller = container.read(toneControllerProvider.notifier);

    // Select note while stopped
    controller.selectNote(2); // D
    expect(container.read(toneControllerProvider).noteIndex, 2);
    verifyNever(() => mockAudioService.play(any()));

    // Start playing
    controller.togglePlay();
    clearInteractions(mockAudioService);

    // Select note while playing
    controller.selectNote(4); // E
    expect(container.read(toneControllerProvider).noteIndex, 4);
    verify(() => mockAudioService.play(any())).called(1);
  });

  test('setTransposition updates state', () {
    final controller = container.read(toneControllerProvider.notifier);
    controller.setTransposition(1);
    expect(container.read(toneControllerProvider).transpositionIndex, 1);
  });
}
