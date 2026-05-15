import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// 5-dot progress strip — Aetheric Pulse rhythm for gameplay top chrome.
///
/// S2-03 AC-001: replaces the linear progress bar. Fills dots left-to-right
/// based on [progress] (0..1). Filled dots widen to a pill and use the
/// blue→purple primary gradient; empty dots are subtle white pebbles.
class DotProgressStrip extends StatelessWidget {
  /// Fraction in [0..1] of the level / session completed.
  final double progress;

  /// Total number of dots in the strip. Defaults to 5 per the spec.
  final int totalDots;

  const DotProgressStrip({
    super.key,
    required this.progress,
    this.totalDots = 5,
  });

  @override
  Widget build(BuildContext context) {
    final filled =
        (progress.clamp(0.0, 1.0) * totalDots).ceil().clamp(0, totalDots);
    return Semantics(
      label: 'Progress: $filled of $totalDots',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalDots, (i) {
          final isOn = i < filled;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              width: isOn ? 22 : 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: isOn ? AP.gradPrimary : null,
                color: isOn ? null : Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
