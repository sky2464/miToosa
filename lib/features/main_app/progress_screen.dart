import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Progress'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
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
