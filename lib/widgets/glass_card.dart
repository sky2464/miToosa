import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../theme/design_tokens.dart';

/// Aetheric Pulse glass card — theme-aware fill, blur, border, and shadows.
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
    final theme = APTheme.of(context);
    final shadows = boxShadow ??
        (neonGlow ? AethericPulseDark.blueGlow : theme.cardShadows);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.glassFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: theme.glassBorder, width: 1),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}
