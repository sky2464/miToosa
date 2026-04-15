import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// A thin animated progress bar rendered at the top of the screen during a run.
///
/// Colour shifts green → yellow → red as [timeRemaining] approaches zero.
/// When [timeRemaining] is [Duration.zero] the bar is hidden.
class RunTimerOverlay extends StatelessWidget {
  final Duration timeRemaining;
  final Duration totalTime;

  const RunTimerOverlay({
    super.key,
    required this.timeRemaining,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    if (totalTime == Duration.zero) return const SizedBox.shrink();
    final fraction =
        (timeRemaining.inMilliseconds / totalTime.inMilliseconds).clamp(0.0, 1.0);

    final Color barColor;
    if (fraction > 0.5) {
      barColor = MiToosaTheme.success;
    } else if (fraction > 0.25) {
      barColor = MiToosaTheme.warning;
    } else {
      barColor = MiToosaTheme.error;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MiToosaTheme.radiusFull),
        child: LinearProgressIndicator(
          key: const ValueKey('run_timer_bar'),
          value: fraction,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(barColor),
          minHeight: 5,
        ),
      ),
    );
  }
}
