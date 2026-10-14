import 'package:flutter/material.dart';

import '../../../core/models/gameplay_level.dart';
import '../../../theme/design_system.dart';

/// Bottom sheet that lets the player choose a difficulty tier before a level.
class DifficultySelectionSheet extends StatelessWidget {
  final void Function(DifficultyTier tier) onSelect;

  const DifficultySelectionSheet({super.key, required this.onSelect});

  static const _tiers = [
    (tier: DifficultyTier.easy, emoji: '🟢', label: 'Easy', sub: '30 sec'),
    (tier: DifficultyTier.medium, emoji: '🟡', label: 'Medium', sub: '15 sec'),
    (tier: DifficultyTier.hard, emoji: '🟠', label: 'Hard', sub: '7 sec'),
    (
      tier: DifficultyTier.challenge,
      emoji: '🔴',
      label: 'Challenge',
      sub: '4 sec',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MiToosaTheme.spacingLg,
          MiToosaTheme.spacingLg,
          MiToosaTheme.spacingLg,
          MiToosaTheme.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: MiToosaTheme.spacingLg),
            Text(
              'Choose Difficulty',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'How fast can you think? ⏱️',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: MiToosaTheme.spacingLg),
            ...(_tiers.map(
              (t) => _TierTile(
                emoji: t.emoji,
                label: t.label,
                sub: t.sub,
                onTap: () => onSelect(t.tier),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TierTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _TierTile({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MiToosaTheme.spacingSm),
      child: Semantics(
        button: true,
        label: '$label. $sub',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MiToosaTheme.spacingLg,
              vertical: MiToosaTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
              boxShadow: MiToosaTheme.shadowCard,
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: MiToosaTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        sub,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
