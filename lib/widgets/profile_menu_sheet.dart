import 'package:flutter/material.dart';

import '../core/engine/progression_engine.dart';
import '../data/player_progress.dart';
import '../theme/design_system.dart';
import '../theme/design_tokens.dart';

/// Profile menu — opened from the app header avatar / brand tap.
Future<void> showProfileMenuSheet(
  BuildContext context, {
  required PlayerProgress progress,
}) {
  final level = (progress.totalXP ~/ 1000) + 1;
  final tier = ProgressionEngine.computeMasteryTier(progress.adaptiveHistory);
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.brandBlue, width: 1.5),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/avatars/avatar_4.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            progress.playerId.toUpperCase(),
                            style: theme.headlineMd(),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Level $level · ${tier.name} mastery',
                            style: theme.label(color: theme.fgMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Your progress is stored only on this device.',
                  style: theme.bodyMd(color: theme.fgMuted),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
