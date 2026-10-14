import 'package:flutter/material.dart';

import '../../theme/design_system.dart';

/// Compact objective shown during gameplay (BL-24 AC-005).
class TutorialObjectiveStrip extends StatelessWidget {
  final String objective;
  final String livePrompt;

  const TutorialObjectiveStrip({
    super.key,
    required this.objective,
    required this.livePrompt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: 'Level objective: $objective. Current prompt: $livePrompt',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: MiToosaTheme.spacingMd,
          vertical: MiToosaTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              objective,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              livePrompt,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
