import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/player_progress.dart';
import '../../features/progression/free_games_controller.dart';
import '../../theme/design_system.dart';
import '../../theme/design_tokens.dart';

/// Shown when the player has no free games left — offers a daily share bonus.
Future<void> showFreeGamesDepletedSheet(
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('No free games left', style: theme.headlineMd()),
                const SizedBox(height: 8),
                Text(
                  claimedToday
                      ? 'You already claimed today\'s +40 share bonus. Your 25 free games return at midnight.'
                      : 'Share miToosa once today to unlock 40 bonus games — no paywall, no ads.',
                  style: theme.bodyMd(color: theme.fgMuted),
                ),
                const SizedBox(height: 20),
                if (!claimedToday)
                  FilledButton.icon(
                    key: const Key('free-games-share-cta'),
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
                      } else if (result == ShareGrantResult.alreadyClaimed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Daily share bonus already claimed today.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share for +40 games'),
                  )
                else
                  Text(
                    'Come back tomorrow for 25 more free games.',
                    style: theme.label(color: theme.fgMuted),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
