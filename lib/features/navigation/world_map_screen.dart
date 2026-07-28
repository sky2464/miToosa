import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/featured_track.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_progress_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/stat_pill.dart';
import '../../widgets/track_tile.dart';
import 'track_detail_screen.dart';

// ─── Tracks screen — Aetheric Pulse "Daily Training" dashboard ────────────────

class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final tracks = ContentProvider().tracks;

    return progressAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AethericPulseDark.brandBlue),
      ),
      error: (e, _) => Center(
        child: Text(
          'Error loading progress',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (progress) => _TracksBody(progress: progress, tracks: tracks),
    );
  }
}

class _TracksBody extends StatefulWidget {
  final PlayerProgress progress;
  final List<TrackDefinition> tracks;

  const _TracksBody({required this.progress, required this.tracks});

  @override
  State<_TracksBody> createState() => _TracksBodyState();
}

class _TracksBodyState extends State<_TracksBody> {
  String _filter = 'all';

  List<TrackDefinition> get _filtered {
    if (_filter == 'all') return widget.tracks;
    return widget.tracks
        .where((t) => t.category.toLowerCase() == _filter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final gamesPlayed = (25 - progress.freeGamesRemaining).clamp(0, 25);
    final gamesInSession = gamesPlayed.clamp(0, 5);

    final filtered = _filtered;
    final featured = filtered.isNotEmpty ? filtered.first : null;
    final rest = filtered.length > 1
        ? filtered.sublist(1)
        : <TrackDefinition>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceMd,
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceXl + 80,
      ),
      children: [
        // AC-001: Daily Spark hero
        _DailySparkHero(
          gamesComplete: gamesInSession,
          onStart: featured != null
              ? () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrackDetailScreen(track: featured),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 14),
        // Aetheric Pulse stat strip — real player metrics from PlayerProgress.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Semantics(
                label:
                    'Daily streak: ${progress.streakCount} ${progress.streakCount == 1 ? 'day' : 'days'}. Earn a milestone reward every 3, 7, 14, 30, 60, 90, 180, and 365 days.',
                child: StatPill(
                  icon: const Icon(Icons.local_fire_department),
                  label: '${progress.streakCount} day streak',
                  tint: StatPillTint.orange,
                ),
              ),
              const SizedBox(width: 8),
              // BL-08 / BL-29 — plain-English free-games allowance on the stat strip.
              Semantics(
                label:
                    '${progress.freeGamesRemaining} of 25 free games remaining today. Resets at midnight. Share miToosa for +40 bonus games.',
                child: StatPill(
                  icon: const Icon(Icons.sports_esports_outlined),
                  label: '${progress.freeGamesRemaining}/25 free games',
                  tint: StatPillTint.amber,
                  glow: true,
                ),
              ),
              const SizedBox(width: 8),
              StatPill(
                icon: const Icon(Icons.star),
                label:
                    '${progress.levelStars.values.fold<int>(0, (a, b) => a + b)} stars',
                tint: StatPillTint.purple,
              ),
              const SizedBox(width: 8),
              StatPill(
                icon: const Icon(Icons.bolt_outlined),
                label: '${progress.totalXP} XP',
                tint: StatPillTint.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // AC-002: Filter chips
        _FilterChips(
          selected: _filter,
          onSelected: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 16),
        // AC-003: Featured track
        if (featured != null) ...[
          FeaturedTrack(
            track: featured,
            progress: progress,
            onPlay: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TrackDetailScreen(track: featured),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        // AC-003: 2-col TrackTile grid
        if (rest.isNotEmpty)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: rest
                .map(
                  (t) => TrackTile(
                    track: t,
                    progress: progress,
                    onPlay: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TrackDetailScreen(track: t),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 16),
        _StatsCard(progress: progress),
      ],
    );
  }
}

// ─── Daily Spark Hero (AC-001) ────────────────────────────────────────────────

class _DailySparkHero extends StatelessWidget {
  final int gamesComplete; // 0–5
  final VoidCallback? onStart;

  const _DailySparkHero({required this.gamesComplete, this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = APTheme.of(context);
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final remaining = tomorrow.difference(now);
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;

    const skillLabels = ['Pattern', 'Logic', 'Memory', 'Speed', 'Spatial'];

    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(AethericPulseDark.spaceLg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Brand-blue glow bloom top-right
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.brandBlue.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Eyebrow timer
              Text(
                'Daily spark · resets in ${h}h ${m}m',
                style: theme.label(color: theme.brandBlue),
              ),
              const SizedBox(height: 8),
              Text("Today's session", style: theme.headlineLg()),
              const SizedBox(height: 20),
              // ProgressRing N/5 + skill dot sequence
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressRing(
                    percent: (gamesComplete / 5 * 100).clamp(0, 100).toDouble(),
                    size: 96,
                    strokeWidth: 7,
                    centerChild: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$gamesComplete/5',
                          style: theme.headlineMd(),
                        ),
                        Text('games', style: theme.label()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 5-dot sequence row
                        Row(
                          children: List.generate(5, (i) {
                            final done = i < gamesComplete;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: done
                                      ? theme.brandBlue
                                      : theme.dotPendingFill,
                                  border: Border.all(
                                    color: done
                                        ? theme.brandBlue
                                        : theme.dotPendingBorder,
                                    width: 1,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        // Skill labels
                        ...List.generate(5, (i) {
                          final done = i < gamesComplete;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              skillLabels[i],
                              style: theme.label(
                                color: done ? theme.fg : theme.fgMuted,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // PrimaryButton CTA
              PrimaryButton(
                fullWidth: true,
                glow: false,
                onPressed: onStart,
                child: const Text('Start session'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Filter chips (AC-002) ────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  static List<String> get _labels => ['all', ...TrackCategory.allowlist];

  @override
  Widget build(BuildContext context) {
    final theme = APTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _labels.map((label) {
          final active = selected == label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: active
                      ? theme.brandBlue.withValues(alpha: 0.25)
                      : theme.chipInactiveFill,
                  borderRadius: BorderRadius.circular(
                    AethericPulseDark.radiusPill,
                  ),
                  border: Border.all(
                    color: active
                        ? theme.brandBlue.withValues(alpha: 0.70)
                        : theme.chipInactiveBorder,
                    width: 1,
                  ),
                  boxShadow: active && theme.isDark
                      ? AethericPulseDark.blueGlow
                      : null,
                ),
                child: Text(
                  label[0].toUpperCase() + label.substring(1),
                  style: theme.label(
                    color: active ? theme.brandBlue : theme.fgMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Stats card ────────────────────────────────────────────────────────────────

// ─── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final PlayerProgress progress;

  const _StatsCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final history = progress.adaptiveHistory;
    final accuracy = history.isNotEmpty
        ? ((history.where((r) => r >= 4).length / history.length) * 100)
              .clamp(0, 100)
              .toDouble()
        : 92.0;

    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.monitor_heart_outlined,
                size: 22,
                color: AethericPulseDark.brandBlue,
              ),
              const SizedBox(width: 8),
              Text('Stats', style: AethericPulseDark.headlineMd()),
            ],
          ),
          const SizedBox(height: 18),
          _LabeledBar(
            label: 'Accuracy',
            value: '${accuracy.toStringAsFixed(0)}%',
            percent: accuracy,
            valueColor: AethericPulseDark.brandBlue,
          ),
          const SizedBox(height: 16),
          const _LabeledBar(
            label: 'Reaction Time',
            value: '0.8s',
            percent: 75,
            valueColor: AethericPulseDark.brandPurple,
          ),
        ],
      ),
    );
  }
}

class _LabeledBar extends StatelessWidget {
  final String label;
  final String value;
  final double percent;
  final Color valueColor;

  const _LabeledBar({
    required this.label,
    required this.value,
    required this.percent,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AethericPulseDark.label()),
            Text(value, style: AethericPulseDark.label(color: valueColor)),
          ],
        ),
        const SizedBox(height: 6),
        KineticProgressBar(value: percent / 100, height: 3.0),
      ],
    );
  }
}
