import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Displays the player's heart count (0–5) and diamond currency.
///
/// Shows a row of 5 heart icons (filled / outline), a 💎 badge with the
/// diamond count, an optional "Refuel with 💎" button, and an optional
/// "Share ♥" button to earn a free heart by sharing the app.
class HeartsBar extends StatelessWidget {
  final int hearts;
  final int diamonds;
  final int freeGamesRemaining;
  final VoidCallback? onRefuelWithDiamond;

  /// Called when player taps the share-for-heart button.
  /// The caller is responsible for invoking share_plus and
  /// persisting the daily refuel.
  final VoidCallback? onShareForHeart;

  const HeartsBar({
    super.key,
    required this.hearts,
    required this.diamonds,
    this.freeGamesRemaining = 25,
    this.onRefuelWithDiamond,
    this.onShareForHeart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canRefuel = hearts < 5 && diamonds >= 1;
    final canShare = hearts < 5;

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Free games badge ────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎮', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 3),
                Text(
                  '$freeGamesRemaining',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: freeGamesRemaining > 0
                        ? theme.colorScheme.secondary
                        : MiToosaTheme.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Hearts ──────────────────────────────────────────
          ...List.generate(5, (i) {
            final filled = i < hearts;
            return Icon(
              filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18,
              color: filled
                  ? MiToosaTheme.error
                  : theme.colorScheme.primary.withValues(alpha: 0.2),
            );
          }),
          const SizedBox(width: 8),
          // ── Diamond badge ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('💎', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 3),
                Text(
                  '$diamonds',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          // ── Refuel button ────────────────────────────────────
          if (canRefuel) ...[
            const SizedBox(width: 8),
            GestureDetector(
              key: const ValueKey('refuel_diamond_btn'),
              onTap: onRefuelWithDiamond,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2CBF), Color(0xFF9D4EDD)],
                  ),
                  borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+1',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // ── Share-for-heart button ────────────────────────────
          if (canShare) ...[
            const SizedBox(width: 8),
            GestureDetector(
              key: const ValueKey('share_heart_btn'),
              onTap: onShareForHeart,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.share_rounded,
                      size: 13,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '+40',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
