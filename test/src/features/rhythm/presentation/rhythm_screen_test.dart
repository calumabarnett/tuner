import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tuner/src/features/rhythm/data/rhythm_audio_service.dart';
import 'package:tuner/src/features/rhythm/presentation/rhythm_screen.dart';

class MockRhythmAudioService extends Mock implements RhythmAudioService {}

void main() {
  late MockRhythmAudioService mockAudioService;

  setUp(() {
    mockAudioService = MockRhythmAudioService();
    when(() => mockAudioService.init()).thenAnswer((_) async {});
    when(() => mockAudioService.start(any())).thenAnswer((_) async {});
    when(() => mockAudioService.stop()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        rhythmAudioServiceProvider.overrideWithValue(mockAudioService),
      ],
      child: const MaterialApp(
        home: RhythmScreen(),
      ),
    );
  }

  testWidgets('renders BPM and controls', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Ensure state is built

    expect(find.text('120'), findsOneWidget);
    expect(find.text('BPM'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('TAP TEMPO'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets('increment button increases BPM', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('121'), findsOneWidget);
  });

  testWidgets('toggle play button changes icon', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.byIcon(Icons.pause), findsOneWidget);
    verify(() => mockAudioService.start(120)).called(1);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    verify(() => mockAudioService.stop()).called(1);
  });
}
