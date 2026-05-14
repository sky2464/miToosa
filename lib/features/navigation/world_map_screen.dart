import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_background.dart';
import '../../widgets/kinetic_chip.dart';
import '../../widgets/kinetic_progress_bar.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/stat_pill.dart';
import 'track_detail_screen.dart';
import '../local_play/local_play_mode_screen.dart';

// ─── Tracks screen — Aetheric Pulse "Daily Training" dashboard ────────────────

class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final tracks = ContentProvider().tracks;

    return KineticBackground(
      child: progressAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AethericPulseDark.brandBlue)),
        error: (e, _) => Center(
            child: Text('Error loading progress',
                style: Theme.of(context).textTheme.bodyMedium)),
        data: (progress) => _TracksBody(progress: progress, tracks: tracks),
      ),
    );
  }
}

class _TracksBody extends StatelessWidget {
  final PlayerProgress progress;
  final List<TrackDefinition> tracks;

  const _TracksBody({required this.progress, required this.tracks});

  @override
  Widget build(BuildContext context) {
    final screenTracks = tracks.take(6).toList();
    final gamesPlayed = 25 - progress.freeGamesRemaining;
    final dailyGoalPct =
        (gamesPlayed / 25 * 100).clamp(0, 100).toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceMd,
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceXl + 80,
      ),
      children: [
        _DailyTrainingHero(
          dailyGoalPct: dailyGoalPct,
          onStart: screenTracks.isNotEmpty
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          TrackDetailScreen(track: screenTracks.first),
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
              StatPill(
                icon: const Icon(Icons.local_fire_department),
                label: '${progress.streakCount} day streak',
                tint: StatPillTint.orange,
              ),
              const SizedBox(width: 8),
              StatPill(
                icon: const Icon(Icons.bolt),
                label: '${progress.freeGamesRemaining}/25 energy',
                tint: StatPillTint.amber,
                glow: true,
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
        ...screenTracks.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TrackCard(
                track: t,
                onPlay: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TrackDetailScreen(track: t),
                  ),
                ),
              ),
            )),
        _StatsCard(progress: progress),
        const SizedBox(height: 12),
        _LocalPlayCard(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LocalPlayModeScreen()),
          ),
        ),
      ],
    );
  }
}

// ─── Daily Training Hero ───────────────────────────────────────────────────────

class _DailyTrainingHero extends StatelessWidget {
  final double dailyGoalPct;
  final VoidCallback? onStart;

  const _DailyTrainingHero({required this.dailyGoalPct, this.onStart});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(AethericPulseDark.spaceLg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Brand-blue glow bloom top-right
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AethericPulseDark.brandBlue.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily\nTraining',
                style: AethericPulseDark.display(),
              ),
              const SizedBox(height: 14),
              Text(
                'Complete your tasks to maintain your streak and earn bonus credits.',
                style: AethericPulseDark.bodyMd(),
              ),
              const SizedBox(height: 20),
              _KineticButton(
                label: 'Start Sequence',
                onTap: onStart,
              ),
              const SizedBox(height: 28),
              Center(
                child: ProgressRing(
                  percent: dailyGoalPct,
                  size: 170,
                  strokeWidth: 8,
                  centerChild: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${dailyGoalPct.toStringAsFixed(0)}%',
                        style: AethericPulseDark.headlineLg(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'GOAL',
                        style: AethericPulseDark.label(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Track card ────────────────────────────────────────────────────────────────

class _TrackCard extends StatelessWidget {
  final TrackDefinition track;
  final VoidCallback onPlay;

  const _TrackCard({required this.track, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    final name = track.name;
    final subtitle = track.subtitle;
    final levelCount = track.targetLevelCount;

    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PNG icon in nested well
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AethericPulseDark.brandBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/icons/${track.id}.png',
                width: 32,
                height: 32,
                errorBuilder: (context, error, _) => const Icon(
                  Icons.grid_view_rounded,
                  size: 28,
                  color: AethericPulseDark.brandBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(name, style: AethericPulseDark.headlineMd()),
          const SizedBox(height: 8),
          // Stat pills
          Row(
            children: [
              const KineticChip(
                label: 'XP',
                leading: Icon(Icons.star, size: 12, color: AethericPulseDark.brandBlue),
                color: AethericPulseDark.brandBlue,
              ),
              const SizedBox(width: 8),
              KineticChip(
                label: '$levelCount levels',
                color: AethericPulseDark.brandPurple,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: AethericPulseDark.bodyMd()),
          const SizedBox(height: 14),
          const KineticProgressBar(value: 0.0),
          const Divider(height: 24, color: Color(0x0DFFFFFF)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL $levelCount',
                style: AethericPulseDark.label(color: AethericPulseDark.brandBlue),
              ),
              _PlayButton(onTap: onPlay),
            ],
          ),
        ],
      ),
    );
  }
}

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
              const Icon(Icons.monitor_heart_outlined,
                  size: 22, color: AethericPulseDark.brandBlue),
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
            Text(
              label,
              style: AethericPulseDark.label(),
            ),
            Text(
              value,
              style: AethericPulseDark.label(color: valueColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        KineticProgressBar(value: percent / 100, height: 3.0),
      ],
    );
  }
}

// ─── Shared buttons ────────────────────────────────────────────────────────────

class _KineticButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _KineticButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AethericPulseDark.minTapTarget,
          minHeight: AethericPulseDark.minTapTarget,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AethericPulseDark.gradPrimary,
              borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
              boxShadow: AethericPulseDark.blueGlow,
            ),
            child: Text(
              label,
              style: AethericPulseDark.label(color: AethericPulseDark.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AethericPulseDark.minTapTarget,
          minHeight: AethericPulseDark.minTapTarget,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x0DFFFFFF),
              border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
              borderRadius: BorderRadius.circular(AethericPulseDark.radiusChip),
            ),
            child: Text(
              'Play',
              style: AethericPulseDark.label(color: AethericPulseDark.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Local Play Card ──────────────────────────────────────────────────────────

class _LocalPlayCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LocalPlayCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(AethericPulseDark.spaceMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AethericPulseDark.radiusCard),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AethericPulseDark.brandBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.wifi_rounded,
                size: 26,
                color: AethericPulseDark.brandBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Play Locally', style: AethericPulseDark.headlineMd()),
                  const SizedBox(height: 2),
                  Text(
                    'Challenge a friend on the same Wi-Fi',
                    style: AethericPulseDark.bodyMd(),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AethericPulseDark.onSurfaceMuted,
            ),
          ],
        ),
      ),
    );
  }
}
