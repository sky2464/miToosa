import 'package:flutter/material.dart';

import '../core/content_provider.dart';
import '../data/player_progress.dart';
import '../theme/design_system.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';
import 'kinetic_progress_bar.dart';
import 'primary_button.dart';

/// Full-width featured track tile — shown at the top of the Tracks grid.
///
/// Displays a 3D PNG icon well, track name + subtitle, completion progress bar,
/// and a "Play" CTA wired to [onPlay].
class FeaturedTrack extends StatelessWidget {
  final TrackDefinition track;
  final PlayerProgress progress;
  final VoidCallback? onPlay;

  const FeaturedTrack({
    super.key,
    required this.track,
    required this.progress,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = APTheme.of(context);
    final completed = progress.levelStars.entries
        .where((e) => e.key.startsWith('${track.id}_') && e.value > 0)
        .length;
    final total = track.targetLevelCount;
    final pct = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(AethericPulseDark.spaceLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(track.name, style: theme.headlineLg()),
                const SizedBox(height: 4),
                Text(
                  track.subtitle,
                  style: theme.bodyMd(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                KineticProgressBar(value: pct),
                const SizedBox(height: 6),
                Text(
                  '$completed / $total levels',
                  style: theme.label(color: theme.fgMuted),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  key: const ValueKey('featured_track_play_button'),
                  onPressed: onPlay,
                  child: const Text('Play'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: theme.brandBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.brandBlue.withValues(alpha: 0.22),
                width: 1,
              ),
              boxShadow: theme.isDark ? AethericPulseDark.blueGlow : null,
            ),
            child: Center(
              child: Image.asset(
                AP.trackIcon(track.id),
                width: 48,
                height: 48,
                errorBuilder: (_, err, stack) => Icon(
                  Icons.grid_view_rounded,
                  size: 36,
                  color: theme.brandBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
