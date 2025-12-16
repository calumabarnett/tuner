# Tuner - Clean & Simple

A high-quality, "back to basics" instrument tuner built with Flutter.

## Goals

- **Simplicity:** Intuitive interface without unnecessary clutter.
- **Performance:** Robust pitch detection.
- **Custom Design:** A modern, dark-themed UI that avoids standard Material constraints.

## Features

- **Real-time Pitch Detection:** Uses microphone input to detect frequency.
- **Visual Feedback:** Large note display and a custom deviation gauge.
- **Music Theory Engine:** Accurate conversion from Frequency to Note (Scientific Pitch Notation) and Cents.

## Architecture

This project uses a Feature-First architecture with Riverpod for state management.

- `lib/src/features/tuner/`: Contains all tuner-specific logic (Data, Domain, Presentation).
- `lib/src/utils/`: Shared utilities (Music Theory).
- `lib/src/common_widgets/`: Reusable UI components.

## Getting Started

1. **Prerequisites:** Flutter SDK installed.
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run:**
   ```bash
   flutter run
   ```

## Permissions

The app requires microphone access.
- **iOS:** `NSMicrophoneUsageDescription` is configured in `Info.plist`.
- **Android:** `RECORD_AUDIO` permission is configured in `AndroidManifest.xml`.
