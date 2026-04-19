import 'package:flutter/material.dart';
import '../theme/design_system.dart';

/// Circular countdown ring that turns red when ≤5 seconds remain.
class CountdownTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double size;

  const CountdownTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final isUrgent = remainingSeconds <= 5;
    final ringColor = isUrgent
        ? MiToosaTheme.error
        : Theme.of(context).colorScheme.primary;
    final textColor = isUrgent
        ? MiToosaTheme.error
        : Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3.5,
              color: ringColor.withValues(alpha: 0.15),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Progress ring
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3.5,
              color: ringColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          // Time text
          Text(
            '$remainingSeconds',
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: size * 0.35,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
