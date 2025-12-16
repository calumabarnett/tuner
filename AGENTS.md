# AGENTS.md

This repository contains a simple, high-quality Tuner application built with Flutter.
As an agent working on this repo, strictly adhere to the following guidelines.

## 1. Project Goals
- **Simplicity:** The app should be intuitive, "back to basics", and performant.
- **Custom UI:** Avoid default Material Design styling. Use custom widgets, dark mode, and minimal aesthetics.
- **Robustness:** Accurate pitch detection with smoothing and noise handling.

## 2. Architecture & Patterns
- **State Management:** Use `flutter_riverpod` for all state management.
- **Folder Structure:** Feature-first.
  - `lib/src/features/tuner/` (Domain, Data, Presentation)
  - `lib/src/common_widgets/` (Reusable custom UI)
  - `lib/src/utils/` (Helpers, e.g., Music Theory logic)
- **Dependency Injection:** Use Riverpod Providers.

## 3. Coding Standards
- **Lints:** Follow `analysis_options.yaml` strictly. No warnings allowed.
- **Types:** Use strict typing. Avoid `dynamic` unless absolutely necessary.
- **Immutability:** Use `final` variables and immutable state classes (use `equatable` or `freezed` if complex).

## 4. Testing
- **Unit Tests:** Mandatory for all business logic (e.g., frequency-to-note conversion).
- **Widget Tests:** Mandatory for all UI components to verify rendering and state updates.
- **Mocking:** Use `mocktail` for mocking dependencies.

## 5. Environment
- **Platform:** iOS and Android primarily.
- **Permissions:** Handle Microphone permissions gracefully using `permission_handler`.

## 6. Pre-Commit
Before submitting any changes, you must:
1. Run `flutter analyze` and ensure no issues.
2. Run `flutter test` and ensure all tests pass.

## 7. Design System: Koda
- **Identity:** Koda. Modern, Minimal, Creative Companion, Swiss/International Style.
- **Rules:** Strictly 2D. No drop shadows. No gradients. No bevels. Depth is created via color blocking and spacing.
- **Typography:**
  - **Headings/Display:** Sora (Weights: ExtraBold/800, SemiBold/600).
  - **UI/Body:** Manrope (Weights: Medium/500, Bold/700).
  - **Data/Technical:** JetBrains Mono (for Hz, BPM, etc.).
- **Color Palette:**
  - **Background:** Light: `0xFFF8F5F2` (Warm Off-White) / Dark: `0xFF121212` (Deep Charcoal).
  - **Text/Ink:** Light: `0xFF121212` / Dark: `0xFFFFFFFF`.
  - **Tuner:** `0xFF4D5BCE` (Electric Indigo).
  - **Rhythm:** `0xFFFF6B6B` (Coral Red).
  - **Tone:** `0xFF00D2A1` (Mint Green).
- **Shape Language:**
  - Circle = Tuner
  - Square = Rhythm
  - Wave = Tone
- **Pure Flat Rule:** No shadows, use `0xFFF8F5F2` background.
