import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:path_provider/path_provider.dart';

class RhythmEngine {
  RhythmEngine();

  SoLoud? _soloud;
  AudioSource? _clickSource;
  AudioSource? _accentSource;

  // Timer management
  Timer? _timer;
  int _bpm = 120;
  bool _isPlaying = false;

  // Drift correction
  int _nextBeatMicroseconds = 0;

  // Audio state
  bool _isInitialized = false;

  // Callback for UI updates (current beat index)
  void Function(int beatIndex)? onBeat;
  int _currentBeatIndex = 0;
  int _beatsPerBar = 4;
  List<int> _beatPatterns = [1, 0, 0, 0]; // 1=Accent, 0=Normal, -1=Muted

  Future<void> init() async {
    if (_isInitialized) return;

    _soloud = SoLoud.instance;
    await _soloud!.init();

    // Generate sounds
    _clickSource = await _generateClickSound(isAccent: false);
    _accentSource = await _generateClickSound(isAccent: true);

    _isInitialized = true;
  }

  /// Generates a short PCM buffer for a click sound, writes to temp file, and loads it.
  Future<AudioSource> _generateClickSound({required bool isAccent}) async {
    const int sampleRate = 44100;
    const double duration = 0.05; // 50ms
    final int numSamples = (duration * sampleRate).toInt();
    final Float32List pcmData = Float32List(numSamples);

    final double frequency = isAccent ? 1200.0 : 800.0;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Simple sine wave with exponential decay
      final double signal = sin(2 * pi * frequency * t);
      final double envelope = exp(-10 * t); // Decay
      pcmData[i] = signal * envelope;
    }

    // Create WAV source (writes to file)
    return _createWavSource(pcmData, sampleRate, isAccent ? 'accent.wav' : 'click.wav');
  }

  Future<AudioSource> _createWavSource(Float32List floatSamples, int sampleRate, String filename) async {
    // Convert Float32 samples to Int16 PCM for standard WAV
    final int numSamples = floatSamples.length;
    final Int16List int16Data = Int16List(numSamples);
    for (int i = 0; i < numSamples; i++) {
      int sample = (floatSamples[i] * 32767).toInt();
      if (sample > 32767) sample = 32767;
      if (sample < -32768) sample = -32768;
      int16Data[i] = sample;
    }

    // Build WAV header
    final int byteRate = sampleRate * 2; // 16 bit mono
    const int blockAlign = 2;
    final int dataSize = numSamples * 2;
    final int fileSize = 36 + dataSize;

    final ByteData header = ByteData(44);
    // RIFF
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    // WAVE
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E
    // fmt
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6d); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little); // Chunk size
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // Channels (Mono)
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, 16, Endian.little); // Bits per sample
    // data
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    final Uint8List wavBytes = Uint8List(44 + dataSize);
    wavBytes.setRange(0, 44, header.buffer.asUint8List());
    wavBytes.setRange(44, 44 + dataSize, int16Data.buffer.asUint8List());

    // Write to temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(wavBytes);

    // Load from file
    return _soloud!.loadFile(file.path);
  }

  void setBpm(int bpm) {
    if (bpm < 1) bpm = 1;
    if (bpm > 300) bpm = 300;
    _bpm = bpm;
    if (_isPlaying) {
      _restartTimer();
    }
  }

  void setTimeSignature(int numerator, List<int> patterns) {
    _beatsPerBar = numerator;
    _beatPatterns = patterns;
    _currentBeatIndex = 0; // Reset
  }

  void updateBeatPattern(int index, int state) {
     if (index >= 0 && index < _beatPatterns.length) {
       _beatPatterns[index] = state;
     }
  }

  void start() {
    if (_isPlaying || !_isInitialized) return;
    _isPlaying = true;
    _currentBeatIndex = 0;

    // Initialize drift correction
    _nextBeatMicroseconds = DateTime.now().microsecondsSinceEpoch;

    _scheduleNextClick();
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
  }

  void dispose() {
    stop();
    _soloud?.deinit();
  }

  void _restartTimer() {
    _timer?.cancel();
    // Reset next beat time to now to avoid massive catch-up if bpm changes
    _nextBeatMicroseconds = DateTime.now().microsecondsSinceEpoch;
    _scheduleNextClick();
  }

  void _scheduleNextClick() {
    if (!_isPlaying || !_isInitialized) return;

    // Update UI immediately for current beat
    if (onBeat != null) {
      onBeat!(_currentBeatIndex);
    }

    // Play sound immediately if we are at or past the target time
    // In a real high-precision audio loop, we might schedule the audio buffer.
    // Here we trigger 'play' which has low latency.
    _playCurrentBeat(); // Fire and forget

    // Calculate duration for NEXT beat
    final double intervalMs = 60000 / _bpm;
    final int intervalMicros = (intervalMs * 1000).toInt();

    _nextBeatMicroseconds += intervalMicros;

    int delay = _nextBeatMicroseconds - DateTime.now().microsecondsSinceEpoch;

    // Drift correction:
    // If we are late (delay < 0), we try to catch up.
    // If we are WAY late (e.g. paused/backgrounded), reset.
    if (delay < -100000) { // Late by > 100ms
        _nextBeatMicroseconds = DateTime.now().microsecondsSinceEpoch + intervalMicros;
        delay = intervalMicros;
    } else if (delay < 0) {
        // Late but close, schedule immediately (0 delay) to catch up
        delay = 0;
    }

    _timer = Timer(Duration(microseconds: delay), () {
      _currentBeatIndex = (_currentBeatIndex + 1) % _beatsPerBar;
      // We do NOT call onBeat here anymore, we call it at the start of next recursion
      _scheduleNextClick();
    });
  }

  Future<void> _playCurrentBeat() async {
    // pattern: 1 = Accent, 0 = Normal, -1 = Mute
    final int type = _beatPatterns.isNotEmpty ? _beatPatterns[_currentBeatIndex % _beatPatterns.length] : 0;

    if (type == -1) return; // Muted

    final source = (type == 1) ? _accentSource : _clickSource;
    if (source != null) {
      // Fire and forget
       _soloud!.play(source);
    }
  }
}
