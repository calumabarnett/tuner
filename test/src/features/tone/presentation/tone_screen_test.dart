import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tuner/src/features/tone/data/tone_audio_service.dart';
import 'package:tuner/src/features/tone/presentation/tone_screen.dart';

class MockToneAudioService extends Mock implements ToneAudioService {}

void main() {
  late MockToneAudioService mockAudioService;

  setUp(() {
    mockAudioService = MockToneAudioService();
    when(() => mockAudioService.init()).thenAnswer((_) async {});
    when(() => mockAudioService.play(any())).thenAnswer((_) async {});
    when(() => mockAudioService.stop()).thenAnswer((_) {});
    when(() => mockAudioService.setFrequency(any())).thenAnswer((_) {});
  });

  testWidgets('Play/Pause button has correct semantics', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          toneAudioServiceProvider.overrideWithValue(mockAudioService),
        ],
        child: const MaterialApp(home: ToneScreen()),
      ),
    );

    // Initial state: isPlaying = false.
    final playIconFinder = find.byIcon(Icons.play_arrow);
    expect(playIconFinder, findsOneWidget);

    // Find the GestureDetector wrapping the icon
    final playButtonFinder = find.ancestor(
      of: playIconFinder,
      matching: find.byType(GestureDetector),
    ).first;

    // Verify Semantics
    expect(
        tester.getSemantics(playButtonFinder),
        matchesSemantics(
          isButton: true,
          label: 'Play Tone',
          hint: 'Starts or stops the tone generation',
          isLiveRegion: false,
          hasTapAction: true,
          isEnabled: true,
          hasEnabledState: true,
        ));

    // Tap to play
    await tester.tap(playButtonFinder);
    await tester.pump();

    // Check pause icon
    final pauseIconFinder = find.byIcon(Icons.pause);
    expect(pauseIconFinder, findsOneWidget);

    final pauseButtonFinder = find.ancestor(
      of: pauseIconFinder,
      matching: find.byType(GestureDetector),
    ).first;

     expect(
        tester.getSemantics(pauseButtonFinder),
        matchesSemantics(
          isButton: true,
          label: 'Pause Tone',
          hint: 'Starts or stops the tone generation',
          hasTapAction: true,
          isEnabled: true,
          hasEnabledState: true,
        ));
  });
}
