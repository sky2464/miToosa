import 'dart:math';
import 'package:flutter/material.dart';
import '../core/models/puzzle.dart';
import '../core/models/shape_item.dart';

class ShapeRenderer extends StatelessWidget {
  final ShapeItem item;
  final double size;

  const ShapeRenderer({super.key, required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(item: item),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeItem item;

  _ShapePainter({required this.item});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = item.color.value
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    paint.style = item.fill == ShapeFill.outlined
        ? PaintingStyle.stroke
        : PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;

    switch (item.shape) {
      case Shape.circle:
        canvas.drawCircle(Offset(cx, cy), r, paint);
        if (item.fill == ShapeFill.striped) {
          _drawStripes(canvas, size, paint);
        }

      case Shape.square:
        final rr = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: r * 1.8, height: r * 1.8),
          Radius.circular(r * 0.2),
        );
        canvas.drawRRect(rr, paint);

      case Shape.triangle:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy + r * 0.8)
          ..lineTo(cx - r, cy + r * 0.8)
          ..close();
        canvas.drawPath(path, paint);

      case Shape.star:
        canvas.drawPath(_starPath(cx, cy, r, 5), paint);

      case Shape.hexagon:
        canvas.drawPath(_polygonPath(cx, cy, r, 6), paint);

      case Shape.diamond:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.7, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.7, cy)
          ..close();
        canvas.drawPath(path, paint);
    }
  }

  Path _starPath(double cx, double cy, double r, int points) {
    final path = Path();
    final innerR = r * 0.4;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : innerR;
      final angle = (pi / 2 * -1) + (i * pi / points);
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _polygonPath(double cx, double cy, double r, int sides) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (pi / 2 * -1) + (i * 2 * pi / sides);
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawStripes(Canvas canvas, Size size, Paint paint) {
    final stripePaint = Paint()
      ..color = paint.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (double y = 3; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) => old.item != item;
}
