import 'package:flutter/material.dart';

class NoteIcon extends StatelessWidget {
  final int unit; // 2, 4, 8, 16
  final int subdivision; // 1, 2, 3, 4
  final Color color;
  final double size;

  const NoteIcon({
    super.key,
    required this.unit,
    this.subdivision = 1,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (subdivision > 1) {
      // For subdivisions, we show multiple small notes
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(subdivision, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: _SingleNote(
              unit: _getLogicalUnit(unit, subdivision),
              color: color,
              size: size * 0.6
            ),
          );
        }),
      );
    }
    return _SingleNote(unit: unit, color: color, size: size);
  }

  int _getLogicalUnit(int baseUnit, int sub) {
    if (sub == 2) return baseUnit * 2;
    if (sub == 4) return baseUnit * 4;
    if (sub == 3) return baseUnit * 2; // Approximate triplets as eighths
    return baseUnit;
  }
}

class _SingleNote extends StatelessWidget {
  final int unit;
  final Color color;
  final double size;

  const _SingleNote({required this.unit, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.4),
      painter: _NotePainter(unit: unit, color: color),
    );
  }
}

class _NotePainter extends CustomPainter {
  final int unit;
  final Color color;

  _NotePainter({required this.unit, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final double headWidth = size.width * 0.8;
    final double headHeight = size.width * 0.55;
    final double stemWidth = size.width * 0.12;
    final double stemHeight = size.height * 0.85;

    // 1. Draw Note Head (Slanted Oval)
    canvas.save();
    // Position head at the bottom left of the stem
    canvas.translate(headWidth * 0.4, size.height - headHeight * 0.6);
    canvas.rotate(-0.3); // Traditional slant

    if (unit == 2) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = stemWidth;
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: headWidth, height: headHeight),
      paint,
    );
    canvas.restore();

    // 2. Draw Stem (On the right, going UP)
    paint.style = PaintingStyle.fill;
    final double stemX = headWidth * 0.8;
    final double stemTop = size.height - stemHeight - headHeight * 0.2;
    final double stemBottom = size.height - headHeight * 0.6;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(stemX, stemTop, stemX + stemWidth, stemBottom),
        const Radius.circular(1),
      ),
      paint,
    );

    // 3. Draw Flags (for Quavers and Semiquavers)
    if (unit >= 8) {
      _drawFlag(canvas, paint, stemX + stemWidth, stemTop, size.width);
      if (unit >= 16) {
        _drawFlag(canvas, paint, stemX + stemWidth, stemTop + size.height * 0.2, size.width);
      }
    }
  }

  void _drawFlag(Canvas canvas, Paint paint, double x, double y, double width) {
    final path = Path();
    path.moveTo(x, y);
    // Classical flag shape
    path.cubicTo(
      x + width * 0.6, y + width * 0.2,
      x + width * 0.7, y + width * 0.6,
      x + width * 0.2, y + width * 0.9
    );
    path.cubicTo(
      x + width * 0.5, y + width * 0.6,
      x + width * 0.4, y + width * 0.3,
      x, y + width * 0.2
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
