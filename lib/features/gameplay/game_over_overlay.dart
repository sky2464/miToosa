import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import 'session_stat.dart';

class GameOverOverlay extends StatelessWidget {
  final int puzzlesCompleted;
  final int sessionTotalPuzzles;
  final int sessionXP;
  final VoidCallback onRetry;
  final VoidCallback onBackToTrack;

  const GameOverOverlay({
    super.key,
    required this.puzzlesCompleted,
    required this.sessionTotalPuzzles,
    required this.sessionXP,
    required this.onRetry,
    required this.onBackToTrack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MiToosaTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💔', style: TextStyle(fontSize: 56)),
                const SizedBox(height: MiToosaTheme.spacingLg),
                Text(
                  'Game Over',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: MiToosaTheme.error,
                  ),
                ),
                const SizedBox(height: MiToosaTheme.spacingXl),
                Container(
                  padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(MiToosaTheme.radiusXl),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    ),
                    boxShadow: MiToosaTheme.shadowCard,
                  ),
                  child: Column(
                    children: [
                      SessionStat(
                        label: 'Puzzles solved',
                        value: '$puzzlesCompleted / $sessionTotalPuzzles',
                      ),
                      const SizedBox(height: MiToosaTheme.spacingMd),
                      SessionStat(
                        label: 'XP earned',
                        value: '$sessionXP XP',
                        valueColor: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MiToosaTheme.spacingXl),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(200, 52),
                  ),
                ),
                const SizedBox(height: MiToosaTheme.spacingMd),
                OutlinedButton.icon(
                  onPressed: onBackToTrack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Track'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(200, 52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
