import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../utils/wav_generator.dart';

final toneAudioServiceProvider = Provider<ToneAudioService>((ref) {
  return ToneAudioService();
});

class ToneAudioService {
  ToneAudioService();

  SoLoud? _soloud;
  SoundHandle? _currentHandle;
  AudioSource? _sineSource;

  // Base frequency for the generated sample
  static const double _baseFrequency = 440.0;

  Future<void> init() async {
    if (_soloud != null) return;

    _soloud = SoLoud.instance;
    try {
      // In newer versions, init returns void or Future<void> and throws on error,
      // or returns a result object. Based on analyzer, it returns void (so just await).
      await _soloud!.init();
    } catch (e) {
      debugPrint('ToneAudioService: Failed to init SoLoud: $e');
      return;
    }

    // Generate a 1-second 440Hz sine wave
    final Uint8List wavBytes = WavGenerator.generateSineWaveWav(
      _baseFrequency,
      1.0, // 1 second loop
      sampleRate: 44100,
    );

    try {
      _sineSource = await _soloud!.loadMem(
        'sine_wave',
        wavBytes,
        // loadMode removed as per analyzer error
      );
    } catch (e) {
      debugPrint('ToneAudioService: Failed to load wav: $e');
    }
  }

  Future<void> play(double frequency) async {
    if (_soloud == null || _sineSource == null) return;

    // Calculate speed based on target frequency vs base frequency
    final double speed = frequency / _baseFrequency;

    if (_currentHandle != null && _soloud!.getIsValidVoiceHandle(_currentHandle!)) {
      // Already playing, just update pitch
      _soloud!.setRelativePlaySpeed(_currentHandle!, speed);
    } else {
      // Start playing
      try {
        _currentHandle = await _soloud!.play(
          _sineSource!,
          looping: true,
          volume: 1.0,
          loopingStartAt: Duration.zero,
        );
        _soloud!.setRelativePlaySpeed(_currentHandle!, speed);
      } catch (e) {
        debugPrint('ToneAudioService: Failed to play: $e');
      }
    }
  }

  void setFrequency(double frequency) {
     if (_soloud == null || _currentHandle == null) return;

     if (_soloud!.getIsValidVoiceHandle(_currentHandle!)) {
        final double speed = frequency / _baseFrequency;
        _soloud!.setRelativePlaySpeed(_currentHandle!, speed);
     }
  }

  void stop() {
    if (_soloud == null || _currentHandle == null) return;

    if (_soloud!.getIsValidVoiceHandle(_currentHandle!)) {
      _soloud!.stop(_currentHandle!);
    }
    _currentHandle = null;
  }

  void dispose() {
    stop();
    _soloud?.deinit();
    _soloud = null;
  }
}
