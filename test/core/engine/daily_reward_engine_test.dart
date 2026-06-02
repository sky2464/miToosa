import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/daily_reward_engine.dart';

void main() {
  // ─── canClaim ─────────────────────────────────────────────────────────────

  group('DailyRewardEngine.canClaim', () {
    test('returns true when lastClaim is null (never claimed)', () {
      expect(
        DailyRewardEngine.canClaim(lastClaim: null, now: DateTime(2026, 4, 18)),
        isTrue,
      );
    });

    test('returns true when last claim was a different calendar day', () {
      expect(
        DailyRewardEngine.canClaim(
          lastClaim: DateTime(2026, 4, 17, 23, 59),
          now: DateTime(2026, 4, 18, 0, 1),
        ),
        isTrue,
      );
    });

    test('returns false when already claimed today', () {
      expect(
        DailyRewardEngine.canClaim(
          lastClaim: DateTime(2026, 4, 18, 8, 0),
          now: DateTime(2026, 4, 18, 20, 0),
        ),
        isFalse,
      );
    });
  });

  // ─── nextDay ──────────────────────────────────────────────────────────────

  group('DailyRewardEngine.nextDay', () {
    test('advances from 0 to 1', () {
      expect(DailyRewardEngine.nextDay(0), 1);
    });

    test('advances from 1 to 2', () {
      expect(DailyRewardEngine.nextDay(1), 2);
    });

    test('wraps from 7 back to 1', () {
      expect(DailyRewardEngine.nextDay(7), 1);
    });

    test('wraps from 14 back within cycle (14 % 7 + 1 = 1)', () {
      // Defensive: if corrupted value passed in, still wraps safely
      expect(DailyRewardEngine.nextDay(14), greaterThanOrEqualTo(1));
      expect(DailyRewardEngine.nextDay(14), lessThanOrEqualTo(7));
    });
  });

  // ─── rewardForDay ─────────────────────────────────────────────────────────

  group('DailyRewardEngine.rewardForDay', () {
    test('day 1 returns a positive coin amount', () {
      final r = DailyRewardEngine.rewardForDay(1);
      expect(r.coins, greaterThan(0));
    });

    test('day 7 returns the highest reward', () {
      final day7 = DailyRewardEngine.rewardForDay(7);
      for (var d = 1; d < 7; d++) {
        final other = DailyRewardEngine.rewardForDay(d);
        expect(
          day7.coins,
          greaterThanOrEqualTo(other.coins),
          reason: 'day 7 >= day $d',
        );
      }
    });

    test('day 0 (not started) returns 0', () {
      final r = DailyRewardEngine.rewardForDay(0);
      expect(r.coins, 0);
    });

    test('all 7 days have non-zero rewards', () {
      for (var d = 1; d <= 7; d++) {
        final r = DailyRewardEngine.rewardForDay(d);
        expect(r.coins, greaterThan(0), reason: 'day $d');
      }
    });

    test('rewards increase or stay equal across the week', () {
      for (var d = 2; d <= 7; d++) {
        final prev = DailyRewardEngine.rewardForDay(d - 1);
        final curr = DailyRewardEngine.rewardForDay(d);
        expect(
          curr.coins,
          greaterThanOrEqualTo(prev.coins),
          reason: 'day $d >= day ${d - 1}',
        );
      }
    });
  });

  // ─── fullCycleRewards ─────────────────────────────────────────────────────

  group('DailyRewardEngine.fullCycleRewards', () {
    test('returns exactly 7 entries', () {
      expect(DailyRewardEngine.fullCycleRewards().length, 7);
    });

    test('day numbers are 1–7 in order', () {
      final rewards = DailyRewardEngine.fullCycleRewards();
      expect(rewards.map((r) => r.day).toList(), [1, 2, 3, 4, 5, 6, 7]);
    });
  });
}
