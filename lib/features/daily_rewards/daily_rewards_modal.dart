import 'package:flutter/material.dart';

import '../../core/engine/daily_reward_engine.dart';
import '../../theme/design_system.dart';

/// Bottom-sheet modal showing the 7-day daily reward cycle.
class DailyRewardsModal extends StatelessWidget {
  final int currentDay; // 1–7 (which day to highlight)
  final VoidCallback onClaim;

  const DailyRewardsModal({
    super.key,
    required this.currentDay,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rewards = DailyRewardEngine.fullCycleRewards();

    return Padding(
      padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Daily Rewards',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: MiToosaTheme.spacingMd),
          Wrap(
            spacing: MiToosaTheme.spacingSm,
            runSpacing: MiToosaTheme.spacingSm,
            children: rewards.map((r) {
              final isCurrent = r.day == currentDay;
              final isPast = r.day < currentDay;
              return _DayTile(
                key: ValueKey('daily_reward_day_${r.day}'),
                reward: r,
                isCurrent: isCurrent,
                isPast: isPast,
              );
            }).toList(),
          ),
          const SizedBox(height: MiToosaTheme.spacingMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              key: const ValueKey('daily_reward_claim'),
              onPressed: onClaim,
              child: const Text('Claim Reward'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  final DailyReward reward;
  final bool isCurrent;
  final bool isPast;

  const _DayTile({
    super.key,
    required this.reward,
    required this.isCurrent,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCurrent
        ? theme.colorScheme.primary
        : isPast
            ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
            : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrent ? theme.colorScheme.primary : Colors.grey.shade300,
          width: isCurrent ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isCurrent
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
      ),
      child: Column(
        children: [
          Text('Day ${reward.day}',
              style: theme.textTheme.labelMedium?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text('🪙 ${reward.coins}',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          if (reward.isBonusDay) ...[
            const SizedBox(height: 2),
            Text('BONUS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                )),
          ],
          if (isPast)
            const Icon(Icons.check, size: 16, color: Colors.green),
        ],
      ),
    );
  }
}
