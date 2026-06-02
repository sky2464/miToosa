import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Aetheric Pulse glass card.
/// rgba(255,255,255,0.08) fill, 24px backdrop blur, uniform 1px border,
/// outer drop shadow + inner white glow. Default radius 24px.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? boxShadow;
  final bool neonGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AethericPulseDark.radiusCard,
    this.padding = const EdgeInsets.all(AethericPulseDark.spaceLg),
    this.boxShadow,
    this.neonGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final shadows =
        boxShadow ??
        (neonGlow
            ? AethericPulseDark.blueGlow
            : [...AethericPulseDark.cardOuter, ...AethericPulseDark.cardInner]);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AethericPulseDark.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: AethericPulseDark.glassBorder, width: 1),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
