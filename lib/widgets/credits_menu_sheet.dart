import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_progress.dart';
import '../features/progression/free_games_controller.dart';
import '../theme/design_system.dart';
import '../theme/design_tokens.dart';

/// Free-games allowance menu — opened from the app header games pill.
Future<void> showFreeGamesMenuSheet(
  BuildContext context, {
  required WidgetRef ref,
  required PlayerProgress progress,
}) {
  final theme = APTheme.of(context);
  final now = DateTime.now();
  final claimedToday = FreeGamesController.claimedShareBonusToday(
    progress.lastShareDate,
    now,
  );

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
                Text('Free games', style: theme.headlineMd()),
                const SizedBox(height: 8),
                Text(
                  '${progress.totalGamesAvailable} games available today',
                  style: theme.display(color: theme.brandBlue),
                ),
                const SizedBox(height: 12),
                Text(
                  'You get 25 free games every day. They reset at midnight. '
                  'Share miToosa once per day for +40 bonus games.',
                  style: theme.bodyMd(color: theme.fgMuted),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  title: 'Daily allowance',
                  subtitle:
                      '${progress.freeGamesRemaining} of 25 free games remaining',
                  theme: theme,
                ),
                if (progress.shareBonusGames > 0)
                  _InfoRow(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Share bonus',
                    subtitle: '${progress.shareBonusGames} bonus games left',
                    theme: theme,
                  ),
                const Divider(height: 24),
                if (!claimedToday)
                  FilledButton.icon(
                    key: const Key('free-games-menu-share'),
                    onPressed: () async {
                      final result = await ref
                          .read(freeGamesControllerProvider)
                          .requestShareBonus(now);
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      if (result == ShareGrantResult.granted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('+40 free games added for today!'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share for +40 games'),
                  )
                else
                  Text(
                    'Daily share bonus already claimed — come back tomorrow.',
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final APTheme theme;

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
