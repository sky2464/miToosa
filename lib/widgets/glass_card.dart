import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Kinetic Obsidian glass card.
/// 50% surface-container fill, 16 px backdrop blur, top/left lit edge.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<BoxShadow>? boxShadow;
  final bool neonGlow;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = KineticObsidian.radiusLg,
    this.padding = const EdgeInsets.all(KineticObsidian.spaceMd),
    this.boxShadow,
    this.neonGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: KineticObsidian.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: const Border(
              top: BorderSide(color: KineticObsidian.glassBorderBright, width: 1),
              left: BorderSide(color: KineticObsidian.glassBorderBright, width: 1),
              right: BorderSide(color: KineticObsidian.glassBorderDim, width: 1),
              bottom: BorderSide(color: KineticObsidian.glassBorderDim, width: 1),
            ),
            boxShadow: boxShadow ??
                (neonGlow ? KineticObsidian.shadowNeonSoft : null),
          ),
          child: child,
        ),
      ),
    );
  }
}
