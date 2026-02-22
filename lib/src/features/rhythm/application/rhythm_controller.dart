import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rhythm_audio_service.dart';
import 'rhythm_state.dart';

final rhythmControllerProvider = NotifierProvider<RhythmController, RhythmState>(RhythmController.new);

class RhythmController extends Notifier<RhythmState> {
  late final RhythmAudioService _audioService;

  static const int minBpm = 30;
  static const int maxBpm = 300;

  final List<DateTime> _tapTimes = [];
  static const int _maxTapCount = 4;

  @override
  RhythmState build() {
    _audioService = ref.read(rhythmAudioServiceProvider);
    _initAudio();
    return const RhythmState();
  }

  Future<void> _initAudio() async {
    await _audioService.init();
  }

  void togglePlay() {
    if (state.isPlaying) {
      _audioService.stop();
      state = state.copyWith(isPlaying: false);
    } else {
      state = state.copyWith(isPlaying: true);
      _audioService.start(state.bpm);
    }
  }

  void setBpm(int bpm) {
    final clampedBpm = bpm.clamp(minBpm, maxBpm);
    if (clampedBpm == state.bpm) return;

    state = state.copyWith(bpm: clampedBpm);
    if (state.isPlaying) {
      _audioService.start(state.bpm);
    }
  }

  void incrementBpm() {
    setBpm(state.bpm + 1);
  }

  void decrementBpm() {
    setBpm(state.bpm - 1);
  }

  void tapTempo() {
    final now = DateTime.now();
    _tapTimes.add(now);

    if (_tapTimes.length > _maxTapCount) {
      _tapTimes.removeAt(0);
    }

    if (_tapTimes.length >= 2) {
      final List<int> intervals = [];
      for (int i = 1; i < _tapTimes.length; i++) {
        final interval = _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds;
        if (interval > 2000) {
          _tapTimes.clear();
          _tapTimes.add(now);
          return;
        }
        intervals.add(interval);
      }

      if (intervals.isNotEmpty) {
        final double averageInterval = intervals.reduce((a, b) => a + b) / intervals.length;
        if (averageInterval > 0) {
          final int newBpm = (60000 / averageInterval).round();
          setBpm(newBpm);
        }
      }
    }
  }

  void stop() {
    state = state.copyWith(isPlaying: false);
    _audioService.stop();
  }
}
