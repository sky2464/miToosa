import 'package:flutter/material.dart';

import '../core/content_provider.dart';
import '../data/player_progress.dart';
import '../theme/design_system.dart';
import '../theme/design_tokens.dart';
import 'glass_card.dart';

/// 2-column grid tile for secondary tracks.
///
/// Displays a 3D PNG icon, track name, skill/category label, and completed
/// vs total level count. Tapping the tile triggers [onPlay].
class TrackTile extends StatelessWidget {
  final TrackDefinition track;
  final PlayerProgress progress;
  final VoidCallback? onPlay;

  const TrackTile({
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

    return GestureDetector(
      onTap: onPlay,
      child: GlassCard(
        borderRadius: AethericPulseDark.radiusCard,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3D PNG icon well
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.brandBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.brandBlue.withValues(alpha: 0.18),
                  width: 1,
                ),
              ),
              child: Center(
                child: Image.asset(
                  AP.trackIcon(track.id),
                  width: 28,
                  height: 28,
                  errorBuilder: (_, err, stack) => Icon(
                    Icons.grid_view_rounded,
                    size: 24,
                    color: theme.brandBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              track.name,
              style: theme.headlineMd(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              track.category,
              style: theme.label(color: theme.fgMuted),
            ),
            const SizedBox(height: 6),
            Text(
              '$completed / $total',
              style: theme.label(color: theme.brandBlue),
            ),
          ],
        ),
      ),
    );
  }
}
