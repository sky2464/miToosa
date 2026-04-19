/// Adaptive difficulty and progression engine for miToosa.
///
/// Pure Dart — no Flutter, Hive, or Riverpod dependencies.
/// All methods are static and deterministic, making them straightforward
/// to test with seeded data.
library;

/// Controls whether the adaptive difficulty system is active for a player.
enum DifficultyMode { standard, adaptive }

/// Aggregated mastery tier derived from a player's full performance history.
enum MasteryTier {
  /// Average stars below 2.5.
  bronze,

  /// Average stars 2.5 – < 4.0.
  silver,

  /// Average stars ≥ 4.0.
  gold,
}

/// Minimum history size before adaptive adjustments are applied.
const int kAdaptiveWindowSize = 5;

/// Lower bound of the difficulty multiplier.
const double kMultiplierMin = 0.75;

/// Upper bound of the difficulty multiplier.
const double kMultiplierMax = 1.50;

/// Fractional change applied in a single adjustment step.
const double kMultiplierStep = 0.10;

/// Computes adaptive difficulty and progression values.
///
/// All members are static — instantiation is intentionally prevented.
class ProgressionEngine {
  const ProgressionEngine._();

  /// Returns a star rating (0–5) for a completed level.
  ///
  /// * 0 incorrect → 5 stars
  /// * 1 incorrect → 4 stars
  /// * 2 incorrect → 3 stars
  /// * 3–4 incorrect → 2 stars
  /// * 5–6 incorrect → 1 star
  /// * 7+ incorrect → 0 stars
  static int computeStars(int incorrectAttempts) {
    if (incorrectAttempts == 0) return 5;
    if (incorrectAttempts == 1) return 4;
    if (incorrectAttempts == 2) return 3;
    if (incorrectAttempts <= 4) return 2;
    if (incorrectAttempts <= 6) return 1;
    return 0;
  }

  /// Migrates [history] from the 1–3 star scale (schema v1) to the 0–5 scale
  /// (schema v2) by multiplying each entry by 5/3 and rounding.
  ///
  /// Returns a new list; the original is not mutated.
  static List<int> migrateAdaptiveHistory(List<int> history) {
    return history.map((s) => (s * 5 / 3).round()).toList();
  }

  /// Returns true if [refuelAt] is not null and is on or before [now],
  /// meaning a timed heart is due.
  static bool shouldRefuelByTime(DateTime? refuelAt, DateTime now) {
    if (refuelAt == null) return false;
    return !refuelAt.isAfter(now);
  }

  /// Returns the [DateTime] when the next timed heart refuel is due
  /// (30 minutes from [now]).
  static DateTime computeNextRefuelTime(DateTime now) {
    return now.add(const Duration(minutes: 30));
  }

  /// Returns true if [completedIndex] is strictly less than [targetIndex],
  /// meaning the completed level is a lower level (grants +1 heart).
  static bool isLowerLevel(int completedIndex, int targetIndex) {
    return completedIndex < targetIndex;
  }

  /// Returns XP earned based on star rating (max 10 XP per level).
  ///
  /// * 5★ → 10 XP, 4★ → 8 XP, 3★ → 6 XP, 2★ → 4 XP, 1★ → 2 XP, 0★ → 1 XP.
  /// When [hintUsed] is true, 1 XP is deducted (floor at 1).
  static int computeXP(int stars, {bool hintUsed = false}) {
    final base = switch (stars) {
      5 => 10,
      4 => 8,
      3 => 6,
      2 => 4,
      1 => 2,
      _ => 1,
    };
    if (hintUsed) return (base - 1).clamp(1, 10);
    return base;
  }

  /// Returns coin reward for a completed level.
  ///
  /// Formula: base 10 + ([stars] × 5) + first-clear bonus 20.
  static int computeCoinReward({required int stars, required bool isFirstClear}) {
    int reward = 10 + (stars * 5);
    if (isFirstClear) reward += 20;
    return reward;
  }

  /// Derives a [MasteryTier] from the player's full performance [history].
  ///
  /// Returns [MasteryTier.bronze] when [history] is empty (new player).
  static MasteryTier computeMasteryTier(List<int> history) {
    if (history.isEmpty) return MasteryTier.bronze;
    final avg = history.reduce((a, b) => a + b) / history.length;
    if (avg >= 4.0) return MasteryTier.gold;
    if (avg >= 2.5) return MasteryTier.silver;
    return MasteryTier.bronze;
  }

  /// Computes the next adaptive difficulty multiplier from recent performance.
  ///
  /// Rules enforced:
  /// * Requires ≥ [kAdaptiveWindowSize] data points; returns [current] if
  ///   the history is too short.
  /// * Evaluates only the most recent [kAdaptiveWindowSize] star ratings.
  /// * Fires only on even-length histories (one evaluation per 2 levels) to
  ///   prevent oscillation.
  /// * Applies at most ±[kMultiplierStep] per evaluation.
  /// * Clamps the result to [[kMultiplierMin], [kMultiplierMax]].
  ///
  /// Average stars ≥ 4.0 → increase difficulty (good performance).
  /// Average stars < 2.0 → decrease difficulty (struggling).
  /// Otherwise         → keep [current] unchanged.
  static double computeAdaptiveMultiplier(
    List<int> history,
    double current,
  ) {
    if (history.length < kAdaptiveWindowSize) return current;

    // Smooth transition guardrail: only evaluate every other level.
    if (history.length.isOdd) return current;

    final window = history.length > kAdaptiveWindowSize
        ? history.sublist(history.length - kAdaptiveWindowSize)
        : List<int>.unmodifiable(history);

    final avgStars = window.reduce((a, b) => a + b) / window.length;

    double next = current;
    if (avgStars >= 4.0) {
      next = current + kMultiplierStep; // performing well → increase difficulty
    } else if (avgStars < 2.0) {
      next = current - kMultiplierStep; // struggling → decrease difficulty
    }
    // 2.0 ≤ avgStars < 4.0 → maintain current multiplier

    return next.clamp(kMultiplierMin, kMultiplierMax);
  }
}
