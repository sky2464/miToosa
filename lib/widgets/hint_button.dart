import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// A 💡 button that reveals the level hint at the cost of 1 heart.
///
/// - Disabled when [hint] is null or [hintUsed] is true.
/// - Shows a red heart badge while [hearts] > 0.
/// - On tap when [hearts] == 0: triggers [onNoHearts] (e.g. show snackbar).
/// - On tap when available: calls [onUseHint].
class HintButton extends StatelessWidget {
  final String? hint;
  final int hearts;
  final bool hintUsed;
  final VoidCallback? onUseHint;
  final VoidCallback? onNoHearts;

  const HintButton({
    super.key,
    required this.hint,
    required this.hearts,
    required this.hintUsed,
    this.onUseHint,
    this.onNoHearts,
  });

  bool get _disabled => hint == null || hintUsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main button
        IconButton(
          key: const ValueKey('hint_button'),
          icon: Icon(
            Icons.lightbulb_rounded,
            color: _disabled
                ? theme.colorScheme.primary.withValues(alpha: 0.25)
                : MiToosaTheme.warning,
          ),
          tooltip: _disabled
              ? (hintUsed ? 'Hint already used' : 'No hint available')
              : 'Use hint (costs ❤)',
          onPressed: _disabled
              ? null
              : () {
                  if (hearts <= 0) {
                    onNoHearts?.call();
                  } else {
                    onUseHint?.call();
                  }
                },
        ),
        // Heart-cost badge (only when active and not yet used)
        if (!_disabled && hearts > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              key: const ValueKey('hint_heart_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: MiToosaTheme.error,
                borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_rounded,
                      size: 9, color: Colors.white),
                  const SizedBox(width: 1),
                  Text(
                    '-1',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // "Used" indicator
        if (hintUsed && hint != null)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              key: const ValueKey('hint_used_badge'),
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: MiToosaTheme.success,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
