import 'dart:typed_data';

import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tuner/src/features/tone/data/tone_audio_service.dart';

class MockSoLoud extends Mock implements SoLoud {
  @override
  void setInaudibleBehavior(SoundHandle handle, bool mustStop, bool mustPause) {}
}
class MockAudioSource extends Mock implements AudioSource {}

void main() {
  late ToneAudioService service;
  late MockSoLoud mockSoLoud;
  late MockAudioSource mockAudioSource;
  late SoundHandle fakeSoundHandle;

  setUpAll(() {
    registerFallbackValue(MockAudioSource());
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(Duration.zero);
  });

  setUp(() async {
    mockSoLoud = MockSoLoud();
    mockAudioSource = MockAudioSource();
    service = ToneAudioService();

    // SoundHandle is a value class/struct.
    try {
      fakeSoundHandle = const SoundHandle(1);
    } catch (e) {
       // If const constructor fails, try default or factory?
       // Based on successful compilation before, this is fine.
       // However, to be safe against runtime errors in setUp:
       fakeSoundHandle = const SoundHandle(1);
    }

    // Stub init
    when(() => mockSoLoud.init()).thenAnswer((_) async => {});

    // Stub loadMem
    when(() => mockSoLoud.loadMem(any(), any())).thenAnswer((_) async => mockAudioSource);

    // Stub play
    // Match exact arguments used in ToneAudioService to avoid 'any' matcher issues
    when(() => mockSoLoud.play(
      any(),
      looping: true,
      volume: 0.0,
      loopingStartAt: Duration.zero,
      paused: false,
    )).thenAnswer((_) async => fakeSoundHandle);

    // Stub getIsValidVoiceHandle
    when(() => mockSoLoud.getIsValidVoiceHandle(any())).thenReturn(true);

    // Stub setRelativePlaySpeed
    when(() => mockSoLoud.setRelativePlaySpeed(any(), any())).thenReturn(null);

    // Stub setVolume
    when(() => mockSoLoud.setVolume(any(), any())).thenReturn(null);

    // Initialize the service
    await service.init(soloudInstance: mockSoLoud);
  });

  group('ToneAudioService Security Tests', () {
    test('play should not set speed for negative frequency', () async {
      await service.play(-440.0);

      // Verify setRelativePlaySpeed was NOT called
      verifyNever(() => mockSoLoud.setRelativePlaySpeed(any(), any()));
    });

    test('play should not set speed for zero frequency', () async {
      await service.play(0.0);
      verifyNever(() => mockSoLoud.setRelativePlaySpeed(any(), any()));
    });

    test('play should not set speed for infinite frequency', () async {
      await service.play(double.infinity);
      verifyNever(() => mockSoLoud.setRelativePlaySpeed(any(), any()));
    });

    test('play should not set speed for NaN frequency', () async {
      await service.play(double.nan);
      verifyNever(() => mockSoLoud.setRelativePlaySpeed(any(), any()));
    });

    test('play should call setRelativePlaySpeed for valid frequency', () async {
      await service.play(440.0);
      verify(() => mockSoLoud.setRelativePlaySpeed(any(), 1.0)).called(1);
    });

    test('setFrequency should not set speed for negative frequency', () {
      service.setFrequency(-100.0);
      verifyNever(() => mockSoLoud.setRelativePlaySpeed(any(), any()));
    });

    test('setFrequency should not set speed for NaN', () {
      service.setFrequency(double.nan);
      verifyNever(() => mockSoLoud.setRelativePlaySpeed(any(), any()));
    });
  });
}
