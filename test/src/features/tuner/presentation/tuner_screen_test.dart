import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tuner/src/features/tuner/data/tuner_repository.dart';
import 'package:tuner/src/features/tuner/domain/permission_provider.dart';
import 'package:tuner/src/features/tuner/presentation/tuner_screen.dart';

// Mock Repository
class MockTunerRepo extends Mock implements TunerRepository {}

class FakeMicrophonePermissionNotifier extends MicrophonePermissionNotifier {
  @override
  Future<PermissionStatus> build() async {
    return PermissionStatus.granted;
  }

  @override
  Future<void> request() async {}
}

class DeniedMicrophonePermissionNotifier extends MicrophonePermissionNotifier {
  @override
  Future<PermissionStatus> build() async {
    return PermissionStatus.denied;
  }

  @override
  Future<void> request() async {}
}

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
          microphonePermissionProvider.overrideWith(FakeMicrophonePermissionNotifier.new),
        ],
        child: const MaterialApp(home: TunerScreen()),
      ),
    );

    // Initial load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    // Should show listening text
    expect(find.text('Listening...'), findsOneWidget);
  });

  testWidgets('TunerScreen shows Note A4 when 440Hz', (tester) async {
    when(() => mockRepo.getFrequencyStream()).thenAnswer((_) => Stream.value(440.0));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tunerRepositoryProvider.overrideWithValue(mockRepo),
          microphonePermissionProvider.overrideWith(FakeMicrophonePermissionNotifier.new),
        ],
        child: const MaterialApp(home: TunerScreen()),
      ),
    );

    await tester.pump(); // Build
    await tester.pump(const Duration(milliseconds: 10)); // Stream emit

    expect(find.text('A'), findsOneWidget);
    expect(find.text('4'), findsOneWidget); // Octave is back
    // Updated expectation to integer Hz
    expect(find.text('440 Hz'), findsOneWidget);
  });

  testWidgets('TunerScreen shows Permission Required when denied', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          microphonePermissionProvider.overrideWith(DeniedMicrophonePermissionNotifier.new),
        ],
        child: const MaterialApp(home: TunerScreen()),
      ),
    );

    await tester.pump(); // Build

    expect(find.text('Microphone Required'), findsOneWidget);
    expect(find.text('Grant Permission'), findsOneWidget);
  });
}
