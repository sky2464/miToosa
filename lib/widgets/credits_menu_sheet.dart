import 'package:flutter/material.dart';

import '../data/player_progress.dart';
import '../theme/design_system.dart';
import '../theme/design_tokens.dart';

/// Credits / economy menu — opened from the app header CR pill tap.
Future<void> showCreditsMenuSheet(
  BuildContext context, {
  required PlayerProgress progress,
}) {
  final theme = APTheme.of(context);

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.paddingOf(ctx).bottom + 16,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.isDark
                ? AethericPulseDark.surfaceMid
                : AethericPulseLight.lightSurfaceContainerHigh,
            borderRadius: BorderRadius.circular(AP.radiusCard),
            border: Border.all(color: theme.glassBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Credits', style: theme.headlineMd()),
                const SizedBox(height: 8),
                Text(
                  '${progress.coins} CR',
                  style: theme.display(color: theme.brandBlue),
                ),
                const SizedBox(height: 12),
                Text(
                  'Earn credits by completing levels, hitting streak milestones, '
                  'and finishing your daily session.',
                  style: theme.bodyMd(color: theme.fgMuted),
                ),
                const SizedBox(height: 16),
                _CreditsRow(
                  icon: Icons.star_outline,
                  title: 'Level stars',
                  subtitle: 'Bonus credits on first clear and high scores',
                  theme: theme,
                ),
                _CreditsRow(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Streak milestones',
                  subtitle: 'Rewards at 3, 7, 14, 30+ day streaks',
                  theme: theme,
                ),
                const Divider(height: 24),
                _CreditsRow(
                  icon: Icons.share_outlined,
                  title: 'Share miToosa',
                  subtitle: 'Earn +40 bonus sessions per share (once per day)',
                  theme: theme,
                ),
                _CreditsRow(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Go VIP',
                  subtitle:
                      'Ad-free play, +10 bonus sessions daily, streak shield',
                  theme: theme,
                ),
                const SizedBox(height: 8),
                Text(
                  'Shop coming soon — credits will unlock boosts and cosmetics.',
                  style: theme.label(color: theme.fgMuted),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _CreditsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final APTheme theme;

  const _CreditsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.brandBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.bodyMd(color: theme.fg)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.label(color: theme.fgMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
