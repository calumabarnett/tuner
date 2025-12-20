import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_audio_capture/flutter_audio_capture.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:tuner/src/features/tuner/data/tuner_repository.dart';

class RealTunerRepository implements TunerRepository {
  final _audioCapture = FlutterAudioCapture();
  late final PitchDetector _pitchDetector;

  final StreamController<double> _controller = StreamController<double>.broadcast();

  // Smoothing state
  double? _prevFrequency;
  final double _alpha = 0.2; // Smoothing factor
  final double _probabilityThreshold = 0.95; // High threshold for noise

  RealTunerRepository() {
    _pitchDetector = PitchDetector();
  }

  @override
  Stream<double> getFrequencyStream() {
    return _controller.stream;
  }

  @override
  Future<void> start() async {
    _prevFrequency = null;
    try {
      await _audioCapture.init();
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
    var buffer = Float64List(0);

    if (obj is Float32List) {
      buffer = Float64List.fromList(obj);
    } else if (obj is List<double>) {
       buffer = Float64List.fromList(obj);
    } else if (obj is List<dynamic>) {
       buffer = Float64List.fromList(obj.cast<double>());
    }

    if (buffer.isNotEmpty) {
      _pitchDetector.getPitchFromFloatBuffer(buffer).then((result) {
        if (result.pitched && result.probability >= _probabilityThreshold) {
          final double newFreq = result.pitch;

          if (_prevFrequency == null) {
            _prevFrequency = newFreq;
          } else {
            // Check for large jump (e.g. potential new note or octave error)
            // If difference is > 20Hz, snap to new value.
            if ((newFreq - _prevFrequency!).abs() > 20.0) {
              _prevFrequency = newFreq;
            } else {
              // Apply EMA
              _prevFrequency = _prevFrequency! + _alpha * (newFreq - _prevFrequency!);
            }
          }

          _controller.add(_prevFrequency!);
        }
      });
    }
  }

  void _onError(Object e) {
    debugPrint('Audio capture error: $e');
  }
}
