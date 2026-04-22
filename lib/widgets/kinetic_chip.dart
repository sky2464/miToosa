import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Aetheric Pulse pill chip.
/// Purple 20% fill, 1px purple border, borderRadius 999.
/// Used for stat pills (XP, streak, energy) and category labels.
class KineticChip extends StatelessWidget {
  final String label;
  final Widget? leading;
  final Color? color;

  const KineticChip({
    super.key,
    required this.label,
    this.leading,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = (color ?? AethericPulseDark.brandPurple).withValues(alpha: 0.20);
    final borderColor = (color ?? AethericPulseDark.brandPurple).withValues(alpha: 0.30);
    final labelColor = color ?? AethericPulseDark.brandPurple;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AethericPulseDark.label(color: labelColor),
          ),
        ],
      ),
    );
  }
}
