import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/achievement_engine.dart';
import '../../core/models/achievement.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';

/// Full-screen achievements list.
///
/// Shows every catalog achievement with progress bar and unlock state.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load achievements.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        data: (progress) {
          final unlocked = Set<String>.from(progress.unlockedAchievements);
          final totalLevels = progress.levelStars.length;
          final totalStars = progress.levelStars.values.fold<int>(
            0,
            (s, v) => s + v,
          );

          return ListView.separated(
            padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
            itemCount: AchievementEngine.catalog.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: MiToosaTheme.spacingSm),
            itemBuilder: (context, index) {
              final a = AchievementEngine.catalog[index];
              final isUnlocked = unlocked.contains(a.id);
              final pct = AchievementEngine.progressFor(
                achievementId: a.id,
                totalLevelsCompleted: totalLevels,
                totalStars: totalStars,
                totalXP: progress.totalXP,
                currentStreak: progress.streakCount,
                achievementProgress: progress.achievementProgress,
              );

              return _AchievementTile(
                achievement: a,
                isUnlocked: isUnlocked,
                progress: pct,
              );
            },
          );
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final double progress;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = isUnlocked ? 1.0 : 0.7;

    return Opacity(
      opacity: opacity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
          child: Row(
            children: [
              // Status icon
              if (isUnlocked)
                const Icon(Icons.check_circle, color: Colors.green, size: 32)
              else
                Icon(
                  Icons.emoji_events_outlined,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 32,
                ),
              const SizedBox(width: MiToosaTheme.spacingMd),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      achievement.description,
                      style: theme.textTheme.bodySmall,
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: MiToosaTheme.spacingSm),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: MiToosaTheme.spacingSm),
              // Coin reward badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🪙 ${achievement.coinReward}',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
