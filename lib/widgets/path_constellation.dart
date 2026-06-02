import 'dart:math';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum PathNodeState { done, current, locked }

enum PathNodeType { regular, bonus, boss }

class PathLevel {
  final int n;
  final PathNodeState state;
  final PathNodeType type;
  const PathLevel({required this.n, required this.state, required this.type});
}

/// Vertical S-curve constellation of level nodes. Dashed connections in muted
/// gradient; solid path through completed levels with blue glow.
///
/// [onTapLevel] is called with the 0-based index of the tapped node.
/// Only done and current nodes are tappable; locked nodes receive no callback.
class PathConstellation extends StatelessWidget {
  final List<PathLevel> levels;
  final double rowHeight;
  final void Function(int levelIndex)? onTapLevel;

  const PathConstellation({
    super.key,
    required this.levels,
    this.rowHeight = 84,
    this.onTapLevel,
  });

  @override
  Widget build(BuildContext context) {
    const maxWidth = 320.0;
    final h = levels.length * rowHeight + 40;

    // Compute node positions
    final positions = <Offset>[];
    for (int i = 0; i < levels.length; i++) {
      final phase = sin(i * 0.7) * 0.5 + 0.5;
      final x = 36 + phase * (maxWidth - 72);
      final y = i * rowHeight + 40;
      positions.add(Offset(x, y));
    }

    final doneCount =
        levels.where((l) => l.state == PathNodeState.done).length +
        (levels.any((l) => l.state == PathNodeState.current) ? 1 : 0);

    return Center(
      child: SizedBox(
        width: maxWidth,
        height: h,
        child: Stack(
          children: [
            // Path lines
            Positioned.fill(
              child: CustomPaint(
                painter: _PathLinePainter(
                  positions: positions,
                  doneCount: doneCount,
                ),
              ),
            ),
            // Nodes
            for (int i = 0; i < levels.length; i++)
              Positioned(
                left: positions[i].dx - _nodeSize(levels[i]) / 2,
                top: positions[i].dy - _nodeSize(levels[i]) / 2,
                child: _PathNodeView(
                  level: levels[i],
                  onTap:
                      levels[i].state != PathNodeState.locked &&
                          onTapLevel != null
                      ? () => onTapLevel!(i)
                      : null,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _nodeSize(PathLevel l) => l.type == PathNodeType.boss ? 60 : 48;
}

class _PathLinePainter extends CustomPainter {
  final List<Offset> positions;
  final int doneCount;
  _PathLinePainter({required this.positions, required this.doneCount});

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    // Dashed full path (muted)
    final dashedPath = Path()..moveTo(positions[0].dx, positions[0].dy);
    for (int i = 1; i < positions.length; i++) {
      dashedPath.lineTo(positions[i].dx, positions[i].dy);
    }
    _drawDashedPath(
      canvas,
      dashedPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AP.emerald,
            AP.blueLight,
            Colors.white.withValues(alpha: 0.08),
          ],
        ).createShader(Offset.zero & size)
        ..color = AP.blueLight.withValues(alpha: 0.5),
    );

    // Solid completed segment with glow
    if (doneCount > 1) {
      final solid = Path()..moveTo(positions[0].dx, positions[0].dy);
      for (int i = 1; i < doneCount && i < positions.length; i++) {
        solid.lineTo(positions[i].dx, positions[i].dy);
      }
      final solidPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AP.emerald, AP.blueLight],
        ).createShader(Offset.zero & size)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(solid, solidPaint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final dashWidth = 2.0;
    final dashSpace = 6.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashSpace;
        if (draw) {
          canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        }
        distance += len;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(_PathLinePainter old) =>
      old.positions != positions || old.doneCount != doneCount;
}

class _PathNodeView extends StatelessWidget {
  final PathLevel level;
  final VoidCallback? onTap;
  const _PathNodeView({required this.level, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBoss = level.type == PathNodeType.boss;
    final size = isBoss ? 60.0 : 48.0;

    final (gradient, borderColor, glowColor) = _stateColors();

    final semanticsLabel = switch (level.state) {
      PathNodeState.done => 'Level ${level.n} completed',
      PathNodeState.current => 'Level ${level.n}, current',
      PathNodeState.locked => 'Level ${level.n}, locked',
    };

    final node = SizedBox(
      width: size,
      height: size + (level.state == PathNodeState.current ? 28 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Pulse ring for current
          if (level.state == PathNodeState.current)
            Positioned(left: -8, top: -8, child: _PulseRing(size: size + 16)),
          // Node circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
              color: level.state == PathNodeState.locked
                  ? Colors.white.withValues(alpha: 0.05)
                  : null,
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: glowColor != null
                  ? [BoxShadow(color: glowColor, blurRadius: 14)]
                  : null,
            ),
            child: Center(
              child: switch (level.state) {
                PathNodeState.locked => const Icon(
                  Icons.lock,
                  color: AP.fgMuted,
                  size: 18,
                ),
                PathNodeState.done => const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 22,
                ),
                PathNodeState.current => Text(
                  '${level.n}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isBoss ? 18 : 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              },
            ),
          ),
          // "You are here" pill for current
          if (level.state == PathNodeState.current)
            Positioned(
              top: size + 4,
              left: -16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AP.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(AP.radiusPill),
                  border: Border.all(
                    color: AP.blueLight.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AP.blueLight.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Text(
                  'YOU ARE HERE',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFBFDBFE),
                    letterSpacing: 0.72,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: node,
      ),
    );
  }

  (LinearGradient?, Color, Color?) _stateColors() {
    if (level.state == PathNodeState.current) {
      return (
        AP.gradPrimary,
        AP.blueLight.withValues(alpha: 0.8),
        AP.blueLight.withValues(alpha: 0.7),
      );
    }
    if (level.state == PathNodeState.done) {
      return (
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
        ),
        AP.emerald.withValues(alpha: 0.5),
        AP.emerald.withValues(alpha: 0.3),
      );
    }
    if (level.type == PathNodeType.boss) {
      return (
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF59E0B), Color(0xFFFB923C)],
        ),
        AP.amber.withValues(alpha: 0.5),
        AP.amber.withValues(alpha: 0.25),
      );
    }
    return (null, Colors.white.withValues(alpha: 0.1), null);
  }
}

class _PulseRing extends StatefulWidget {
  final double size;
  const _PulseRing({required this.size});

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        return Opacity(
          opacity: 1.0 - t * 0.55,
          child: Transform.scale(
            scale: 1.0 + t * 0.05,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AP.blueLight.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
