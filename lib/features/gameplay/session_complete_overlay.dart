import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import 'session_stat.dart';

class SessionCompleteOverlay extends StatelessWidget {
  final int puzzlesCompleted;
  final int sessionXP;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onBackToTrack;

  const SessionCompleteOverlay({
    super.key,
    required this.puzzlesCompleted,
    required this.sessionXP,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onBackToTrack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.94),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MiToosaTheme.spacingXl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 64)),
                const SizedBox(height: MiToosaTheme.spacingLg),
                Text(
                  'Session Complete!',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: MiToosaTheme.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: MiToosaTheme.spacingXl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: MiToosaTheme.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(MiToosaTheme.radiusXl),
                    border: Border.all(
                      color: MiToosaTheme.success.withValues(alpha: 0.2),
                    ),
                    boxShadow: MiToosaTheme.shadowCard,
                  ),
                  child: Column(
                    children: [
                      SessionStat(
                        label: 'Puzzles solved',
                        value: '$puzzlesCompleted',
                        valueColor: MiToosaTheme.success,
                      ),
                      const SizedBox(height: MiToosaTheme.spacingMd),
                      SessionStat(
                        label: 'Session XP',
                        value: '+$sessionXP XP',
                        valueColor: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MiToosaTheme.spacingXl),
                if (hasNextLevel)
                  FilledButton.icon(
                    onPressed: onNextLevel,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Next Level'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(200, 52),
                      backgroundColor: MiToosaTheme.success,
                    ),
                  ),
                if (hasNextLevel)
                  const SizedBox(height: MiToosaTheme.spacingMd),
                OutlinedButton.icon(
                  onPressed: onBackToTrack,
                  icon: const Icon(Icons.grid_view_rounded),
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
