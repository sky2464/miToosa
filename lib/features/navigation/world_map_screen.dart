import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/content_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_text.dart';
import '../../widgets/progress_ring.dart';
import 'track_detail_screen.dart';

// ─── Tracks screen — Kinetic Obsidian "Daily Training" dashboard ──────────────

class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final tracks = ContentProvider().tracks;

    return progressAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: KineticObsidian.electricCyan)),
      error: (e, _) => Center(
          child: Text('Error loading progress',
              style: Theme.of(context).textTheme.bodyMedium)),
      data: (progress) => _TracksBody(progress: progress, tracks: tracks),
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
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceMd,
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceLg + 80,
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
      borderRadius: KineticObsidian.radiusXl,
      padding: const EdgeInsets.all(KineticObsidian.spaceMd),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Proton glow bloom top-right
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    KineticObsidian.electricCyan.withValues(alpha: 0.25),
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
                style: GoogleFonts.orbitron(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  height: 1.05,
                  letterSpacing: 2.0,
                  color: KineticObsidian.primarySoft,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Complete your tasks to maintain your streak and earn bonus credits.',
                style: Theme.of(context).textTheme.bodyMedium,
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
                        style: GoogleFonts.orbitron(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.12,
                          color: KineticObsidian.primarySoft,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'GOAL',
                        style: GoogleFonts.exo2(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.8,
                          color: KineticObsidian.onSurfaceVariant,
                        ),
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
    final emoji = track.icon;
    final levelCount = track.targetLevelCount;

    return GlassCard(
      borderRadius: KineticObsidian.radiusXl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon tile
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: KineticObsidian.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KineticObsidian.radiusLg),
              border: Border.all(color: KineticObsidian.outlineVariant, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x80000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 14),
          Text(name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                height: 1,
                color: const Color(0x0DFFFFFF),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0x0DFFFFFF)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL $levelCount',
                style: GoogleFonts.exo2(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.72,
                  color: KineticObsidian.electricCyan,
                ),
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
      borderRadius: KineticObsidian.radiusXl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_outlined,
                  size: 22, color: KineticObsidian.electricCyan),
              const SizedBox(width: 8),
              Text('Stats', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 18),
          _LabeledBar(
            label: 'Accuracy',
            value: '${accuracy.toStringAsFixed(0)}%',
            percent: accuracy,
            valueColor: KineticObsidian.electricCyan,
          ),
          const SizedBox(height: 16),
          _LabeledBar(
            label: 'Reaction Time',
            value: '0.8s',
            percent: 75,
            valueColor: KineticObsidian.secondaryFixedDim,
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
              style: GoogleFonts.exo2(
                fontSize: 12, fontWeight: FontWeight.w400,
                letterSpacing: 0.48,
                color: KineticObsidian.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.exo2(
                fontSize: 12, fontWeight: FontWeight.w400,
                letterSpacing: 0.48,
                color: valueColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        KineticProgressBar(percent: percent, height: 3),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: KineticObsidian.kineticGradient,
          borderRadius: BorderRadius.circular(KineticObsidian.radiusFull),
          boxShadow: KineticObsidian.shadowNeonSoft,
        ),
        child: Text(
          label,
          style: GoogleFonts.exo2(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.84,
            color: const Color(0xFF00363A),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x0DFFFFFF),
          border: Border.all(color: const Color(0x1AFFFFFF), width: 1),
          borderRadius: BorderRadius.circular(KineticObsidian.radius),
        ),
        child: Text(
          'Play',
          style: GoogleFonts.exo2(
            fontSize: 12, fontWeight: FontWeight.w500,
            letterSpacing: 0.48,
            color: KineticObsidian.onSurface,
          ),
        ),
      ),
    );
  }
}
