# Bolt's Journal

## 2024-05-22 - Optimizing Tuner Gauge Painting
**Learning:** `CustomPaint` repaints everything by default. Splitting static and dynamic elements into separate painters and using `RepaintBoundary` on the static one can significantly reduce CPU usage during animations.
**Action:** Always look for static background elements in `CustomPainter` and separate them.

## 2024-05-23 - Stopping Idle Animations
**Learning:** `AnimationController.repeat()` keeps the UI thread busy (60fps) even if the visual effect is effectively hidden (e.g., alpha 0 or scale 0). `TweenAnimationBuilder`'s `onEnd` is a perfect place to clean up or stop backing controllers when a transition finishes.
**Action:** When animating a "playing" state, ensure the underlying controller is stopped when the state is false and the exit transition completes.
