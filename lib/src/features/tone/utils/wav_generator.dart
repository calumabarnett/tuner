import 'dart:math';
import 'dart:typed_data';

class WavGenerator {
  /// Generates a WAV file buffer (RIFF header + PCM data) for a sine wave.
  ///
  /// [frequency] - Frequency of the sine wave in Hz.
  /// [duration] - Duration of the audio in seconds.
  /// [sampleRate] - Samples per second (default 44100).
  static Uint8List generateSineWaveWav(
    double frequency,
    double duration, {
    int sampleRate = 44100,
  }) {
    final int numSamples = (duration * sampleRate).toInt();
    final int byteRate = sampleRate * 2; // 16-bit mono = 2 bytes per sample
    final int dataSize = numSamples * 2;
    final int totalSize = 36 + dataSize;

    final buffer = ByteData(totalSize + 8);
    int offset = 0;

    // --- RIFF Header ---
    _writeString(buffer, offset, 'RIFF');
    offset += 4;
    buffer.setUint32(offset, totalSize, Endian.little);
    offset += 4;
    _writeString(buffer, offset, 'WAVE');
    offset += 4;

    // --- fmt Chunk ---
    _writeString(buffer, offset, 'fmt ');
    offset += 4;
    buffer.setUint32(offset, 16, Endian.little); // Subchunk1Size (16 for PCM)
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little); // AudioFormat (1 = PCM)
    offset += 2;
    buffer.setUint16(offset, 1, Endian.little); // NumChannels (1 = Mono)
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 2, Endian.little); // BlockAlign
    offset += 2;
    buffer.setUint16(offset, 16, Endian.little); // BitsPerSample
    offset += 2;

    // --- data Chunk ---
    _writeString(buffer, offset, 'data');
    offset += 4;
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    // --- PCM Data ---
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Standard Sine Wave
      final double sample = sin(2 * pi * frequency * t);

      // Convert to 16-bit signed integer (-32768 to 32767)
      final int value = (sample * 32767).round().clamp(-32768, 32767);

      buffer.setInt16(offset, value, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// Generates a WAV loop of exactly one beat at the given BPM, with a click at the start.
  static Uint8List generateClickLoopWav(int bpm, {
    double frequency = 1000.0,
    double clickDuration = 0.05,
    int sampleRate = 44100,
  }) {
    final double beatDuration = 60.0 / bpm;
    final int numSamples = (beatDuration * sampleRate).toInt();
    final int clickSamples = (clickDuration * sampleRate).toInt();

    final int byteRate = sampleRate * 2;
    final int dataSize = numSamples * 2;
    final int totalSize = 36 + dataSize;

    final buffer = ByteData(totalSize + 8);
    int offset = 0;

    _writeString(buffer, offset, 'RIFF');
    offset += 4;
    buffer.setUint32(offset, totalSize, Endian.little);
    offset += 4;
    _writeString(buffer, offset, 'WAVE');
    offset += 4;

    _writeString(buffer, offset, 'fmt ');
    offset += 4;
    buffer.setUint32(offset, 16, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little);
    offset += 2;
    buffer.setUint16(offset, 1, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 2, Endian.little);
    offset += 2;
    buffer.setUint16(offset, 16, Endian.little);
    offset += 2;

    _writeString(buffer, offset, 'data');
    offset += 4;
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    for (int i = 0; i < numSamples; i++) {
      double sample = 0;
      if (i < clickSamples) {
        final double t = i / sampleRate;
        final double envelope = exp(-i / (clickSamples / 3));
        sample = sin(2 * pi * frequency * t) * envelope;
      }

      final int value = (sample * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(offset, value, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// Generates a short percussive click sound.
  static Uint8List generateClickWav({
    double frequency = 1000.0,
    double duration = 0.05,
    int sampleRate = 44100,
  }) {
    final int numSamples = (duration * sampleRate).toInt();
    final int byteRate = sampleRate * 2;
    final int dataSize = numSamples * 2;
    final int totalSize = 36 + dataSize;

    final buffer = ByteData(totalSize + 8);
    int offset = 0;

    _writeString(buffer, offset, 'RIFF');
    offset += 4;
    buffer.setUint32(offset, totalSize, Endian.little);
    offset += 4;
    _writeString(buffer, offset, 'WAVE');
    offset += 4;

    _writeString(buffer, offset, 'fmt ');
    offset += 4;
    buffer.setUint32(offset, 16, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little);
    offset += 2;
    buffer.setUint16(offset, 1, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 2, Endian.little);
    offset += 2;
    buffer.setUint16(offset, 16, Endian.little);
    offset += 2;

    _writeString(buffer, offset, 'data');
    offset += 4;
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // Exponential decay envelope
      final double envelope = exp(-i / (numSamples / 3));
      final double sample = sin(2 * pi * frequency * t) * envelope;

      final int value = (sample * 32767).round().clamp(-32768, 32767);
      buffer.setInt16(offset, value, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  /// Generates a WAV loop of a full measure with accents and subdivisions.
  static Uint8List generateMeasureWav({
    required int bpm,
    required int beatsPerMeasure,
    required int beatUnit,
    required int subdivision,
    required List<bool> accents,
    int sampleRate = 44100,
  }) {
    final double beatDuration = 60.0 / bpm;
    final double measureDuration = beatDuration * beatsPerMeasure;
    final int numSamples = (measureDuration * sampleRate).toInt();

    final int byteRate = sampleRate * 2;
    final int dataSize = numSamples * 2;
    final int totalSize = 36 + dataSize;

    final buffer = ByteData(totalSize + 8);
    int offset = 0;

    _writeString(buffer, offset, 'RIFF');
    offset += 4;
    buffer.setUint32(offset, totalSize, Endian.little);
    offset += 4;
    _writeString(buffer, offset, 'WAVE');
    offset += 4;

    _writeString(buffer, offset, 'fmt ');
    offset += 4;
    buffer.setUint32(offset, 16, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 1, Endian.little);
    offset += 2;
    buffer.setUint16(offset, 1, Endian.little);
    offset += 2;
    buffer.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    buffer.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    buffer.setUint16(offset, 2, Endian.little);
    offset += 2;
    buffer.setUint16(offset, 16, Endian.little);
    offset += 2;

    _writeString(buffer, offset, 'data');
    offset += 4;
    buffer.setUint32(offset, dataSize, Endian.little);
    offset += 4;

    final List<int> pcmData = List.filled(numSamples, 0);

    const double clickDuration = 0.05;
    final int clickSamples = (clickDuration * sampleRate).toInt();

    for (int b = 0; b < beatsPerMeasure; b++) {
      final double beatStartTime = b * beatDuration;
      final bool isAccented = accents.length > b && accents[b];
      final double frequency = isAccented ? 1200.0 : 800.0;
      final double gain = isAccented ? 1.0 : 0.7;

      _addClick(pcmData, beatStartTime, frequency, gain, clickSamples, sampleRate);

      if (subdivision > 1) {
        final double subStep = beatDuration / subdivision;
        for (int s = 1; s < subdivision; s++) {
          final double subStartTime = beatStartTime + (s * subStep);
          _addClick(pcmData, subStartTime, 600.0, 0.4, clickSamples ~/ 2, sampleRate);
        }
      }
    }

    for (int i = 0; i < numSamples; i++) {
      final int value = pcmData[i].clamp(-32768, 32767);
      buffer.setInt16(offset, value, Endian.little);
      offset += 2;
    }

    return buffer.buffer.asUint8List();
  }

  static void _addClick(
    List<int> data,
    double startTimeSeconds,
    double frequency,
    double gain,
    int durationSamples,
    int sampleRate,
  ) {
    final int startSample = (startTimeSeconds * sampleRate).toInt();
    for (int i = 0; i < durationSamples; i++) {
      final int index = startSample + i;
      if (index >= data.length) break;

      final double t = i / sampleRate;
      final double envelope = exp(-i / (durationSamples / 3));
      final double sample = sin(2 * pi * frequency * t) * envelope * gain;
      data[index] += (sample * 32767).round();
    }
  }

  static void _writeString(ByteData buffer, int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      buffer.setUint8(offset + i, s.codeUnitAt(i));
    }
  }
}
