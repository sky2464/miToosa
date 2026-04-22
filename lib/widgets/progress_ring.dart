import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Circular progress ring with kinetic gradient arc and neon glow.
class ProgressRing extends StatelessWidget {
  final double percent;   // 0–100
  final double size;
  final double strokeWidth;
  final Widget? centerChild;

  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 160,
    this.strokeWidth = 8,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark
        ? KineticObsidian.surfaceContainerHigh
        : AethericPulseLight.lightSurfaceContainerHigh;
    final arcColors = isDark
        ? const [KineticObsidian.protonPurple, KineticObsidian.electricCyan]
        : const [AethericPulseLight.softBlue, AethericPulseLight.pinkPastel];
    final glowColor = isDark
        ? KineticObsidian.electricCyan
        : AethericPulseLight.softBlue;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              percent: percent.clamp(0, 100) / 100,
              strokeWidth: strokeWidth,
              trackColor: trackColor,
              arcColors: arcColors,
              glowColor: glowColor,
            ),
          ),
          ?centerChild,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double strokeWidth;
  final Color trackColor;
  final List<Color> arcColors;
  final Color glowColor;

  const _RingPainter({
    required this.percent,
    required this.strokeWidth,
    required this.trackColor,
    required this.arcColors,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * percent;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (percent <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * pi,
        colors: arcColors,
        tileMode: TileMode.clamp,
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, gradientPaint);

    final tipAngle = startAngle + sweepAngle;
    final tipX = center.dx + radius * cos(tipAngle);
    final tipY = center.dy + radius * sin(tipAngle);
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2, glowPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
