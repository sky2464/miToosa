import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class SkillScore {
  final String name;
  final double value; // 0-100
  final Color color;
  const SkillScore({required this.name, required this.value, required this.color});
}

/// Hexagonal cognitive radar — concentric ring guides + filled polygon + vertex dots.
class SkillRadar extends StatelessWidget {
  final List<SkillScore> skills;
  final double size;

  const SkillRadar({super.key, required this.skills, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RadarPainter(skills)),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<SkillScore> skills;
  _RadarPainter(this.skills);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width / 2 - 8;
    final n = skills.length;

    // Concentric ring guides
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.06);
    for (final r in [0.25, 0.5, 0.75, 1.0]) {
      canvas.drawCircle(Offset(cx, cy), maxR * r, ringPaint);
    }

    // Axis spokes
    final spokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.05);
    for (int i = 0; i < n; i++) {
      final a = (i / n) * 2 * pi - pi / 2;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + cos(a) * maxR, cy + sin(a) * maxR),
        spokePaint,
      );
    }

    // Polygon points
    final pts = <Offset>[];
    for (int i = 0; i < n; i++) {
      final a = (i / n) * 2 * pi - pi / 2;
      final r = (skills[i].value / 100) * maxR;
      pts.add(Offset(cx + cos(a) * r, cy + sin(a) * r));
    }

    // Fill polygon
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AP.blue.withValues(alpha: 0.4),
          AP.purple.withValues(alpha: 0.4),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AP.blueLight
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, outlinePaint);

    final outlineSharp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AP.blueLight;
    canvas.drawPath(path, outlineSharp);

    // Vertex dots
    for (int i = 0; i < pts.length; i++) {
      final dotPaint = Paint()
        ..color = skills[i].color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(pts[i], 3, dotPaint);
      canvas.drawCircle(pts[i], 3, Paint()..color = skills[i].color);
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.skills != skills;
}
