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
