import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Circular countdown ring.
///
/// S2-03 AC-011: when [remainingSeconds] ≤ 4, ring + text switch to the
/// Aetheric Pulse pink tint (`AP.pink` / #EC4899) with a pulsing glow that
/// fades in and out twice per second to telegraph urgency.
class CountdownTimerWidget extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double size;

  const CountdownTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.size = 48,
  });

  /// AC-011 threshold — at or below this many seconds, the urgent (pink) state
  /// is active.
  static const int urgentThresholdSeconds = 4;

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get _isUrgent =>
      widget.remainingSeconds <= CountdownTimerWidget.urgentThresholdSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalSeconds > 0
        ? widget.remainingSeconds / widget.totalSeconds
        : 0.0;
    final ringColor = _isUrgent
        ? AP.pink
        : Theme.of(context).colorScheme.primary;
    final textColor = _isUrgent
        ? AP.pink
        : Theme.of(context).colorScheme.onSurface;

    final core = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 3.5,
              color: ringColor.withValues(alpha: 0.15),
              strokeCap: StrokeCap.round,
            ),
          ),
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 3.5,
              color: ringColor,
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${widget.remainingSeconds}',
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              fontSize: widget.size * 0.35,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    if (!_isUrgent) return core;

    // Urgent: wrap in an AnimatedBuilder that pulses an outer pink glow.
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        final t = _pulse.value;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AP.pink.withValues(alpha: 0.25 + 0.35 * t),
                blurRadius: 8 + 8 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: core,
    );
  }
}
