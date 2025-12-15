import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pitch_detector_dart/pitch_detector_dart.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:tuner/src/features/tuner/data/tuner_repository.dart';

class RealTunerRepository implements TunerRepository {
  final _audioCapture = FlutterAudioCapture();
  late final PitchDetector _pitchDetector;

  final StreamController<double> _controller = StreamController<double>.broadcast();

  RealTunerRepository() {
    _pitchDetector = PitchDetector(44100, 4096);
  }

  @override
  Stream<double> getFrequencyStream() {
    return _controller.stream;
  }

  @override
  Future<void> start() async {
    // Ensure we don't start multiple times
    try {
      await _audioCapture.start(
        _listener,
        _onError,
        sampleRate: 44100,
        bufferSize: 4096
      );
    } catch (e) {
      debugPrint('Error starting audio capture: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioCapture.stop();
    } catch (e) {
      debugPrint('Error stopping audio capture: $e');
    }
  }

  void _listener(dynamic obj) {
    // flutter_audio_capture returns Float32List or List<double> depending on platform/config
    // We need to check the type.
    // Documentation says it returns Float32List for AudioBuffer usually.

    var buffer = Float64List(0);

    // Convert to Float64List for pitch_detector_dart which likely expects List<double>
    if (obj is Float32List) {
      buffer = Float64List.fromList(obj);
    } else if (obj is List<double>) {
       buffer = Float64List.fromList(obj);
    } else if (obj is List<dynamic>) {
       buffer = Float64List.fromList(obj.cast<double>());
    }

    if (buffer.isNotEmpty) {
      final result = _pitchDetector.getPitch(buffer);

      // result.pitched is boolean, result.pitch is double frequency
      if (result.pitched) {
        _controller.add(result.pitch);
      }
    }
  }

  void _onError(Object e) {
    debugPrint('Audio capture error: $e');
  }
}
