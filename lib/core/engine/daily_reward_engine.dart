/// Pure-Dart daily reward engine — no Flutter imports.
///
/// Manages a 7-day reward cycle with escalating coin rewards.
library;

class DailyReward {
  final int day; // 1–7
  final int coins;
  final bool isBonusDay; // day 7 = bonus

  const DailyReward({
    required this.day,
    required this.coins,
    this.isBonusDay = false,
  });
}

class DailyRewardEngine {
  DailyRewardEngine._(); // static-only

  static const _cycleLength = 7;

  /// Reward table: day → coins. Day 7 is a bonus day.
  static const _rewards = <int, int>{
    1: 10,
    2: 15,
    3: 20,
    4: 30,
    5: 40,
    6: 50,
    7: 100,
  };

  /// Whether the player can claim today's reward.
  static bool canClaim({
    required DateTime? lastClaim,
    required DateTime now,
  }) {
    if (lastClaim == null) return true;
    return !_isSameCalendarDay(lastClaim, now);
  }

  /// Advances the day counter (1-based, wraps at 7).
  static int nextDay(int currentDay) {
    if (currentDay <= 0) return 1;
    return (currentDay % _cycleLength) + 1;
  }

  /// Returns the reward for a given [day] (1–7). Day 0 returns zero.
  static DailyReward rewardForDay(int day) {
    final coins = _rewards[day] ?? 0;
    return DailyReward(
      day: day,
      coins: coins,
      isBonusDay: day == _cycleLength,
    );
  }

  /// Returns all 7 days of the reward cycle in order.
  static List<DailyReward> fullCycleRewards() {
    return List.generate(
      _cycleLength,
      (i) => rewardForDay(i + 1),
    );
  }

  static bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
