import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Animated atmosphere background — three radial gradient blobs + a faint star
/// field. Used as the bottom layer of every screen. Drifts slowly.
class Atmosphere extends StatefulWidget {
  /// Accent palette for the top glow. 'blue' (default), 'cyan', or 'pink'.
  final String accent;

  const Atmosphere({super.key, this.accent = 'blue'});

  @override
  State<Atmosphere> createState() => _AtmosphereState();
}

class _AtmosphereState extends State<Atmosphere> with TickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _topColor {
    switch (widget.accent) {
      case 'cyan':
        return AP.cyan.withValues(alpha: 0.42);
      case 'pink':
        return AP.pink.withValues(alpha: 0.42);
      default:
        return AP.blue.withValues(alpha: 0.42);
    }
  }

  Color get _bottomColor {
    switch (widget.accent) {
      case 'cyan':
        return AP.blue.withValues(alpha: 0.32);
      case 'pink':
        return AP.purple.withValues(alpha: 0.32);
      default:
        return AP.purple.withValues(alpha: 0.32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value * 2 * pi;
            return Stack(
              fit: StackFit.expand,
              children: [
                // Top center blob
                Positioned(
                  top: -120 + sin(t) * 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 520,
                      height: 520,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [_topColor, Colors.transparent],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom right blob
                Positioned(
                  bottom: -100 + cos(t) * 15,
                  right: -80,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [_bottomColor, Colors.transparent],
                        stops: const [0.0, 0.65],
                      ),
                    ),
                  ),
                ),
                // Mid left blob
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  left: -120,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AP.blueLight.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6],
                      ),
                    ),
                  ),
                ),
                // Star field
                CustomPaint(size: Size.infinite, painter: _StarFieldPainter()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..blendMode = BlendMode.screen;
    final rng = Random(42);
    for (int i = 0; i < 28; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.2 + 0.4;
      final opacity = rng.nextDouble() * 0.4 + 0.3;
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_StarFieldPainter old) => false;
}
