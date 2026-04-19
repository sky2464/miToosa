/// Pure-Dart streak engine — no Flutter imports.
///
/// Handles streak continuity (with freeze), milestone checks, and rewards.
library;

enum StreakResult { continued, frozen, broken }

class StreakEngine {
  StreakEngine._(); // static-only

  /// The 8 milestone thresholds.
  static const milestones = [3, 7, 14, 30, 60, 90, 180, 365];

  static const _milestoneRewards = <int, int>{
    3: 25,
    7: 50,
    14: 100,
    30: 200,
    60: 400,
    90: 600,
    180: 1000,
    365: 2000,
  };

  /// Determines whether a streak is continued, frozen (1-day gap covered by
  /// a freeze item), or broken.
  ///
  /// Returns [StreakResult.continued] when:
  /// - [lastLoginDate] is null (first login ever)
  /// - Login is the same calendar day
  /// - Login is the next consecutive calendar day
  ///
  /// Returns [StreakResult.frozen] when:
  /// - Gap is exactly 1 missed day AND [streakFreezeCount] > 0
  ///
  /// Returns [StreakResult.broken] otherwise.
  static StreakResult checkStreak({
    required DateTime? lastLoginDate,
    required DateTime now,
    required int streakFreezeCount,
  }) {
    if (lastLoginDate == null) return StreakResult.continued;

    final lastDay = DateTime(
        lastLoginDate.year, lastLoginDate.month, lastLoginDate.day);
    final today = DateTime(now.year, now.month, now.day);
    final gap = today.difference(lastDay).inDays;

    if (gap <= 1) return StreakResult.continued; // same day or next day
    if (gap == 2 && streakFreezeCount > 0) return StreakResult.frozen;
    return StreakResult.broken;
  }

  /// Returns newly achieved milestones for [currentStreak] that are not yet
  /// in [alreadyAchieved].
  static List<int> checkMilestones({
    required int currentStreak,
    required List<int> alreadyAchieved,
  }) {
    final achieved = Set<int>.from(alreadyAchieved);
    return milestones
        .where((m) => currentStreak >= m && !achieved.contains(m))
        .toList();
  }

  /// Coin reward for reaching a [milestone]. Returns 0 for unknown milestones.
  static int computeMilestoneReward(int milestone) {
    return _milestoneRewards[milestone] ?? 0;
  }

  /// Whether [currentStreak] earns a free streak freeze (every 7 days).
  static bool earnsFreezeForStreak(int currentStreak) {
    return currentStreak > 0 && currentStreak % 7 == 0;
  }
}
