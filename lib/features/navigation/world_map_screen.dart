import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/content_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/streak/streak_calendar_screen.dart';
import '../../widgets/hearts_bar.dart';
import 'track_detail_screen.dart';
import '../../theme/design_system.dart';

class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  static const _appShareUrl =
      'https://apps.apple.com/app/mitoosa/id0000000000'; // replace with real ID

  Future<void> _refuelWithDiamond(WidgetRef ref, BuildContext context) async {
    final playerId = ref.playerId;
    if (playerId == null) return;
    final ok =
        await ref.read(persistenceProvider).refuelHeartsWithDiamond(playerId);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough 💎 diamonds')),
      );
    }
    ref.invalidate(playerProgressProvider);
  }

  Future<void> _shareForBonus(WidgetRef ref, BuildContext context) async {
    final playerId = ref.playerId;
    if (playerId == null) return;
    final result = await SharePlus.instance.share(
      ShareParams(
        text: 'Play miToosa with me! $_appShareUrl',
        title: 'Check out miToosa',
      ),
    );
    if (result.status != ShareResultStatus.success) return;
    final now = DateTime.now();
    // Grant the share bonus (40 extra games)
    final granted = await ref
        .read(persistenceProvider)
        .grantShareBonus(playerId, now);
    // Also keep the legacy heart refuel for backwards compat
    await ref.read(persistenceProvider).shareAndRefuel(playerId, now);
    ref.invalidate(playerProgressProvider);
    if (context.mounted) {
      final msg = granted
          ? '+40 bonus games unlocked! 🎉'
          : 'Already shared today – come back tomorrow for more bonus games!';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ContentProvider().tracks;
    final progressAsync = ref.watch(playerProgressProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.06),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MiToosaTheme.spacingLg, MiToosaTheme.spacingMd,
                  MiToosaTheme.spacingLg, 0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'mi',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                        Text(
                          'Toosa',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const Spacer(),
                        // XP Badge + HeartsBar
                        Flexible(
                          child: progressAsync.when(
                            data: (progress) => SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  HeartsBar(
                                    hearts: progress.hearts,
                                    diamonds: progress.diamonds,
                                    freeGamesRemaining: progress.totalGamesAvailable,
                                    onRefuelWithDiamond: () =>
                                        _refuelWithDiamond(ref, context),
                                    onShareForHeart: () =>
                                        _shareForBonus(ref, context),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.primary
                                              .withValues(alpha: 0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          MiToosaTheme.radiusMd),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.bolt,
                                            size: 18, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${progress.totalXP} XP',
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: MiToosaTheme.spacingMd),
                    // Streak Card
                    progressAsync.when(
                      data: (progress) => _StreakCard(progress: progress),
                      loading: () => const SizedBox(height: 80),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MiToosaTheme.spacingMd),
              // ─── Track Grid (grouped by category) ─────────────
              Expanded(
                child: progressAsync.when(
                  data: (progress) {
                    // Group tracks by category
                    final Map<String, List<TrackDefinition>> grouped = {};
                    for (final track in tracks) {
                      grouped.putIfAbsent(track.category, () => []).add(track);
                    }
                    final categories = grouped.keys.toList()..sort();

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MiToosaTheme.spacingMd,
                        vertical: MiToosaTheme.spacingMd,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, catIndex) {
                        final category = categories[catIndex];
                        final categoryTracks = grouped[category]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category header
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: MiToosaTheme.spacingSm,
                                top: catIndex == 0 ? 0 : MiToosaTheme.spacingLg,
                              ),
                              child: Text(
                                category,
                                style: Theme.of(context)
                                    .textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                            ),
                            // 2-column grid of tracks
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: MiToosaTheme.spacingMd,
                                crossAxisSpacing: MiToosaTheme.spacingMd,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: categoryTracks.length,
                              itemBuilder: (context, trackIndex) {
                                final track = categoryTracks[trackIndex];
                                return _TrackCard(
                                  track: track,
                                  progress: progress,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const Center(child: Text('Failed to load.')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Streak Card ─────────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  final PlayerProgress progress;

  const _StreakCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
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
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withValues(alpha: 0.15),
            theme.colorScheme.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(MiToosaTheme.radiusLg),
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: MiToosaTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${progress.streakCount} Day Streak',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  'Best: ${progress.bestStreak} days · Keep it going!',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
      ),
    );
  }
}

// ─── Track Card ──────────────────────────────────────────────

class _TrackCard extends ConsumerWidget {
  final TrackDefinition track;
  final PlayerProgress progress;

  const _TrackCard({
    required this.track,
    required this.progress,
  });

  int _completedLevels() => List.generate(
    track.targetLevelCount, (i) => '${track.id}_$i',
  ).where(progress.levelStars.containsKey).length;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final completed = _completedLevels();
    final total = track.targetLevelCount;
    final progressVal = total > 0 ? completed / total : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TrackDetailScreen(track: track),
          ),
        );
      },
      child: Card(
        elevation: 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background accent
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Text(
                      track.icon,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: MiToosaTheme.spacingSm),
                    // Track name
                    Text(
                      track.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Mini progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 3,
                        backgroundColor: theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: MiToosaTheme.spacingSm),
                    // Completion text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completed / $total',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${(progressVal * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
