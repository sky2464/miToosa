import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Full-bleed atmospheric background. Adapts surface and glow to the current
/// brightness — dark uses the Aetheric Pulse dark tokens, light uses the
/// AethericPulseLight off-white surface with a soft blue radial glow.
class KineticBackground extends StatelessWidget {
  final Widget child;

  const KineticBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? AethericPulseDark.surface
        : AethericPulseLight.lightSurface;
    final glow = isDark ? AethericPulseDark.heroGlow : _lightHeroGlow;

    return Stack(
      children: [
        Positioned.fill(child: ColoredBox(color: surface)),
        Positioned(
          top: -200,
          left: 0,
          right: 0,
          child: Container(
            height: 600,
            decoration: BoxDecoration(gradient: glow),
          ),
        ),
        child,
      ],
    );
  }

  // Soft blue radial glow at reduced opacity for light surfaces.
  static const RadialGradient _lightHeroGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.0,
    colors: [Color(0x26597AFA), Color(0x00597AFA)],
  );
}
