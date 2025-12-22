import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/tone/data/tone_audio_service.dart';

void main() {
  group('ToneAudioService Security Tests', () {
    late ToneAudioService service;

    setUp(() {
      service = ToneAudioService();
    });

    test('isValidFrequency rejects NaN', () {
      expect(service.isValidFrequency(double.nan), false);
    });

    test('isValidFrequency rejects Infinity', () {
      expect(service.isValidFrequency(double.infinity), false);
      expect(service.isValidFrequency(double.negativeInfinity), false);
    });

    test('isValidFrequency rejects zero and negative values', () {
      expect(service.isValidFrequency(0), false);
      expect(service.isValidFrequency(-100.0), false);
      expect(service.isValidFrequency(-0.0001), false);
    });

    test('isValidFrequency accepts valid positive frequencies', () {
      expect(service.isValidFrequency(440.0), true);
      expect(service.isValidFrequency(0.1), true);
      expect(service.isValidFrequency(20000.0), true);
    });
  });
}
