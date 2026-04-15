import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/progression_engine.dart';

void main() {
  group('ProgressionEngine — computeStars', () {
    test('0 incorrect → 3 stars', () {
      expect(ProgressionEngine.computeStars(0), 3);
    });

    test('1 incorrect → 2 stars', () {
      expect(ProgressionEngine.computeStars(1), 2);
    });

    test('2 incorrect → 1 star', () {
      expect(ProgressionEngine.computeStars(2), 1);
    });

    test('many incorrect → 1 star (floor)', () {
      expect(ProgressionEngine.computeStars(100), 1);
    });
  });

  group('ProgressionEngine — computeXP', () {
    test('score 100 → 10 XP', () {
      expect(ProgressionEngine.computeXP(100), 10);
    });

    test('score 0 → 0 XP', () {
      expect(ProgressionEngine.computeXP(0), 0);
    });

    test('score 105 → 11 XP (ceiling)', () {
      expect(ProgressionEngine.computeXP(105), 11);
    });
  });

  group('ProgressionEngine — computeMasteryTier', () {
    test('empty history → bronze', () {
      expect(ProgressionEngine.computeMasteryTier([]), MasteryTier.bronze);
    });

    test('all 1-star → bronze', () {
      expect(ProgressionEngine.computeMasteryTier([1, 1, 1, 1, 1]), MasteryTier.bronze);
    });

    test('mixed mid-range → silver', () {
      // avg = 2.0 → silver
      expect(ProgressionEngine.computeMasteryTier([2, 2, 2, 2, 2]), MasteryTier.silver);
    });

    test('all 3-star → gold', () {
      expect(ProgressionEngine.computeMasteryTier([3, 3, 3, 3, 3]), MasteryTier.gold);
    });

    test('borderline gold: avg exactly 2.5 → gold', () {
      // [2, 3, 2, 3, 3] avg = 13/5 = 2.6 → gold
      expect(ProgressionEngine.computeMasteryTier([2, 3, 2, 3, 3]), MasteryTier.gold);
    });

    test('borderline silver: avg 1.8 → silver', () {
      // [1, 2, 2, 2, 2] avg = 9/5 = 1.8 → silver
      expect(ProgressionEngine.computeMasteryTier([1, 2, 2, 2, 2]), MasteryTier.silver);
    });
  });

  group('ProgressionEngine — computeAdaptiveMultiplier', () {
    const base = 1.0;

    test('fewer than 5 entries → returns current unchanged', () {
      expect(ProgressionEngine.computeAdaptiveMultiplier([3, 3, 3], base), base);
    });

    test('exactly 5 entries with odd total count → no adjustment (smooth guardrail)', () {
      // history.length == 5 → isOdd → skip adjustment
      expect(ProgressionEngine.computeAdaptiveMultiplier([3, 3, 3, 3, 3], base), base);
    });

    test('6 entries (even), all 3-star → increases multiplier', () {
      final result = ProgressionEngine.computeAdaptiveMultiplier(
        [3, 3, 3, 3, 3, 3],
        base,
      );
      expect(result, closeTo(base + kMultiplierStep, 1e-9));
    });

    test('6 entries (even), all 1-star → decreases multiplier', () {
      final result = ProgressionEngine.computeAdaptiveMultiplier(
        [1, 1, 1, 1, 1, 1],
        base,
      );
      expect(result, closeTo(base - kMultiplierStep, 1e-9));
    });

    test('6 entries (even), mixed mid-range → no change', () {
      // [2, 2, 2, 2, 2, 2] avg = 2.0 → maintain
      final result = ProgressionEngine.computeAdaptiveMultiplier(
        [2, 2, 2, 2, 2, 2],
        base,
      );
      expect(result, base);
    });

    test('upper bound clamp: multiplier cannot exceed kMultiplierMax', () {
      // Start at max; even-length all-3-star history should stay clamped.
      final result = ProgressionEngine.computeAdaptiveMultiplier(
        [3, 3, 3, 3, 3, 3],
        kMultiplierMax,
      );
      expect(result, kMultiplierMax);
    });

    test('lower bound clamp: multiplier cannot go below kMultiplierMin', () {
      final result = ProgressionEngine.computeAdaptiveMultiplier(
        [1, 1, 1, 1, 1, 1],
        kMultiplierMin,
      );
      expect(result, kMultiplierMin);
    });

    test('sliding window uses only last 5 of a longer history', () {
      // First bunch of poor performance, then 5 perfect levels.
      // Window = last 5 entriees; all 3-star → should increase from 1.0.
      final history = [...List.filled(10, 1), ...List.filled(5, 3)];
      // history.length = 15 (odd) → no adjustment (smooth guardrail).
      expect(
        ProgressionEngine.computeAdaptiveMultiplier(history, base),
        base,
      );

      // Add one more to make it even (16 entries).
      final history16 = [...history, 3];
      final result = ProgressionEngine.computeAdaptiveMultiplier(history16, base);
      // Window = last 5 of 16 = [3, 3, 3, 3, 3] → avg 3.0 ≥ 2.5 → increase.
      expect(result, closeTo(base + kMultiplierStep, 1e-9));
    });
  });
}
