import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';

class RhythmEngine {
  static final RhythmEngine _instance = RhythmEngine._internal();
  factory RhythmEngine() => _instance;
  RhythmEngine._internal();

  SoLoud? _soloud;
  AudioSource? _accentSound;
  AudioSource? _normalSound;

  Timer? _timer;
  bool _isPlaying = false;
  int _bpm = 120;
  List<int> _beatPatterns = [1, 0, 0, 0]; // 1: Accent, 0: Normal, 2: Muted
  int _currentBeatIndex = 0;

  // Drift Correction
  int _startTime = 0;
  int _beatCount = 0;
  double _intervalMs = 500; // 60000 / 120

  Function(int beatIndex)? onBeat;

  Future<void> init() async {
    if (_soloud != null) return;

    _soloud = SoLoud.instance;
    await _soloud!.init();

    final accentData = _generateWave(1200);
    final normalData = _generateWave(800);

    final tempDir = await getTemporaryDirectory();
    final accentFile = File('${tempDir.path}/accent.wav');
    final normalFile = File('${tempDir.path}/normal.wav');

    await accentFile.writeAsBytes(accentData);
    await normalFile.writeAsBytes(normalData);

    _accentSound = await _soloud!.loadFile(accentFile.path);
    _normalSound = await _soloud!.loadFile(normalFile.path);
  }

  void setBpm(int bpm) {
    _bpm = bpm;
    _intervalMs = 60000 / _bpm;
    // If playing, the next tick will adjust automatically based on drift/re-calc,
    // but changing BPM mid-stream requires resetting the reference time to avoid "catch-up" or huge jumps
    // or we just accept the interval change for future beats.
    // Better to reset reference time on BPM change if playing to smooth transition?
    // For now, simpler: if playing, we might need to reset start time reference to "now" - (beatCount * newInterval)
    // to maintain continuity, OR just reset beatCount.
    if (_isPlaying) {
      _timer?.cancel();
      _resetTiming();
      _tick();
    }
  }

  void updateBeatPattern(List<int> patterns) {
    _beatPatterns = patterns;
    if (_currentBeatIndex >= _beatPatterns.length) {
      _currentBeatIndex = 0;
    }
  }

  void play() {
    if (_isPlaying) return;
    _isPlaying = true;
    _currentBeatIndex = 0;
    _resetTiming();
    _tick();
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
    _currentBeatIndex = 0;
  }

  void dispose() {
    stop();
    _soloud?.deinit();
    _soloud = null;
  }

  void _resetTiming() {
    _startTime = DateTime.now().millisecondsSinceEpoch;
    _beatCount = 0;
  }

  void _tick() {
    if (!_isPlaying) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    // Check for huge drift (e.g. app pause)
    final expectedTime = _startTime + (_beatCount * _intervalMs).round();
    final drift = now - expectedTime;

    if (drift > 1000) {
      // Extensive drift (e.g. > 1s), reset timing
      _resetTiming();
      // We still process this beat
    }

    // Fire callback
    onBeat?.call(_currentBeatIndex);

    // Play Sound
    _playSound(_beatPatterns[_currentBeatIndex]);

    // Prepare next
    _beatCount++;
    _currentBeatIndex = (_currentBeatIndex + 1) % _beatPatterns.length;

    // Calculate next interval
    // We want the next tick to happen at _startTime + (_beatCount * _intervalMs)
    // The delay from *now* is (TargetTime - Now)
    final nextTargetTime = _startTime + (_beatCount * _intervalMs).round();
    final delay = nextTargetTime - DateTime.now().millisecondsSinceEpoch;

    // Ensure delay is non-negative (if we are late, fire immediately, but maybe skip?)
    // If we are extremely late, we might loop to skip beats, but for now just fire immediately.
    int nextDelay = delay;
    if (nextDelay < 0) nextDelay = 0;

    _timer = Timer(Duration(milliseconds: nextDelay), _tick);
  }

  Future<void> _playSound(int type) async {
    if (_soloud == null) return;
    try {
      if (type == 1 && _accentSound != null) {
        await _soloud!.play(_accentSound!);
      } else if (type == 0 && _normalSound != null) {
        await _soloud!.play(_normalSound!);
      }
      // Type 2 is Muted, do nothing
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Uint8List _generateWave(int freq) {
    const int sampleRate = 44100;
    const int numSamples = 4410; // 100ms * 44100Hz
    const int numChannels = 1;
    const int byteRate = sampleRate * numChannels * 2; // 16-bit = 2 bytes
    const int blockAlign = numChannels * 2;
    const int bitsPerSample = 16;

    const int dataSize = numSamples * blockAlign;
    const int fileSize = 36 + dataSize;

    final ByteData header = ByteData(44);

    // RIFF chunk
    _writeString(header, 0, 'RIFF');
    header.setUint32(4, fileSize, Endian.little);
    _writeString(header, 8, 'WAVE');

    // fmt chunk
    _writeString(header, 12, 'fmt ');
    header.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    header.setUint16(20, 1, Endian.little); // AudioFormat (1 for PCM)
    header.setUint16(22, numChannels, Endian.little); // NumChannels
    header.setUint32(24, sampleRate, Endian.little); // SampleRate
    header.setUint32(28, byteRate, Endian.little); // ByteRate
    header.setUint16(32, blockAlign, Endian.little); // BlockAlign
    header.setUint16(34, bitsPerSample, Endian.little); // BitsPerSample

    // data chunk
    _writeString(header, 36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    final Int16List pcmData = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Sine wave
      final double sample = sin(2 * pi * freq * t);
      // Exponential decay
      final double decay = exp(-15 * t); // Adjust decay rate as needed
      final double value = sample * decay;

      // Convert to 16-bit int
      pcmData[i] = (value * 32767).toInt().clamp(-32768, 32767);
    }

    final Uint8List fileBytes = Uint8List(44 + dataSize);
    fileBytes.setRange(0, 44, header.buffer.asUint8List());
    fileBytes.setRange(44, 44 + dataSize, pcmData.buffer.asUint8List());

    return fileBytes;
  }

  void _writeString(ByteData data, int offset, String value) {
    for (int i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }
}
