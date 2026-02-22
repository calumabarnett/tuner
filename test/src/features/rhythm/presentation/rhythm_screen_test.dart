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
    when(() => mockAudioService.start(
          bpm: any(named: 'bpm'),
          beatsPerMeasure: any(named: 'beatsPerMeasure'),
          beatUnit: any(named: 'beatUnit'),
          subdivision: any(named: 'subdivision'),
          accents: any(named: 'accents'),
        )).thenAnswer((_) async {});
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

  testWidgets('renders BPM and professional controls', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('120'), findsOneWidget);
    expect(find.text('SIGNATURE'), findsOneWidget);
    expect(find.text('SUBDIVISION'), findsOneWidget);
    expect(find.text('4/4'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });

  testWidgets('tapping signature opens bottom sheet', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.text('SIGNATURE'));
    await tester.pumpAndSettle();

    expect(find.text('Time Signature'), findsOneWidget);
    expect(find.text('Beats'), findsOneWidget);
    expect(find.text('Unit (Crotchet)'), findsOneWidget);
  });
}
