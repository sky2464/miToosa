import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/progression_engine.dart';
import '../../data/hive_persistence_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';

/// Settings screen for miToosa.
///
/// Displays the player's [MasteryTier] badge and allows toggling the adaptive
/// difficulty system on or off.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load settings.', style: theme.textTheme.bodyMedium),
        ),
        data: (progress) => _SettingsBody(progress: progress),
      ),
    );
  }
}

// ─── Settings Body ───────────────────────────────────────────

class _SettingsBody extends ConsumerWidget {
  final PlayerProgress progress;

  const _SettingsBody({required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ProgressionEngine.computeMasteryTier(progress.adaptiveHistory);
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
      children: [
        // ─── Mastery Tier Badge ─────────────────────────
        Text(
          'Your Progress',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: MiToosaTheme.spacingSm),
        _MasteryTierCard(tier: tier, levelCount: progress.adaptiveHistory.length),
        const SizedBox(height: MiToosaTheme.spacingLg),

        // ─── Adaptive Difficulty Toggle ─────────────────
        Text(
          'Difficulty',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: MiToosaTheme.spacingSm),
        Card(
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MiToosaTheme.spacingMd,
              vertical: MiToosaTheme.spacingSm,
            ),
            title: Text(
              'Adaptive Difficulty',
              style: theme.textTheme.titleSmall,
            ),
            subtitle: Text(
              'Automatically adjusts level difficulty based on your recent '
              'performance. Requires at least 5 completed levels.',
              style: theme.textTheme.bodySmall,
            ),
            value: progress.difficultyMode == DifficultyMode.adaptive,
            onChanged: (enabled) async {
              progress.difficultyMode =
                  enabled ? DifficultyMode.adaptive : DifficultyMode.standard;
              await HivePersistenceProvider().saveProgress(progress);
              ref.invalidate(playerProgressProvider);
            },
          ),
        ),
      ],
    );
  }
}

// ─── Mastery Tier Card ───────────────────────────────────────

class _MasteryTierCard extends StatelessWidget {
  final MasteryTier tier;
  final int levelCount;

  const _MasteryTierCard({required this.tier, required this.levelCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (label, color, emoji) = switch (tier) {
      MasteryTier.gold   => ('Gold',   const Color(0xFFFFD700), '🥇'),
      MasteryTier.silver => ('Silver', const Color(0xFFC0C0C0), '🥈'),
      MasteryTier.bronze => ('Bronze', const Color(0xFFCD7F32), '🥉'),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(width: MiToosaTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label Mastery',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    levelCount == 0
                        ? 'Complete levels to build your history.'
                        : 'Based on $levelCount completed level${levelCount == 1 ? '' : 's'}.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
