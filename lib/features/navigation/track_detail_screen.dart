import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content_provider.dart';
import '../../core/engine/progression_engine.dart';
import '../../core/models/gameplay_level.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../gameplay/gameplay_screen.dart';
import '../../features/progression/free_games_controller.dart';
import '../../widgets/free_games_depleted_sheet.dart';

class TrackDetailScreen extends ConsumerStatefulWidget {
  final TrackDefinition track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  ConsumerState<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// True when the player has earned enough XP on [index] to unlock the next
  /// level. Returns `true` for levels completed before v6 XP tracking (null XP)
  /// so existing progress is not retroactively locked.
  bool _hasMetGate(int index, PlayerProgress progress) {
    final key = '${widget.track.id}_$index';
    if (!progress.levelStars.containsKey(key)) return false;
    final xp = progress.levelXP[key];
    return xp == null || xp >= kProgressionGateXP;
  }

  /// True when [index] is accessible to the player.
  bool _isPlayable(int index, PlayerProgress progress) {
    if (index == 0) return true;
    return _hasMetGate(index - 1, progress);
  }

  Color _difficultyColor(String? tierName) {
    switch (tierName) {
      case 'easy':
        return MiToosaTheme.success;
      case 'medium':
        return MiToosaTheme.warning;
      case 'hard':
        return const Color(0xFFFF6B35); // deep orange
      case 'challenge':
        return MiToosaTheme.error;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(playerProgressProvider);
    final theme = Theme.of(context);
    final track = widget.track;

    return Scaffold(
      appBar: AppBar(
        title: Text(track.name),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: progressAsync.when(
        data: (progress) {
          // Count completed levels for this track
          final levelPrefix = '${track.id}_';
          int completed = 0;
          for (final entry in progress.levelStars.entries) {
            if (entry.key.startsWith(levelPrefix)) {
              completed++;
            }
          }

          // Find first playable but incomplete level
          int firstIncomplete = track.targetLevelCount - 1;
          for (int i = 0; i < track.targetLevelCount; i++) {
            if (!_isPlayable(i, progress) ||
                !progress.levelStars.containsKey('${track.id}_$i')) {
              firstIncomplete = i;
              break;
            }
          }

          return CustomScrollView(
            slivers: [
              // Header with track icon, name, subtitle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(track.icon, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: MiToosaTheme.spacingMd),
                      Text(
                        track.name,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: MiToosaTheme.spacingSm),
                      Text(
                        track.subtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: MiToosaTheme.spacingMd),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          MiToosaTheme.radiusSm,
                        ),
                        child: LinearProgressIndicator(
                          value: completed / track.targetLevelCount,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surface,
                          valueColor: AlwaysStoppedAnimation(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: MiToosaTheme.spacingSm),
                      Text(
                        '$completed / ${track.targetLevelCount} levels',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              // Level grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MiToosaTheme.spacingLg,
                  vertical: MiToosaTheme.spacingMd,
                ),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: MiToosaTheme.spacingSm,
                    crossAxisSpacing: MiToosaTheme.spacingSm,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final levelKey = '${track.id}_$index';
                    final stars = progress.levelStars[levelKey] ?? 0;
                    final isComplete = progress.levelStars.containsKey(
                      levelKey,
                    );
                    final playable = _isPlayable(index, progress);
                    final isCurrent = playable && !isComplete;
                    final isLocked = !playable && !isComplete;
                    final bestDifficulty =
                        progress.levelBestDifficulty[levelKey];
                    final levelXP = progress.levelXP[levelKey] ?? 0;
                    final dotColor = _difficultyColor(bestDifficulty);

                    Widget tile = Container(
                      decoration: BoxDecoration(
                        color: isComplete
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : isCurrent
                            ? theme.colorScheme.primary.withValues(alpha: 0.05)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          MiToosaTheme.radiusMd,
                        ),
                        border: Border.all(
                          color: isCurrent
                              ? theme.colorScheme.primary
                              : isComplete
                              ? theme.colorScheme.primary.withValues(alpha: 0.3)
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                          width: isCurrent ? 2 : 1,
                        ),
                        boxShadow: (isComplete || isCurrent)
                            ? MiToosaTheme.shadowCard
                            : null,
                      ),
                      child: Stack(
                        children: [
                          // Main content: level number + stars or lock
                          Positioned.fill(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLocked)
                                  Icon(
                                    Icons.lock_rounded,
                                    size: 18,
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                  )
                                else ...[
                                  Text(
                                    '${index + 1}',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: isCurrent
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.primary
                                                .withValues(alpha: 0.85),
                                    ),
                                  ),
                                  if (isComplete)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '$stars★',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          // Difficulty dot: bottom-left (completed levels only)
                          if (isComplete && bestDifficulty != null)
                            Positioned(
                              left: 5,
                              bottom: 5,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: dotColor,
                                ),
                              ),
                            ),
                          // XP badge: bottom-right (completed levels only)
                          if (isComplete && levelXP > 0)
                            Positioned(
                              right: 3,
                              bottom: 4,
                              child: Text(
                                '${levelXP}xp',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );

                    if (isCurrent) {
                      tile = AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (context, child) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: child,
                        ),
                        child: tile,
                      );
                    }

                    final semanticLabel = isComplete
                        ? 'Level ${index + 1}, completed with $stars stars'
                        : isCurrent
                        ? 'Level ${index + 1}, current level'
                        : 'Level ${index + 1}, locked';
                    return Semantics(
                      button: isComplete || isCurrent,
                      enabled: isComplete || isCurrent,
                      label: semanticLabel,
                      child: GestureDetector(
                        onTap: isComplete || isCurrent
                            ? () => _showDifficultySheet(
                                context,
                                ref: ref,
                                track: track,
                                levelIndex: index,
                              )
                            : null,
                        child: tile,
                      ),
                    );
                  }, childCount: track.targetLevelCount),
                ),
              ),
              // CTA buttons
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton(
                            onPressed: completed < track.targetLevelCount
                                ? () => _showDifficultySheet(
                                    context,
                                    ref: ref,
                                    track: track,
                                    levelIndex: firstIncomplete,
                                  )
                                : null,
                            child: const Text('Continue'),
                          ),
                        ],
                      ),
                    ),
                  ],
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

void _showDifficultySheet(
  BuildContext context, {
  required WidgetRef ref,
  required TrackDefinition track,
  required int levelIndex,
}) {
  showModalBottomSheet<DifficultyTier>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(MiToosaTheme.radiusXl),
      ),
    ),
    builder: (_) => DifficultySelectionSheet(
      onSelect: (tier) async {
        Navigator.pop(context);
        final result = await ref
            .read(freeGamesControllerProvider)
            .consumeGameForStart(DateTime.now());
        if (!context.mounted) return;

        switch (result) {
          case GameStartResult.started:
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameplayScreen(
                  track: track,
                  levelIndex: levelIndex,
                  initialDifficulty: tier,
                  sessionStartLevelIndex: levelIndex,
                  sessionXP: 0,
                ),
              ),
            );
          case GameStartResult.noAllowance:
            final progress = await ref.read(playerProgressProvider.future);
            if (!context.mounted) return;
            await showFreeGamesDepletedSheet(
              context,
              ref: ref,
              progress: progress,
            );
          case GameStartResult.failed:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not start game. Try again.')),
            );
        }
      },
    ),
  );
}

/// Bottom sheet that lets the player choose a difficulty tier before a level.
class DifficultySelectionSheet extends StatelessWidget {
  final void Function(DifficultyTier tier) onSelect;

  const DifficultySelectionSheet({super.key, required this.onSelect});

  static const _tiers = [
    (tier: DifficultyTier.easy, emoji: '🟢', label: 'Easy', sub: '30 sec'),
    (tier: DifficultyTier.medium, emoji: '🟡', label: 'Medium', sub: '15 sec'),
    (tier: DifficultyTier.hard, emoji: '🟠', label: 'Hard', sub: '7 sec'),
    (
      tier: DifficultyTier.challenge,
      emoji: '🔴',
      label: 'Challenge',
      sub: '4 sec',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MiToosaTheme.spacingLg,
          MiToosaTheme.spacingLg,
          MiToosaTheme.spacingLg,
          MiToosaTheme.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: MiToosaTheme.spacingLg),
            Text(
              'Choose Difficulty',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'How fast can you think? ⏱️',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: MiToosaTheme.spacingLg),
            ...(_tiers.map(
              (t) => _TierTile(
                emoji: t.emoji,
                label: t.label,
                sub: t.sub,
                onTap: () => onSelect(t.tier),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TierTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String sub;
  final VoidCallback onTap;

  const _TierTile({
    required this.emoji,
    required this.label,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: MiToosaTheme.spacingSm),
      child: Semantics(
        button: true,
        label: '$label. $sub',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MiToosaTheme.spacingLg,
              vertical: MiToosaTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
              ),
              boxShadow: MiToosaTheme.shadowCard,
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: MiToosaTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        sub,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
