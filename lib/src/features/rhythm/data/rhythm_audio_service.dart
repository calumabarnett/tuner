import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../../tone/utils/wav_generator.dart';

final rhythmAudioServiceProvider = Provider<RhythmAudioService>((ref) {
  return RhythmAudioService();
});

class RhythmAudioService {
  RhythmAudioService();

  SoLoud? _soloud;
  SoundHandle? _currentHandle;
  AudioSource? _currentSource;
  bool _isStarting = false;

  Future<void> init() async {
    if (_soloud != null) return;

    _soloud = SoLoud.instance;
    try {
      if (!_soloud!.isInitialized) {
        await _soloud!.init();
      }
    } catch (e) {
      debugPrint('RhythmAudioService: Failed to init SoLoud: $e');
    }
  }

  Future<void> start(int bpm) async {
    if (_isStarting) return;
    _isStarting = true;

    try {
      if (_soloud == null) await init();
      if (_soloud == null) return;

      // Stop previous
      if (_currentHandle != null) {
        await _soloud!.stop(_currentHandle!);
        _currentHandle = null;
      }
      if (_currentSource != null) {
        await _soloud!.disposeSource(_currentSource!);
        _currentSource = null;
      }

      final Uint8List wavBytes = WavGenerator.generateClickLoopWav(bpm);
      _currentSource = await _soloud!.loadMem(
        'metronome_$bpm',
        wavBytes,
      );

      _currentHandle = await _soloud!.play(
        _currentSource!,
        looping: true,
        volume: 1.0,
        paused: false,
      );
    } catch (e) {
      debugPrint('RhythmAudioService: Failed to play: $e');
    } finally {
      _isStarting = false;
    }
  }

  Future<void> stop() async {
    if (_soloud == null) return;

    if (_currentHandle != null) {
      try {
        if (_soloud!.getIsValidVoiceHandle(_currentHandle!)) {
          await _soloud!.stop(_currentHandle!);
        }
      } catch (e) {
         debugPrint('RhythmAudioService: Error stopping handle: $e');
      }
      _currentHandle = null;
    }

    if (_currentSource != null) {
      try {
        await _soloud!.disposeSource(_currentSource!);
      } catch (e) {
        debugPrint('RhythmAudioService: Error disposing source: $e');
      }
      _currentSource = null;
    }
  }

  void dispose() {
    stop();
  }
}
