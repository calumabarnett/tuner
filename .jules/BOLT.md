# Bolt's Journal

## 2024-05-22 - Optimizing Tuner Gauge Painting
**Learning:** `CustomPaint` repaints everything by default. Splitting static and dynamic elements into separate painters and using `RepaintBoundary` on the static one can significantly reduce CPU usage during animations.
**Action:** Always look for static background elements in `CustomPainter` and separate them.
