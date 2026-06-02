import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// An animated progress bar rendered at the top of the screen during a run.
///
/// Colour transitions smoothly from [MiToosaTheme.success] → yellow → [MiToosaTheme.error]
/// as [timeRemaining] approaches zero. A time label appears when ≤ 30 s remain.
/// When [totalTime] is [Duration.zero] the widget is hidden.
///
/// Optional [label] shows a session counter (e.g. "Puzzle 3 / 20") at the
/// left side of the label row.
class RunTimerOverlay extends StatelessWidget {
  final Duration timeRemaining;
  final Duration totalTime;

  /// Optional label shown at the left of the time-label row when non-null.
  final String? label;

  const RunTimerOverlay({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (totalTime == Duration.zero) return const SizedBox.shrink();
    final fraction = (timeRemaining.inMilliseconds / totalTime.inMilliseconds)
        .clamp(0.0, 1.0);

    // Smooth colour: green → amber → red
    final Color barColor;
    if (fraction > 0.5) {
      barColor = Color.lerp(
        MiToosaTheme.warning,
        MiToosaTheme.success,
        (fraction - 0.5) * 2,
      )!;
    } else if (fraction > 0.25) {
      barColor = Color.lerp(
        const Color(0xFFFF6B35),
        MiToosaTheme.warning,
        (fraction - 0.25) * 4,
      )!;
    } else {
      barColor = Color.lerp(
        MiToosaTheme.error,
        const Color(0xFFFF6B35),
        fraction * 4,
      )!;
    }

    final secs = timeRemaining.inSeconds;
    final showLabel = label != null || secs <= 30;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Progress bar ──────────────────────────────────────────
        SizedBox(
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
            child: Stack(
              children: [
                // Subtle tinted track
                Container(
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                  ),
                ),
                // Filled progress with gradient overlay
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 200),
                  widthFactor: fraction,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [barColor.withValues(alpha: 0.7), barColor],
                      ),
                    ),
                  ),
                ),
                // Invisible LinearProgressIndicator kept for widget tests
                LinearProgressIndicator(
                  key: const ValueKey('run_timer_bar'),
                  value: fraction,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(barColor),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ),
        // ── Label row ─────────────────────────────────────────────
        if (showLabel)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MiToosaTheme.spacingMd,
              vertical: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: barColor.withValues(alpha: 0.85),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  secs >= 60 ? '${secs ~/ 60}m ${secs % 60}s' : '${secs}s',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
