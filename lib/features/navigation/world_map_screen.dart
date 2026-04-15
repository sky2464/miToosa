import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/content_provider.dart';
import '../../data/hive_persistence_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../features/auth/auth_provider.dart';
import '../../widgets/hearts_bar.dart';
import '../../widgets/how_to_play_modal.dart';
import '../gameplay/gameplay_screen.dart';
import '../../theme/design_system.dart';

class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  static const _appShareUrl =
      'https://apps.apple.com/app/mitoosa/id0000000000'; // replace with real ID

  Future<void> _refuelWithDiamond(WidgetRef ref, BuildContext context) async {
    final playerId = ref.read(authProvider).maybeWhen(
      data: (v) => v,
      orElse: () => null,
    );
    if (playerId == null) return;
    final ok =
        await HivePersistenceProvider().refuelHeartsWithDiamond(playerId);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough 💎 diamonds')),
      );
    }
    ref.invalidate(playerProgressProvider);
  }

  Future<void> _shareForHeart(WidgetRef ref, BuildContext context) async {
    final playerId = ref.read(authProvider).maybeWhen(
      data: (v) => v,
      orElse: () => null,
    );
    if (playerId == null) return;
    await Share.share(
      'Play miToosa with me! $_appShareUrl',
      subject: 'Check out miToosa',
    );
    final granted = await HivePersistenceProvider()
        .shareAndRefuel(playerId, DateTime.now());
    ref.invalidate(playerProgressProvider);
    if (!granted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already shared today – come back tomorrow for another ❤')),
      );
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
                        progressAsync.when(
                          data: (progress) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              HeartsBar(
                                hearts: progress.hearts,
                                diamonds: progress.diamonds,
                                onRefuelWithDiamond: () =>
                                    _refuelWithDiamond(ref, context),
                                onShareForHeart: () =>
                                    _shareForHeart(ref, context),
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
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: MiToosaTheme.spacingMd),
                    // Streak Card
                    progressAsync.when(
                      data: (progress) => _StreakCard(progress: progress),
                      loading: () => const SizedBox(height: 80),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: MiToosaTheme.spacingMd),
              // ─── Track List ───────────────────────────────
              Expanded(
                child: progressAsync.when(
                  data: (progress) => ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MiToosaTheme.spacingMd,
                    ),
                    itemCount: tracks.length,
                    itemBuilder: (context, trackIndex) {
                      final track = tracks[trackIndex];
                      return _TrackCard(
                        track: track,
                        progress: progress,
                        trackIndex: trackIndex,
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Failed to load.')),
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
    return Container(
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
    );
  }
}

// ─── Track Card ──────────────────────────────────────────────

class _TrackCard extends ConsumerWidget {
  final TrackDefinition track;
  final PlayerProgress progress;
  final int trackIndex;

  const _TrackCard({
    required this.track,
    required this.progress,
    required this.trackIndex,
  });

  int _completedLevels() {
    int count = 0;
    for (int i = 0; i < track.targetLevelCount; i++) {
      final key = '${track.id}_$i';
      if (progress.levelStars.containsKey(key)) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final completed = _completedLevels();
    final total = track.targetLevelCount;
    final progressVal = total > 0 ? completed / total : 0.0;

    // Track colors - rotate through palette
    final trackColors = [
      const Color(0xFF7B2CBF),
      const Color(0xFF3A86FF),
      const Color(0xFF00B4D8),
      const Color(0xFFFF8800),
      const Color(0xFFFF006E),
      const Color(0xFF06D6A0),
      const Color(0xFFEF233C),
      const Color(0xFFFFBE0B),
      const Color(0xFF9D4EDD),
      const Color(0xFF00F5D4),
    ];
    final trackColor = trackColors[trackIndex % trackColors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: MiToosaTheme.spacingMd),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: MiToosaTheme.spacingMd,
            vertical: MiToosaTheme.spacingSm,
          ),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [trackColor, trackColor.withValues(alpha: 0.6)],
              ),
              borderRadius: BorderRadius.circular(MiToosaTheme.radiusSm),
            ),
            child: Center(
              child: Text(track.icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          title: Text(
            track.name,
            style: theme.textTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(track.subtitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressVal,
                        minHeight: 4,
                        backgroundColor: trackColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation(trackColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$completed/$total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: trackColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(
                MiToosaTheme.spacingMd, 0,
                MiToosaTheme.spacingMd, MiToosaTheme.spacingMd,
              ),
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: track.targetLevelCount,
                itemBuilder: (context, levelIndex) {
                  final levelKey = '${track.id}_$levelIndex';
                  final stars = progress.levelStars[levelKey] ?? 0;
                  final isCompleted = stars > 0;
                  final isCurrent = levelIndex == completed;

                  return GestureDetector(
                    onTap: () async {
                      // Show tutorial modal on first entry to this world.
                      if (!progress.seenTutorialWorlds.contains(track.id)) {
                        if (!context.mounted) return;
                        final authState = ref.read(authProvider);
                        final playerId = authState.maybeWhen(
                          data: (v) => v,
                          orElse: () => 'local',
                        );
                        await HowToPlayModal.show(
                          context,
                          track: track,
                          onStart: () {
                            Navigator.of(context).pop();
                          },
                        );
                        await HivePersistenceProvider()
                            .markTutorialSeen(playerId, track.id);
                        ref.invalidate(playerProgressProvider);
                      }
                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameplayScreen(
                            track: track,
                            levelIndex: levelIndex,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: MiToosaTheme.spacingSm),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? trackColor.withValues(alpha: 0.08)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
                        border: Border.all(
                          color: isCurrent
                              ? trackColor
                              : isCompleted
                                  ? trackColor.withValues(alpha: 0.3)
                                  : theme.colorScheme.primary.withValues(alpha: 0.08),
                          width: isCurrent ? 2.5 : 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isCompleted)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                return Icon(
                                  i < stars
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 14,
                                  color: i < stars
                                      ? MiToosaTheme.warning
                                      : theme.colorScheme.primary.withValues(alpha: 0.15),
                                );
                              }),
                            )
                          else
                            Icon(
                              isCurrent ? Icons.play_circle_fill_rounded : Icons.lock_outline_rounded,
                              size: 24,
                              color: isCurrent
                                  ? trackColor
                                  : theme.colorScheme.primary.withValues(alpha: 0.2),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            '${levelIndex + 1}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isCurrent || isCompleted
                                  ? trackColor
                                  : theme.colorScheme.primary.withValues(alpha: 0.3),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
