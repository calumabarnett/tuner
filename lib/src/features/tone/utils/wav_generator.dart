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

  static void _writeString(ByteData buffer, int offset, String s) {
    for (int i = 0; i < s.length; i++) {
      buffer.setUint8(offset + i, s.codeUnitAt(i));
    }
  }
}
