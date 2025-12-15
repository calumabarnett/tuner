import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tuner/src/features/tuner/data/tuner_repository.dart';
import 'package:tuner/src/utils/music_theory.dart';

/// Provider that emits the current MusicalNote detected.
final tunerNoteProvider = StreamProvider.autoDispose<MusicalNote?>((ref) {
  final repository = ref.watch(tunerRepositoryProvider);

  // Start listening when the provider is observed
  repository.start();

  // When the provider is destroyed, stop listening
  ref.onDispose(() {
    repository.stop();
  });

  return repository.getFrequencyStream().map((frequency) {
    return MusicTheory.getNoteFromFrequency(frequency);
  });
});
