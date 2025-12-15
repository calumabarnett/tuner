# Contributing to Tuner

Thank you for your interest in contributing! We aim to keep this codebase clean, simple, and high-quality.

## Guidelines

Please refer to [AGENTS.md](AGENTS.md) for detailed coding standards, architectural patterns, and testing requirements.

### Quick Summary

1. **Architecture:** We use Riverpod. Keep business logic out of the UI.
2. **Style:** Follow the strict lints in `analysis_options.yaml`.
3. **Testing:**
   - Unit tests are mandatory for all logic.
   - Widget tests are mandatory for UI components.
4. **Commits:** Write clear, descriptive commit messages.

## Development Process

1. Fork the repository.
2. Create a feature branch.
3. Implement your feature with tests.
4. Ensure `flutter analyze` and `flutter test` pass.
5. Submit a Pull Request.

## Issues

If you find a bug or have a feature request, please open an issue describing the problem or idea in detail.
