import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tuner/src/features/tuner/data/tuner_repository.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_screen.dart';

// Mock Repository
class MockTunerRepo extends Mock implements TunerRepository {}

void main() {
  late MockTunerRepo mockRepo;

  setUp(() {
    mockRepo = MockTunerRepo();
    when(() => mockRepo.start()).thenAnswer((_) async {});
    when(() => mockRepo.stop()).thenAnswer((_) async {});
  });

  testWidgets('TunerScreen shows Listening when no frequency', (tester) async {
    when(() => mockRepo.getFrequencyStream()).thenAnswer((_) => Stream.value(0.0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tunerRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(home: TunerScreen()),
      ),
    );

    // Initial load
    await tester.pump();

    // Should show listening text
    expect(find.text('Listening...'), findsOneWidget);
  });

  testWidgets('TunerScreen shows Note A4 when 440Hz', (tester) async {
    when(() => mockRepo.getFrequencyStream()).thenAnswer((_) => Stream.value(440.0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tunerRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: const MaterialApp(home: TunerScreen()),
      ),
    );

    await tester.pump(); // Build
    await tester.pump(const Duration(milliseconds: 10)); // Stream emit

    expect(find.text('A'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    // Updated expectation to integer Hz
    expect(find.text('440 Hz'), findsOneWidget);
  });
}
