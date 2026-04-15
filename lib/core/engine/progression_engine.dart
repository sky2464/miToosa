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
  /// Average stars below 1.8.
  bronze,

  /// Average stars 1.8 – < 2.5.
  silver,

  /// Average stars ≥ 2.5.
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

  /// Returns a star rating (1–3) for a completed level.
  ///
  /// * 0 incorrect → 3 stars
  /// * 1 incorrect → 2 stars
  /// * 2+ incorrect → 1 star
  static int computeStars(int incorrectAttempts) {
    if (incorrectAttempts == 0) return 3;
    if (incorrectAttempts == 1) return 2;
    return 1;
  }

  /// Returns XP earned for [score] (⌈score / 10⌉).
  static int computeXP(int score) => (score / 10).ceil();

  /// Derives a [MasteryTier] from the player's full performance [history].
  ///
  /// Returns [MasteryTier.bronze] when [history] is empty (new player).
  static MasteryTier computeMasteryTier(List<int> history) {
    if (history.isEmpty) return MasteryTier.bronze;
    final avg = history.reduce((a, b) => a + b) / history.length;
    if (avg >= 2.5) return MasteryTier.gold;
    if (avg >= 1.8) return MasteryTier.silver;
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
  /// Average stars ≥ 2.5 → increase difficulty (good performance).
  /// Average stars < 1.5 → decrease difficulty (struggling).
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
    if (avgStars >= 2.5) {
      next = current + kMultiplierStep; // performing well → increase difficulty
    } else if (avgStars < 1.5) {
      next = current - kMultiplierStep; // struggling → decrease difficulty
    }
    // 1.5 ≤ avgStars < 2.5 → maintain current multiplier

    return next.clamp(kMultiplierMin, kMultiplierMax);
  }
}
