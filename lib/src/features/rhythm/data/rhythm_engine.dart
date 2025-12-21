import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:logging/logging.dart';
import '../domain/beat_state.dart';
import '../domain/sound_profile.dart';

class RhythmEngine {
  final _logger = Logger('RhythmEngine');
  SoLoud? _soloud;
  AudioSource? _sineSource;
  AudioSource? _sawSource;

  Timer? _timer;
  bool _isPlaying = false;
  int _bpm = 120;
  List<BeatState> _pattern = [];
  SoundProfile _profile = SoundProfile.digitalClick;
  int _currentBeatIndex = 0;

  // Timing
  int _nextBeatMicroseconds = 0;
  int _beatIntervalMicroseconds = 0;

  // For UI sync
  int? _startTimeMicroseconds;
  int? get startTimeMicroseconds => _startTimeMicroseconds;

  Future<void> init() async {
    _soloud = SoLoud.instance;
    if (!_soloud!.isInitialized) {
      try {
        await _soloud!.init();
      } catch (e) {
        _logger.severe('Failed to init SoLoud: $e');
        return;
      }
    }

    // Create synthesized sounds
    try {
        _sineSource = await _soloud!.loadWaveform(WaveForm.sin, true, 0.25, 0.0);
        _sawSource = await _soloud!.loadWaveform(WaveForm.saw, true, 0.25, 0.0);
    } catch (e) {
        _logger.severe('Failed to load waveform: $e');
    }
  }

  void setSoundProfile(SoundProfile profile) {
    _profile = profile;
  }

  void setBpm(int bpm) {
    _bpm = bpm;
    _beatIntervalMicroseconds = (60000000 / bpm).round();
  }

  void setPattern(List<BeatState> pattern) {
    _pattern = pattern;
    if (_pattern.isEmpty) return;
    if (_currentBeatIndex >= pattern.length) {
      _currentBeatIndex = 0;
    }
  }

  void start() {
    if (_isPlaying) return;
    if (_soloud == null) {
        _logger.warning('SoLoud not inited');
        // Try auto-init if needed or just return
        return;
    }

    _isPlaying = true;
    _currentBeatIndex = 0;
    _startTimeMicroseconds = DateTime.now().microsecondsSinceEpoch;
    // Start slightly in the future to allow setup? No, start now.
    _nextBeatMicroseconds = _startTimeMicroseconds!;
    _beatIntervalMicroseconds = (60000000 / _bpm).round();

    _scheduleTick();
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
    _startTimeMicroseconds = null;
  }

  void _scheduleTick() {
    if (!_isPlaying) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    // Allow up to 50ms lateness without "catching up" aggressively
    // If we are way behind, maybe reset?
    // For now, simple drift correction.

    final diff = _nextBeatMicroseconds - now;

    if (diff <= 5000) { // 5ms window
      _playTick();

      // Advance to next beat
      _nextBeatMicroseconds += _beatIntervalMicroseconds;
      _currentBeatIndex = (_currentBeatIndex + 1) % (_pattern.isNotEmpty ? _pattern.length : 1);

      // Schedule next
      // We want to re-evaluate soon.
      Timer.run(_scheduleTick);
    } else {
      // Wait
      // Wake up 2ms early
      final waitMs = (diff / 1000).floor() - 2;
      if (waitMs > 0) {
        _timer = Timer(Duration(milliseconds: waitMs), _scheduleTick);
      } else {
        Timer.run(_scheduleTick);
      }
    }
  }

  Future<void> _playTick() async {
    if (_soloud == null) return;

    final state = _pattern.isNotEmpty ? _pattern[_currentBeatIndex] : BeatState.standard;

    if (state == BeatState.mute) return;

    AudioSource? source;
    double pitch = 1.0;
    double volume = 0.8;

    switch (_profile) {
      case SoundProfile.digitalClick:
        source = _sineSource;
        pitch = (state == BeatState.accent) ? 2.0 : 1.0;
        volume = 0.8;
        break;
      case SoundProfile.woodblock:
        source = _sineSource;
        pitch = (state == BeatState.accent) ? 2.5 : 2.0;
        volume = 1.0;
        break;
      case SoundProfile.mechanicalTick:
        source = _sawSource;
        pitch = (state == BeatState.accent) ? 1.5 : 1.0;
        volume = 0.6;
        break;
    }

    if (source == null) return;

    try {
      final handle = await _soloud!.play(source, volume: volume, paused: true);
      _soloud!.setRelativePlaySpeed(handle, pitch);
      _soloud!.setPause(handle, false);
    } catch (e) {
      _logger.warning('Error playing tick: $e');
    }
  }
}

final rhythmEngineProvider = Provider<RhythmEngine>((ref) => RhythmEngine());
