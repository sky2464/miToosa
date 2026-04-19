import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/streak_engine.dart';

void main() {
  // ─── checkStreak ──────────────────────────────────────────────────────────

  group('StreakEngine.checkStreak', () {
    test('returns continued when login is consecutive day', () {
      final yesterday = DateTime(2026, 4, 17);
      final today = DateTime(2026, 4, 18);
      final result = StreakEngine.checkStreak(
        lastLoginDate: yesterday,
        now: today,
        streakFreezeCount: 0,
      );
      expect(result, StreakResult.continued);
    });

    test('returns continued for same-day login', () {
      final today = DateTime(2026, 4, 18, 8, 0);
      final laterToday = DateTime(2026, 4, 18, 20, 0);
      final result = StreakEngine.checkStreak(
        lastLoginDate: today,
        now: laterToday,
        streakFreezeCount: 0,
      );
      expect(result, StreakResult.continued);
    });

    test('returns broken when gap > 1 day and no freeze', () {
      final twoDaysAgo = DateTime(2026, 4, 16);
      final today = DateTime(2026, 4, 18);
      final result = StreakEngine.checkStreak(
        lastLoginDate: twoDaysAgo,
        now: today,
        streakFreezeCount: 0,
      );
      expect(result, StreakResult.broken);
    });

    test('returns frozen when gap == 2 days and freeze available', () {
      final twoDaysAgo = DateTime(2026, 4, 16);
      final today = DateTime(2026, 4, 18);
      final result = StreakEngine.checkStreak(
        lastLoginDate: twoDaysAgo,
        now: today,
        streakFreezeCount: 1,
      );
      expect(result, StreakResult.frozen);
    });

    test('returns broken when gap > 2 days even with freeze', () {
      final threeDaysAgo = DateTime(2026, 4, 15);
      final today = DateTime(2026, 4, 18);
      final result = StreakEngine.checkStreak(
        lastLoginDate: threeDaysAgo,
        now: today,
        streakFreezeCount: 3,
      );
      expect(result, StreakResult.broken);
    });

    test('returns continued when lastLoginDate is null (first login)', () {
      final today = DateTime(2026, 4, 18);
      final result = StreakEngine.checkStreak(
        lastLoginDate: null,
        now: today,
        streakFreezeCount: 0,
      );
      expect(result, StreakResult.continued);
    });

    test('handles month boundary (Mar 31 → Apr 1)', () {
      final mar31 = DateTime(2026, 3, 31);
      final apr1 = DateTime(2026, 4, 1);
      final result = StreakEngine.checkStreak(
        lastLoginDate: mar31,
        now: apr1,
        streakFreezeCount: 0,
      );
      expect(result, StreakResult.continued);
    });

    test('handles year boundary (Dec 31 → Jan 1)', () {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);
      final result = StreakEngine.checkStreak(
        lastLoginDate: dec31,
        now: jan1,
        streakFreezeCount: 0,
      );
      expect(result, StreakResult.continued);
    });
  });

  // ─── checkMilestones ──────────────────────────────────────────────────────

  group('StreakEngine.checkMilestones', () {
    test('returns empty when no milestone reached', () {
      final result = StreakEngine.checkMilestones(
        currentStreak: 2,
        alreadyAchieved: [],
      );
      expect(result, isEmpty);
    });

    test('returns [3] when streak hits 3 for first time', () {
      final result = StreakEngine.checkMilestones(
        currentStreak: 3,
        alreadyAchieved: [],
      );
      expect(result, [3]);
    });

    test('returns multiple milestones if streak jumps past several', () {
      // e.g., streak was 0 (fresh), now restored to 14 from save
      final result = StreakEngine.checkMilestones(
        currentStreak: 14,
        alreadyAchieved: [],
      );
      expect(result, containsAll([3, 7, 14]));
      expect(result.length, 3);
    });

    test('does not return already achieved milestones', () {
      final result = StreakEngine.checkMilestones(
        currentStreak: 30,
        alreadyAchieved: [3, 7, 14],
      );
      expect(result, [30]);
    });

    test('returns empty when all qualifying milestones already achieved', () {
      final result = StreakEngine.checkMilestones(
        currentStreak: 7,
        alreadyAchieved: [3, 7],
      );
      expect(result, isEmpty);
    });

    test('365-day milestone is the highest', () {
      final result = StreakEngine.checkMilestones(
        currentStreak: 400,
        alreadyAchieved: [],
      );
      expect(result, containsAll([3, 7, 14, 30, 60, 90, 180, 365]));
      expect(result.length, 8);
    });
  });

  // ─── computeMilestoneReward ───────────────────────────────────────────────

  group('StreakEngine.computeMilestoneReward', () {
    test('3-day milestone → 25 coins', () {
      expect(StreakEngine.computeMilestoneReward(3), 25);
    });

    test('7-day milestone → 50 coins', () {
      expect(StreakEngine.computeMilestoneReward(7), 50);
    });

    test('14-day milestone → 100 coins', () {
      expect(StreakEngine.computeMilestoneReward(14), 100);
    });

    test('30-day milestone → 200 coins', () {
      expect(StreakEngine.computeMilestoneReward(30), 200);
    });

    test('60-day milestone → 400 coins', () {
      expect(StreakEngine.computeMilestoneReward(60), 400);
    });

    test('90-day milestone → 600 coins', () {
      expect(StreakEngine.computeMilestoneReward(90), 600);
    });

    test('180-day milestone → 1000 coins', () {
      expect(StreakEngine.computeMilestoneReward(180), 1000);
    });

    test('365-day milestone → 2000 coins', () {
      expect(StreakEngine.computeMilestoneReward(365), 2000);
    });

    test('unknown milestone → 0 coins', () {
      expect(StreakEngine.computeMilestoneReward(5), 0);
    });
  });

  // ─── earnsFreezeForStreak ─────────────────────────────────────────────────

  group('StreakEngine.earnsFreezeForStreak', () {
    test('streak 7 earns a free freeze', () {
      expect(StreakEngine.earnsFreezeForStreak(7), isTrue);
    });

    test('streak 14 earns a free freeze', () {
      expect(StreakEngine.earnsFreezeForStreak(14), isTrue);
    });

    test('streak 6 does not earn a freeze', () {
      expect(StreakEngine.earnsFreezeForStreak(6), isFalse);
    });

    test('streak 21 earns a free freeze', () {
      expect(StreakEngine.earnsFreezeForStreak(21), isTrue);
    });
  });
}
