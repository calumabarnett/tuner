import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuner/src/features/tuner/data/real_tuner_repository.dart';

abstract class TunerRepository {
  /// Stream of frequency detected (in Hz).
  Stream<double> getFrequencyStream();

  /// Starts the listening process.
  Future<void> start();

  /// Stops the listening process.
  Future<void> stop();
}

// TODO: Implement RealTunerRepository using pitch_detector_dart
class MockTunerRepository implements TunerRepository {
  bool _isListening = false;

  @override
  Stream<double> getFrequencyStream() async* {
    // Simulate a Sine Wave for A4 (440Hz) with some noise
    while (_isListening) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isListening) break;
      // Add small fluctuation
      yield 440.0 + (DateTime.now().millisecond % 10 - 5) * 0.2;
    }
  }

  @override
  Future<void> start() async {
    _isListening = true;
  }

  @override
  Future<void> stop() async {
    _isListening = false;
  }
}

final tunerRepositoryProvider = Provider<TunerRepository>((ref) {
  // We default to the Real Repository.
  // Tests can override this provider.
  // In a more complex app, we might check kDebugMode or a config flag.
  return RealTunerRepository();
});
