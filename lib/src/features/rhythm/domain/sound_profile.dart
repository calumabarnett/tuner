enum SoundProfile {
  digitalClick,
  woodblock,
  mechanicalTick;

  String get label {
    switch (this) {
      case SoundProfile.digitalClick: return 'Digital Click';
      case SoundProfile.woodblock: return 'Woodblock';
      case SoundProfile.mechanicalTick: return 'Mechanical Tick';
    }
  }
}
