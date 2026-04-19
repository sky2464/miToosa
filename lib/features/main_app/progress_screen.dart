import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/engine/daily_reward_engine.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../achievements/achievements_screen.dart';
import '../daily_rewards/daily_rewards_modal.dart';
import '../streak/streak_calendar_screen.dart';
import '../settings/settings_screen.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  void _showDailyRewards(BuildContext context, WidgetRef ref, PlayerProgress progress) {
    final currentDay = progress.dailyRewardDay == 0
        ? 1
        : DailyRewardEngine.nextDay(progress.dailyRewardDay);
    final canClaim = DailyRewardEngine.canClaim(
      lastClaim: progress.lastDailyRewardClaim,
      now: DateTime.now(),
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => DailyRewardsModal(
        currentDay: currentDay,
        onClaim: () async {
          if (!canClaim) {
            Navigator.of(modalContext).pop();
            return;
          }
          final reward = DailyRewardEngine.fullCycleRewards()
              .firstWhere((r) => r.day == currentDay);
          final playerId = ref.read(playerProgressProvider).value?.playerId;
          if (playerId == null) return;
          final persistence = ref.read(persistenceProvider);
          final p = await persistence.loadProgress(playerId);
          p.addCoins(reward.coins);
          p.claimDailyReward(currentDay, DateTime.now());
          await persistence.saveProgress(p);
          ref.invalidate(playerProgressProvider);
          if (modalContext.mounted) {
            Navigator.of(modalContext).pop();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            key: const ValueKey('settings_button'),
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: progressAsync.when(
        data: (progress) {
          // Calculate stats
          final levelsCompleted = progress.levelStars.length;
          final totalXP = progress.totalXP;
          final hearts = progress.hearts;
          final diamonds = progress.diamonds;
          final bestStreak = progress.bestStreak;
          final currentStreak = progress.streakCount;

          return ListView(
            padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
            children: [
              // XP Card
              _StatCard(
                theme: theme,
                icon: Icons.bolt,
                label: 'Total XP',
                value: totalXP.toString(),
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.7)],
                ),
              ),
              const SizedBox(height: MiToosaTheme.spacingMd),
              // Row with hearts and diamonds
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      icon: Icons.favorite,
                      label: 'Hearts',
                      value: '$hearts / 5',
                      gradient: LinearGradient(
                        colors: [Colors.red, Colors.red.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                  const SizedBox(width: MiToosaTheme.spacingMd),
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      icon: Icons.diamond_outlined,
                      label: 'Diamonds',
                      value: diamonds.toString(),
                      gradient: const LinearGradient(
                        colors: [Colors.cyan, Colors.blue],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MiToosaTheme.spacingMd),
              // Row with streaks
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      icon: Icons.local_fire_department,
                      label: 'Current Streak',
                      value: currentStreak.toString(),
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                    ),
                  ),
                  const SizedBox(width: MiToosaTheme.spacingMd),
                  Expanded(
                    child: _StatCard(
                      theme: theme,
                      icon: Icons.star,
                      label: 'Best Streak',
                      value: bestStreak.toString(),
                      gradient: LinearGradient(
                        colors: [MiToosaTheme.warning, MiToosaTheme.warning.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MiToosaTheme.spacingMd),
              // Levels Completed
              _StatCard(
                theme: theme,
                icon: Icons.check_circle,
                label: 'Levels Completed',
                value: levelsCompleted.toString(),
                gradient: LinearGradient(
                  colors: [MiToosaTheme.success, MiToosaTheme.success.withValues(alpha: 0.7)],
                ),
              ),
              const SizedBox(height: MiToosaTheme.spacingLg),
              // ─── Feature shortcuts ───────────────────────
              _FeatureButton(
                key: const ValueKey('achievements_button'),
                icon: Icons.emoji_events,
                label: 'Achievements',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                ),
              ),
              const SizedBox(height: MiToosaTheme.spacingSm),
              _FeatureButton(
                key: const ValueKey('daily_rewards_button'),
                icon: Icons.card_giftcard,
                label: 'Daily Rewards',
                onTap: () => _showDailyRewards(context, ref, progress),
              ),
              const SizedBox(height: MiToosaTheme.spacingSm),
              _FeatureButton(
                key: const ValueKey('streak_calendar_button'),
                icon: Icons.local_fire_department,
                label: 'Streak Calendar',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StreakCalendarScreen(
                      streakCount: progress.streakCount,
                      bestStreak: progress.bestStreak,
                      playHistory: progress.playHistory,
                      streakFreezeCount: progress.streakFreezeCount,
                      nextMilestone: progress.nextMilestone,
                      nextMilestoneReward: progress.nextMilestoneReward,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;
  final LinearGradient gradient;

  const _StatCard({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(MiToosaTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: Colors.white),
              const SizedBox(width: MiToosaTheme.spacingSm),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: MiToosaTheme.spacingSm),
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.titleSmall),
      trailing: Icon(Icons.chevron_right,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      onTap: onTap,
    );
  }
}
