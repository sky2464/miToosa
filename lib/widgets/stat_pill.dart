import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Tint palette for [StatPill].
enum StatPillTint { blue, orange, purple, amber, cyan, pink, emerald }

/// Inline chip with icon + label + optional outer glow. Used in the stat strip
/// on the Tracks screen and elsewhere for status badges.
class StatPill extends StatelessWidget {
  final Widget? icon;
  final String label;
  final StatPillTint tint;
  final bool glow;

  const StatPill({
    super.key,
    this.icon,
    required this.label,
    this.tint = StatPillTint.blue,
    this.glow = false,
  });

  ({Color c, Color bg, Color bd}) _resolve() {
    switch (tint) {
      case StatPillTint.orange:
        return (
          c: AP.orange,
          bg: AP.orange.withValues(alpha: 0.10),
          bd: AP.orange.withValues(alpha: 0.30),
        );
      case StatPillTint.purple:
        return (
          c: AP.purple,
          bg: AP.purple.withValues(alpha: 0.10),
          bd: AP.purple.withValues(alpha: 0.30),
        );
      case StatPillTint.amber:
        return (
          c: AP.amber,
          bg: AP.amber.withValues(alpha: 0.10),
          bd: AP.amber.withValues(alpha: 0.30),
        );
      case StatPillTint.cyan:
        return (
          c: AP.cyan,
          bg: AP.cyan.withValues(alpha: 0.10),
          bd: AP.cyan.withValues(alpha: 0.30),
        );
      case StatPillTint.pink:
        return (
          c: AP.pink,
          bg: AP.pink.withValues(alpha: 0.10),
          bd: AP.pink.withValues(alpha: 0.30),
        );
      case StatPillTint.emerald:
        return (
          c: AP.emerald,
          bg: AP.emerald.withValues(alpha: 0.10),
          bd: AP.emerald.withValues(alpha: 0.30),
        );
      case StatPillTint.blue:
        return (
          c: AP.blueLight,
          bg: AP.blueLight.withValues(alpha: 0.10),
          bd: AP.blueLight.withValues(alpha: 0.30),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _resolve();
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(AP.radiusPill),
        border: Border.all(color: t.bd, width: 1),
        boxShadow: glow ? [BoxShadow(color: t.bd, blurRadius: 14)] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(color: t.c, size: 14),
              child: icon!,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: t.c,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
