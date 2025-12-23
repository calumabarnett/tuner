# Bolt's Journal

## 2024-05-22 - Optimizing Tuner Gauge Painting
**Learning:** `CustomPaint` repaints everything by default. Splitting static and dynamic elements into separate painters and using `RepaintBoundary` on the static one can significantly reduce CPU usage during animations.
**Action:** Always look for static background elements in `CustomPainter` and separate them.

## 2024-05-23 - Stopping Infinite Animations
**Learning:** `AnimationController.repeat()` consumes frames indefinitely. Even if the visual impact is zero (e.g., amplitude 0), the engine still pumps frames.
**Action:** Always stop `AnimationController` when the animation is not visible or necessary.
