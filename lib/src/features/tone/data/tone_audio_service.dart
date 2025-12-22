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
      );

      // Start playing immediately at volume 0.0 (Gated)
      // Paused: FALSE. We want it running to avoid wake-up latency.
      _currentHandle = await _soloud!.play(
        _sineSource!,
        looping: true,
        volume: 0.0,
        loopingStartAt: Duration.zero,
        paused: false,
      );
    } catch (e) {
      debugPrint('ToneAudioService: Failed to load/play silent wav: $e');
    }
  }

  Future<void> play(double frequency) async {
    if (_soloud == null || _currentHandle == null) return;

    // Safety check handle
    if (!_soloud!.getIsValidVoiceHandle(_currentHandle!)) {
       if (_sineSource != null) {
          _currentHandle = await _soloud!.play(
            _sineSource!,
            looping: true,
            volume: 0.0, // Start silent
            loopingStartAt: Duration.zero,
            paused: false,
          );
       } else {
         return;
       }
    }

    // Set Pitch
    final double speed = frequency / _baseFrequency;
    _soloud!.setRelativePlaySpeed(_currentHandle!, speed);

    // Unmute (Instant)
    _soloud!.setVolume(_currentHandle!, 1.0);
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
      // Mute (Instant)
      _soloud!.setVolume(_currentHandle!, 0.0);
    }
  }

  void dispose() {
    if (_soloud != null && _currentHandle != null) {
       _soloud!.stop(_currentHandle!);
    }
    _soloud?.deinit();
    _soloud = null;
  }
}
