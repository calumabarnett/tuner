## 2024-05-22 - Musical Notation Accessibility
**Learning:** Standard text-to-speech engines often fail to read musical symbols like "#" (Sharp) or "b" (Flat) correctly in context, or read them as symbols ("Number", "Hash").
**Action:** Use `Semantics` widget with `label` to explicitly spell out "Sharp" and "Flat" (e.g., "C Sharp 4") while excluding the original text semantics.

## 2024-05-23 - Custom Button Accessibility
**Learning:** Custom interactive elements built with `GestureDetector` (like the Tone Play button and Note Grid) lack native button semantics, making them invisible or confusing to screen readers.
**Action:** Always wrap `GestureDetector`s that function as buttons in `Semantics` with `button: true`, `enabled: true/false`, and a descriptive `label`.
