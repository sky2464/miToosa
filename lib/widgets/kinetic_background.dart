import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Full-bleed atmospheric background for the Kinetic Obsidian theme.
/// Two distant radial blobs: proton-purple top-left, electric-cyan bottom-right.
class KineticBackground extends StatelessWidget {
  final Widget child;

  const KineticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Obsidian base
        Positioned.fill(
          child: ColoredBox(color: KineticObsidian.surface),
        ),
        // Purple bloom — top-left
        Positioned(
          top: -120, left: -120,
          child: _GlowBlob(
            size: 500,
            color: KineticObsidian.protonPurple.withValues(alpha: 0.18),
          ),
        ),
        // Cyan bloom — bottom-right
        Positioned(
          bottom: -120, right: -120,
          child: _GlowBlob(
            size: 500,
            color: KineticObsidian.electricCyan.withValues(alpha: 0.12),
          ),
        ),
        // Content on top
        child,
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
