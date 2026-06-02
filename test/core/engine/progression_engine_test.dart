import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/progression_engine.dart';

void main() {
  group('ProgressionEngine — computeStars (0–5 scale)', () {
    test('0 incorrect → 5 stars', () {
      expect(ProgressionEngine.computeStars(0), 5);
    });

    test('1 incorrect → 4 stars', () {
      expect(ProgressionEngine.computeStars(1), 4);
    });

    test('2 incorrect → 3 stars', () {
      expect(ProgressionEngine.computeStars(2), 3);
    });

    test('3 incorrect → 2 stars', () {
      expect(ProgressionEngine.computeStars(3), 2);
    });

    test('4 incorrect → 2 stars (boundary)', () {
      expect(ProgressionEngine.computeStars(4), 2);
    });

    test('5 incorrect → 1 star', () {
      expect(ProgressionEngine.computeStars(5), 1);
    });

    test('6 incorrect → 1 star (boundary)', () {
      expect(ProgressionEngine.computeStars(6), 1);
    });

    test('7 incorrect → 0 stars', () {
      expect(ProgressionEngine.computeStars(7), 0);
    });

    test('many incorrect → 0 stars (floor)', () {
      expect(ProgressionEngine.computeStars(100), 0);
    });
  });

  group('ProgressionEngine — computeXP (stars-based, max 10)', () {
    test('5 stars → 10 XP', () {
      expect(ProgressionEngine.computeXP(5), 10);
    });

    test('4 stars → 8 XP', () {
      expect(ProgressionEngine.computeXP(4), 8);
    });

    test('3 stars → 6 XP', () {
      expect(ProgressionEngine.computeXP(3), 6);
    });

    test('2 stars → 4 XP', () {
      expect(ProgressionEngine.computeXP(2), 4);
    });

    test('1 star → 2 XP', () {
      expect(ProgressionEngine.computeXP(1), 2);
    });

    test('0 stars → 1 XP (floor)', () {
      expect(ProgressionEngine.computeXP(0), 1);
    });

    test('hint penalty: 5 stars with hint → 9 XP', () {
      expect(ProgressionEngine.computeXP(5, hintUsed: true), 9);
    });

    test('hint penalty: 1 star with hint → 1 XP (floor at 1)', () {
      expect(ProgressionEngine.computeXP(1, hintUsed: true), 1);
    });

    test('hint penalty: 0 stars with hint → 1 XP (floor at 1)', () {
      expect(ProgressionEngine.computeXP(0, hintUsed: true), 1);
    });
  });

  group('ProgressionEngine — computeMasteryTier (0–5 scale)', () {
    test('empty history → bronze', () {
      expect(ProgressionEngine.computeMasteryTier([]), MasteryTier.bronze);
    });

    test('all 1-star → bronze (avg 1.0 < 2.5)', () {
      expect(
        ProgressionEngine.computeMasteryTier([1, 1, 1, 1, 1]),
        MasteryTier.bronze,
      );
    });

    test('avg 2.0 → bronze (below silver threshold 2.5)', () {
      expect(
        ProgressionEngine.computeMasteryTier([2, 2, 2, 2, 2]),
        MasteryTier.bronze,
      );
    });

    test('all 3-star → silver (avg 3.0, between 2.5 and 4.0)', () {
      expect(
        ProgressionEngine.computeMasteryTier([3, 3, 3, 3, 3]),
        MasteryTier.silver,
      );
    });

    test('borderline silver: avg exactly 2.5 → silver', () {
      // [2, 3, 2, 3, 3] avg = 13/5 = 2.6 → silver
      expect(
        ProgressionEngine.computeMasteryTier([2, 3, 2, 3, 3]),
        MasteryTier.silver,
      );
    });

    test('avg below 2.5 → bronze', () {
      // [1, 2, 2, 2, 2] avg = 9/5 = 1.8 → bronze
      expect(
        ProgressionEngine.computeMasteryTier([1, 2, 2, 2, 2]),
        MasteryTier.bronze,
      );
    });

    test('all 5-star → gold (avg 5.0 ≥ 4.0)', () {
      expect(
        ProgressionEngine.computeMasteryTier([5, 5, 5, 5, 5]),
        MasteryTier.gold,
      );
    });

    test('borderline gold: avg exactly 4.0 → gold', () {
      // [4, 4, 4, 4, 4] avg = 4.0 → gold
      expect(
        ProgressionEngine.computeMasteryTier([4, 4, 4, 4, 4]),
        MasteryTier.gold,
      );
    });

    test('avg 3.9 → silver (just below gold threshold)', () {
      // [4, 4, 4, 4, 3] avg = 19/5 = 3.8 → silver
      expect(
        ProgressionEngine.computeMasteryTier([4, 4, 4, 4, 3]),
        MasteryTier.silver,
      );
    });
  });

  group('ProgressionEngine — computeAdaptiveMultiplier (0–5 scale)', () {
    const base = 1.0;

    test('fewer than 5 entries → returns current unchanged', () {
      expect(
        ProgressionEngine.computeAdaptiveMultiplier([5, 5, 5], base),
        base,
      );
    });

    test(
      'exactly 5 entries with odd total count → no adjustment (smooth guardrail)',
      () {
        // history.length == 5 → isOdd → skip adjustment
        expect(
          ProgressionEngine.computeAdaptiveMultiplier([5, 5, 5, 5, 5], base),
          base,
        );
      },
    );

    test(
      '6 entries (even), all 5-star → increases multiplier (avg 5.0 ≥ 4.0)',
      () {
        final result = ProgressionEngine.computeAdaptiveMultiplier([
          5,
          5,
          5,
          5,
          5,
          5,
        ], base);
        expect(result, closeTo(base + kMultiplierStep, 1e-9));
      },
    );

    test(
      '6 entries (even), all 1-star → decreases multiplier (avg 1.0 < 2.0)',
      () {
        final result = ProgressionEngine.computeAdaptiveMultiplier([
          1,
          1,
          1,
          1,
          1,
          1,
        ], base);
        expect(result, closeTo(base - kMultiplierStep, 1e-9));
      },
    );

    test(
      '6 entries (even), all 3-star → no change (avg 3.0, neutral zone 2.0–4.0)',
      () {
        final result = ProgressionEngine.computeAdaptiveMultiplier([
          3,
          3,
          3,
          3,
          3,
          3,
        ], base);
        expect(result, base);
      },
    );

    test(
      '6 entries (even), avg exactly 2.0 → no change (boundary, not < 2.0)',
      () {
        final result = ProgressionEngine.computeAdaptiveMultiplier([
          2,
          2,
          2,
          2,
          2,
          2,
        ], base);
        expect(result, base);
      },
    );

    test('upper bound clamp: multiplier cannot exceed kMultiplierMax', () {
      final result = ProgressionEngine.computeAdaptiveMultiplier([
        5,
        5,
        5,
        5,
        5,
        5,
      ], kMultiplierMax);
      expect(result, kMultiplierMax);
    });

    test('lower bound clamp: multiplier cannot go below kMultiplierMin', () {
      final result = ProgressionEngine.computeAdaptiveMultiplier([
        1,
        1,
        1,
        1,
        1,
        1,
      ], kMultiplierMin);
      expect(result, kMultiplierMin);
    });

    test('sliding window uses only last 5 of a longer history', () {
      // 10 poor + 5 perfect (odd total → no adjustment)
      final history = [...List.filled(10, 1), ...List.filled(5, 5)];
      expect(ProgressionEngine.computeAdaptiveMultiplier(history, base), base);

      // Add one more to make it even (16 entries).
      final history16 = [...history, 5];
      final result = ProgressionEngine.computeAdaptiveMultiplier(
        history16,
        base,
      );
      // Window = last 5 of 16 = [5, 5, 5, 5, 5] → avg 5.0 ≥ 4.0 → increase.
      expect(result, closeTo(base + kMultiplierStep, 1e-9));
    });
  });

  group('ProgressionEngine — migrateAdaptiveHistory', () {
    test('empty history → empty list', () {
      expect(ProgressionEngine.migrateAdaptiveHistory([]), isEmpty);
    });

    test('[1, 2, 3] → [2, 3, 5] (×5/3 rounded)', () {
      expect(ProgressionEngine.migrateAdaptiveHistory([1, 2, 3]), [2, 3, 5]);
    });

    test('single value 1 → 2', () {
      expect(ProgressionEngine.migrateAdaptiveHistory([1]), [2]);
    });

    test('single value 3 → 5', () {
      expect(ProgressionEngine.migrateAdaptiveHistory([3]), [5]);
    });

    test('does not mutate original list', () {
      final original = [1, 2, 3];
      ProgressionEngine.migrateAdaptiveHistory(original);
      expect(original, [1, 2, 3]);
    });
  });

  group('ProgressionEngine — heart-refuel helpers', () {
    test('shouldRefuelByTime: null refuelAt → false', () {
      expect(ProgressionEngine.shouldRefuelByTime(null, DateTime.now()), false);
    });

    test('shouldRefuelByTime: refuelAt 30 min ago → true', () {
      final now = DateTime(2026, 4, 14, 12, 0);
      final refuelAt = now.subtract(const Duration(minutes: 30));
      expect(ProgressionEngine.shouldRefuelByTime(refuelAt, now), true);
    });

    test('shouldRefuelByTime: refuelAt exactly now → true (due)', () {
      final now = DateTime(2026, 4, 14, 12, 0);
      expect(ProgressionEngine.shouldRefuelByTime(now, now), true);
    });

    test('shouldRefuelByTime: refuelAt 10 min in future → false', () {
      final now = DateTime(2026, 4, 14, 12, 0);
      final refuelAt = now.add(const Duration(minutes: 10));
      expect(ProgressionEngine.shouldRefuelByTime(refuelAt, now), false);
    });

    test('computeNextRefuelTime: returns now + 30 minutes', () {
      final now = DateTime(2026, 4, 14, 12, 0);
      final expected = DateTime(2026, 4, 14, 12, 30);
      expect(ProgressionEngine.computeNextRefuelTime(now), expected);
    });

    test('isLowerLevel: completedIndex < targetIndex → true', () {
      expect(ProgressionEngine.isLowerLevel(2, 5), true);
    });

    test('isLowerLevel: completedIndex > targetIndex → false', () {
      expect(ProgressionEngine.isLowerLevel(5, 2), false);
    });

    test('isLowerLevel: same index → false', () {
      expect(ProgressionEngine.isLowerLevel(3, 3), false);
    });

    test('isLowerLevel: index 0 vs 1 → true (first level is lower)', () {
      expect(ProgressionEngine.isLowerLevel(0, 1), true);
    });
  });

  group('kProgressionGateXP', () {
    test('gate threshold is 7 XP', () {
      expect(kProgressionGateXP, 7);
    });
  });
}
