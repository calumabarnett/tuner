import 'package:flutter_test/flutter_test.dart';
import 'package:tuner/src/features/rhythm/domain/time_signature.dart';

void main() {
  group('TimeSignature', () {
    test('supports value comparisons', () {
      expect(const TimeSignature(4, 4), const TimeSignature(4, 4));
      expect(const TimeSignature(4, 4), isNot(const TimeSignature(3, 4)));
    });
  });
}
