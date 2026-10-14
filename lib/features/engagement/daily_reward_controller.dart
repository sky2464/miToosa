import '../../core/engine/daily_reward_engine.dart';
import '../../data/player_progress.dart';

/// Coordinates daily-reward availability and claim targeting for UI layers.
class DailyRewardController {
  DailyRewardController({
    required PlayerProgress progress,
    DateTime? clock,
  })  : _progress = progress,
        _now = clock ?? DateTime.now();

  final PlayerProgress _progress;
  final DateTime _now;

  bool get canClaim => DailyRewardEngine.canClaim(
        lastClaim: _progress.lastDailyRewardClaim,
        now: _now,
      );

  /// Day highlighted in the 7-day grid.
  int get highlightDay {
    if (canClaim) return claimTargetDay;
    final day = _progress.dailyRewardDay;
    return day <= 0 ? 1 : day;
  }

  /// Day index applied on the next successful claim.
  int get claimTargetDay {
    final day = _progress.dailyRewardDay;
    if (day <= 0) return 1;
    return DailyRewardEngine.nextDay(day);
  }

  int get coinsForClaim =>
      DailyRewardEngine.rewardForDay(claimTargetDay).coins;
}
