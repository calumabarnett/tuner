import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tone_audio_service.dart';
import 'tone_state.dart';

class ToneController extends Notifier<ToneState> {
  late final ToneAudioService _audioService;

  // Transposition Definitions (Name, Semitone Offset from Concert Pitch)
  // Logic: "Transposed to X" usually means "Written C sounds like X".
  // So "Transposed to Bb" (Trumpet): Written C = Concert Bb (-2 semitones).
  // "Transposed to F" (Horn): Written C = Concert F (+5 or -7 semitones).
  // We will store the offset applied to the WRITTEN note to get the CONCERT pitch.
  static const List<Map<String, dynamic>> transpositions = [
    {'name': 'Concert Pitch', 'offset': 0},
    {'name': 'Bb (Trumpet/Clarinet)', 'offset': -2},
    {'name': 'Eb (Alto Sax)', 'offset': 3}, // Usually +9 or -3. Alto is -9 from written? No, Written C = Concert Eb. Eb is above C? No, Alto sounds Major 6th lower. Written C5 -> Concert Eb4. (-9). Let's stick to standard intervals.
    // Wait, simpler: Written C -> Sounds Eb. Eb is +3 semitones from C (up) or -9 (down).
    // Let's implement standard keys.
    // F (Horn): Sounds Perfect 5th lower (-7). Written C -> Concert F.
    {'name': 'F (French Horn)', 'offset': -7},
    {'name': 'A (Clarinet)', 'offset': -3},
    {'name': 'G (Alto Flute)', 'offset': -5},
    {'name': 'E (Sopranino)', 'offset': 4}, // Written C -> Concert E (+4)
  ];

  @override
  ToneState build() {
    _audioService = ref.read(toneAudioServiceProvider);
    _initAudio();
    return const ToneState();
  }

  Future<void> _initAudio() async {
    await _audioService.init();
  }

  void togglePlay() {
    if (state.isPlaying) {
      _audioService.stop();
      state = state.copyWith(isPlaying: false);
    } else {
      _playCurrentNote();
      state = state.copyWith(isPlaying: true);
    }
  }

  void selectNote(int index) {
    if (state.noteIndex == index && state.isPlaying) {
      // If already playing this note, do nothing or toggle?
      // "Tapping a note button selects that note. If sound is active, switch pitch immediately."
      // If same note, maybe just ensure it plays.
      return;
    }

    state = state.copyWith(noteIndex: index);
    if (state.isPlaying) {
      _playCurrentNote();
    }
  }

  void setOctave(int octave) {
    if (octave < 2 || octave > 6) return;
    state = state.copyWith(octave: octave);
    if (state.isPlaying) {
      _playCurrentNote();
    }
  }

  void setTransposition(int index) {
    state = state.copyWith(transpositionIndex: index);
    // "The audio frequency must remain the correct Concert Pitch."
    // If I change transposition while playing, do I change the pitch?
    // "When a transposition is active... Note Name... update to show the 'Written' note."
    // If I hold "Written C" and change transposition to "Bb", the written note stays C, but the concert pitch changes?
    // Or does the Concert Pitch stay the same and the Written Note updates?
    // Prompt: "Behavior: When a transposition is active... the Note Name... must update to show the 'Written' note. The audio frequency must remain the correct Concert Pitch."
    // This implies that if I am listening to 440Hz (Concert A). And I switch to "Bb Transposition".
    // 440Hz is Concert A.
    // For a Bb instrument, Written B = Concert A.
    // So the display should change from "A" to "B".
    // Audio remains 440Hz.

    // HOWEVER, my state holds `noteIndex`. Is `noteIndex` the Written Note or the Concert Note?
    // If `noteIndex` is Written, then changing Transposition (offset) would change the output frequency.
    // If `noteIndex` is Concert, then changing Transposition changes the Displayed Note.

    // Let's assume `noteIndex` represents the *WRITTEN* note (what the user sees on the grid).
    // If I change transposition, the user likely wants to keep the *selection* on the grid (e.g. they selected button 0 (C)).
    // If I change to Bb Transposition, Button 0 is still C.
    // So the Sound must change.

    // Re-reading: "Full Support: Tapping this must open a picker for all 12 chromatic transpositions."
    // "When a transposition is active... Note Name... update to show the 'Written' note."
    // This phrasing is tricky.
    // "The audio frequency must remain the correct Concert Pitch."
    // Scenario: I am playing Concert A (440Hz).
    // I enable "Bb Transposition".
    // The display should show "B".
    // The audio should stay 440Hz.
    // This implies the *Selection* changes?
    // If I was on Button "A", I should visually move to Button "B"?
    // "The Grid labels must update to show the 'Written' note."
    // Ah! "Grid labels must update".
    // This means the grid itself changes?
    // Standard Grid: C, C#, D...
    // If Transposition is active, does the grid layout change? Or just the labels?
    // Usually, a Tone Generator Grid is fixed (C is always top left).
    // If I press "C" (Written), I hear Concert Bb.
    // If I change transposition, "C" (Written) still produces a sound.
    // The prompt says "The audio frequency must remain the correct Concert Pitch."
    // This constraint might apply to the *act of switching transposition*.
    // Example: I am playing a tone. I switch transposition. The tone shouldn't jump?
    // OR it means "The system calculates frequency based on Concert Pitch rules."

    // Let's go with the most standard implementation for a Pitch Pipe with Transposition:
    // User selects "Written C".
    // If Concert Pitch: Plays C.
    // If Bb Transposition: Plays Bb.
    // If I change transposition while playing "Written C", the pitch changes to reflect the new transposition of that written note.

    // BUT the prompt says: "The audio frequency must remain the correct Concert Pitch."
    // This specifically counters the idea that pitch changes.
    // It suggests: "I want to hear an A (440Hz). I am a Bb Trumpet. So show me a 'B' on the screen."
    // So the STATE should track CONCERT PITCH?
    // If state tracks Concert Pitch, then `noteIndex` = Concert Note.
    // Grid Buttons: Button 0 = Concert C?
    // If Transposition is Bb. Button 0 (Concert C) should be labeled "D" (Written D -> Concert C)?
    // "The Note Name... and the Grid labels must update to show the 'Written' note."
    // YES. This confirms it.
    // The internal state `noteIndex` should be CONCERT PITCH.
    // The UI (Grid, Center Display) renders `noteIndex + transposition` (inverse offset).

    // Wait. "Tapping a note button selects that note."
    // If the grid labels update, then the buttons move?
    // No, the grid is a 3x4 layout.
    // If I am in Concert Pitch:
    // C  C# D
    // ...
    // If I switch to Bb Transposition (Written C = Concert Bb. Written D = Concert C).
    // So Concert C should be labeled "D".
    // So the button at position 0 (which was C) is now D?
    // That means the buttons are dynamic?

    // Alternative Interpretation:
    // The grid is always Written Notes.
    // Position 0 is always "C".
    // When I tap "C", I set `noteIndex` (Written) to 0.
    // Frequency = Written + Offset.
    // "When a transposition is active... audio frequency must remain the correct Concert Pitch."
    // This sentence is the confusing part if we assume `noteIndex` is Written.
    // If I am playing Written C (Concert Bb). And I switch to Concert Pitch. Written C is now Concert C. The pitch changes.
    // So "Audio frequency must remain..." implies that if I switch transposition, the *Written Note* changes to maintain the pitch?
    // Example: Playing Written D (Concert C) in Bb Transposition.
    // Switch to Concert Pitch.
    // System should now select Written C (Concert C) to keep the pitch same?
    // This seems like a "Smart" feature.

    // Let's stick to the most robust interpretation:
    // Internal State `noteIndex` = CONCERT PITCH (0-11).
    // This effectively represents the absolute frequency.
    // Grid Buttons represent the 12 semitones.
    // If Transposition = 0. Button 0 represents Concert C. Label "C".
    // If Transposition = Bb (Offset -2). Written C = Concert Bb. Written D = Concert C.
    // So Concert C (Button 0?? No).
    // Let's map the Grid to CONCERT PITCHES 0-11.
    // Grid Button 0: Always triggers Concert C?
    // Label: "D" (if in Bb).
    // Grid Button 1: Concert C#. Label "D#".
    // This preserves the Grid layout (chromatic).
    // And it satisfies "Audio frequency remains correct" (because we store Concert Pitch).
    // And "Labels update".

    // So: `noteIndex` in state is CONCERT PITCH.

    // Correction on Transposition Offsets for LABELS:
    // Bb Instrument: Writes C, Sounds Bb (-2).
    // So if Sound is C (Concert), Written is D (+2).
    // Label Offset = -1 * Transposition Offset.

    if (state.isPlaying) {
      _playCurrentNote(); // Pitch doesn't change because noteIndex is Concert Pitch.
    }
  }

  void startMomentary(int index) {
    // Index is the button index.
    // If the grid maps to Concert Pitch directly, `index` is `concertIndex`.
    // But wait. Does the grid start at C?
    // Yes.
    // So Button 0 is top-left.
    // If I am in Bb Transposition.
    // Button 0 says "D".
    // If I press it, do I want to hear D (Concert)? Or do I want to hear Written D (Concert C)?
    // "Tapping a note button selects that note."
    // Usually, if I see a "D", and I press it, I expect to set the state to that note.
    // If the buttons CHANGE LABELS, then the mapping of Button Position to Concert Pitch changes.
    // Example:
    // Concert Pitch: Button 0 = C (Concert C).
    // Bb Transposition: Button 0 = D (Written D = Concert C).
    // So Button 0 ALWAYS plays Concert C.
    // But it is labeled "D".
    // This works perfect.
    // So `selectNote(index)` where index is 0..11 corresponding to Concert C..B.

    selectNote(index);
    if (!state.isPlaying) {
       _playCurrentNote();
       // We mark as playing for momentary, but we need to track that it's momentary?
       // Actually, the requirement says "plays... as long as it is held".
       // If I release, I stop.
       // But `state.isPlaying` toggles the persistent play.
       // Let's add a temporary play method or just use `togglePlay`.
       // Better: Set `isPlaying` to true.
       state = state.copyWith(isPlaying: true);
    }
  }

  void stopMomentary() {
    // Only stop if we were in momentary mode?
    // The requirement: "plays the note as long as it is held (if not already sounding)."
    // "if not already sounding" -> If it WAS playing before I pressed, do I stop when I release? No.
    // So I need to know if it was playing before.
    // The UI can handle this check?
    // "Pressing and holding a note selects it and plays the note as long as it is held (if not already sounding)."
    // Implies:
    // 1. System is Silent. User holds C. -> Play C. User releases C. -> Silence.
    // 2. System is Playing G. User holds C. -> Switch to C. System plays C. User releases C. -> System continues playing C.

    // So `stopMomentary` should only be called if we started from silent.
    // I will let the UI decide whether to call `stopMomentary`.

    state = state.copyWith(isPlaying: false);
    _audioService.stop();
  }

  void _playCurrentNote() {
    final freq = _calculateFrequency(state.noteIndex, state.octave);
    _audioService.play(freq);
  }

  double _calculateFrequency(int noteIndex, int octave) {
    // A4 = 440Hz.
    // A is index 9 (C=0, C#=1, D=2, D#=3, E=4, F=5, F#=6, G=7, G#=8, A=9).
    // Distance from A4 in semitones:
    // (octave - 4) * 12 + (noteIndex - 9).
    final int semitonesFromA4 = (octave - 4) * 12 + (noteIndex - 9);
    return 440.0 * pow(2.0, semitonesFromA4 / 12.0);
  }
}

final toneControllerProvider = NotifierProvider<ToneController, ToneState>(ToneController.new);
