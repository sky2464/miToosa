import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/content_provider.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../gameplay/gameplay_screen.dart';

class TrackDetailScreen extends ConsumerWidget {
  final TrackDefinition track;

  const TrackDetailScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final theme = Theme.of(context);

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

          // Find first incomplete level
          int firstIncomplete = 0;
          for (int i = 0; i < track.targetLevelCount; i++) {
            final key = '${track.id}_$i';
            if (!progress.levelStars.containsKey(key)) {
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
                      Text(
                        track.icon,
                        style: const TextStyle(fontSize: 64),
                      ),
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: MiToosaTheme.spacingMd),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(MiToosaTheme.radiusSm),
                        child: LinearProgressIndicator(
                          value: completed / track.targetLevelCount,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surface,
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final levelKey = '${track.id}_$index';
                      final stars = progress.levelStars[levelKey] ?? 0;
                      final isComplete = progress.levelStars.containsKey(levelKey);
                      final isCurrent = index == firstIncomplete && !isComplete;

                      return GestureDetector(
                        onTap: isComplete || isCurrent
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => GameplayScreen(
                                      track: track,
                                      levelIndex: index,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isComplete
                                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                                : isCurrent
                                    ? theme.colorScheme.primary.withValues(alpha: 0.05)
                                    : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
                            border: Border.all(
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : isComplete
                                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                                      : theme.colorScheme.primary.withValues(alpha: 0.1),
                              width: isCurrent ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${index + 1}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: isCurrent || isComplete
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                                ),
                              ),
                              if (isComplete)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      5,
                                      (i) => Text(
                                        i < stars ? '⭐' : '☆',
                                        style: const TextStyle(fontSize: 8),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: track.targetLevelCount,
                  ),
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
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => GameplayScreen(
                                          track: track,
                                          levelIndex: firstIncomplete,
                                        ),
                                      ),
                                    );
                                  }
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
