## 2024-05-22 - Musical Notation Accessibility
**Learning:** Standard text-to-speech engines often fail to read musical symbols like "#" (Sharp) or "b" (Flat) correctly in context, or read them as symbols ("Number", "Hash").
**Action:** Use `Semantics` widget with `label` to explicitly spell out "Sharp" and "Flat" (e.g., "C Sharp 4") while excluding the original text semantics.

## 2024-05-23 - Custom Interactive Components Accessibility
**Learning:** The application heavily relies on `GestureDetector` with `AnimatedContainer` for custom buttons (e.g., Tone Play Button, Note Grid). These are invisible to screen readers.
**Action:** Always wrap these custom interactive components in `Semantics` with `button: true`, `label`, and `enabled` properties to ensure accessibility.
