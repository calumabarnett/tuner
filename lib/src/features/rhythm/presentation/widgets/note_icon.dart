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
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SingleNote(unit: unit * (subdivision == 3 ? 2 : 2), color: color, size: size * 0.7),
          const SizedBox(width: 2),
          _SingleNote(unit: unit * (subdivision == 3 ? 2 : 2), color: color, size: size * 0.7),
          if (subdivision >= 3) ...[
            const SizedBox(width: 2),
            _SingleNote(unit: unit * (subdivision == 3 ? 2 : 2), color: color, size: size * 0.7),
          ],
          if (subdivision >= 4) ...[
            const SizedBox(width: 2),
            _SingleNote(unit: unit * 2, color: color, size: size * 0.7),
          ],
        ],
      );
    }
    return _SingleNote(unit: unit, color: color, size: size);
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
      size: Size(size, size * 1.5),
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
      ..style = PaintingStyle.fill;

    final double headWidth = size.width * 0.6;
    final double headHeight = size.width * 0.45;
    final double stemWidth = size.width * 0.1;
    final double stemHeight = size.height * 0.8;

    // Draw Note Head
    canvas.save();
    canvas.translate(headWidth * 0.4, size.height - headHeight / 2);
    canvas.rotate(-0.2);

    if (unit == 2) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = stemWidth;
    }

    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: headWidth, height: headHeight),
      paint,
    );
    canvas.restore();

    // Draw Stem
    paint.style = PaintingStyle.fill;
    final double stemX = headWidth * 0.75;
    canvas.drawRect(
      Rect.fromLTWH(stemX, size.height - stemHeight - headHeight / 4, stemWidth, stemHeight),
      paint,
    );

    // Draw Flags
    if (unit >= 8) {
      final double flagX = stemX + stemWidth;
      final double flagY = size.height - stemHeight - headHeight / 4;

      _drawFlag(canvas, paint, flagX, flagY, size.width);

      if (unit >= 16) {
        _drawFlag(canvas, paint, flagX, flagY + size.width * 0.25, size.width);
      }
    }
  }

  void _drawFlag(Canvas canvas, Paint paint, double x, double y, double width) {
    final path = Path();
    path.moveTo(x, y);
    path.quadraticBezierTo(x + width * 0.5, y + width * 0.2, x + width * 0.4, y + width * 0.6);
    path.quadraticBezierTo(x + width * 0.5, y + width * 0.3, x, y + width * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
