import 'package:flutter/material.dart';

import '../../theme/design_system.dart';

/// Streak calendar widget showing current streak, best streak, and freeze count.
class StreakCalendarWidget extends StatelessWidget {
  final int streakCount;
  final int bestStreak;
  final List<DateTime> playHistory;
  final int streakFreezeCount;
  final int? nextMilestone;
  final int nextMilestoneReward;

  const StreakCalendarWidget({
    super.key,
    required this.streakCount,
    required this.bestStreak,
    required this.playHistory,
    this.streakFreezeCount = 0,
    this.nextMilestone,
    this.nextMilestoneReward = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
        child: Column(
          children: [
            // ─── Streak header ──────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 40)),
                const SizedBox(width: MiToosaTheme.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$streakCount',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text('day streak', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: MiToosaTheme.spacingMd),

            // ─── Stats row ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatChip(label: 'Best: $bestStreak', icon: Icons.emoji_events),
                _StatChip(
                  label: '$streakFreezeCount freezes',
                  icon: Icons.ac_unit,
                ),
              ],
            ),

            // ─── Next milestone reward ──────────
            if (nextMilestone != null) ...[
              const SizedBox(height: MiToosaTheme.spacingMd),
              _MilestoneProgress(
                streakCount: streakCount,
                nextMilestone: nextMilestone!,
                reward: nextMilestoneReward,
              ),
            ],

            // ─── Calendar dots ──────────────────
            if (playHistory.isNotEmpty) ...[
              const SizedBox(height: MiToosaTheme.spacingMd),
              _CalendarDots(playHistory: playHistory),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

/// Renders the last 30 days as small dots (filled if played that day).
class _CalendarDots extends StatelessWidget {
  final List<DateTime> playHistory;

  const _CalendarDots({required this.playHistory});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final playDays = playHistory
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(30, (i) {
        final date = DateTime(today.year, today.month, today.day - (29 - i));
        final played = playDays.contains(date);
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: played
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        );
      }),
    );
  }
}

class _MilestoneProgress extends StatelessWidget {
  final int streakCount;
  final int nextMilestone;
  final int reward;

  const _MilestoneProgress({
    required this.streakCount,
    required this.nextMilestone,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (streakCount / nextMilestone).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next: Day $nextMilestone',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '🪙 $reward coins',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$streakCount / $nextMilestone days',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
