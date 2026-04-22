import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Full-bleed atmospheric background for the Aetheric Pulse dark theme.
/// Single top-center blue radial glow on a deep #0a0d17 surface.
class KineticBackground extends StatelessWidget {
  final Widget child;

  const KineticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep #0a0d17 base
        const Positioned.fill(
          child: ColoredBox(color: AethericPulseDark.surface),
        ),
        // Top-center blue radial glow
        Positioned(
          top: -200,
          left: 0,
          right: 0,
          child: Container(
            height: 600,
            decoration: const BoxDecoration(
              gradient: AethericPulseDark.heroGlow,
            ),
          ),
        ),
        // Content on top
        child,
      ],
    );
  }
}
