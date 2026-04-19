import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/achievement_engine.dart';

void main() {
  // ─── catalog ──────────────────────────────────────────────────────────────

  group('AchievementEngine.catalog', () {
    test('contains at least 8 achievements', () {
      expect(AchievementEngine.catalog.length, greaterThanOrEqualTo(8));
    });

    test('all IDs are unique', () {
      final ids = AchievementEngine.catalog.map((a) => a.id).toSet();
      expect(ids.length, AchievementEngine.catalog.length);
    });

    test('every achievement has a positive coin reward', () {
      for (final a in AchievementEngine.catalog) {
        expect(a.coinReward, greaterThan(0), reason: '${a.id} reward');
      }
    });

    test('every achievement has a positive threshold', () {
      for (final a in AchievementEngine.catalog) {
        expect(a.threshold, greaterThan(0), reason: '${a.id} threshold');
      }
    });
  });

  // ─── evaluateAll ──────────────────────────────────────────────────────────

  group('AchievementEngine.evaluateAll', () {
    test('returns empty when no progress', () {
      final newly = AchievementEngine.evaluateAll(
        totalLevelsCompleted: 0,
        totalStars: 0,
        totalXP: 0,
        currentStreak: 0,
        achievementProgress: {},
        alreadyUnlocked: [],
      );
      expect(newly, isEmpty);
    });

    test('unlocks first_steps at 1 level completed', () {
      final newly = AchievementEngine.evaluateAll(
        totalLevelsCompleted: 1,
        totalStars: 3,
        totalXP: 100,
        currentStreak: 0,
        achievementProgress: {},
        alreadyUnlocked: [],
      );
      expect(newly.map((a) => a.id), contains('first_steps'));
    });

    test('does not return already-unlocked achievements', () {
      final newly = AchievementEngine.evaluateAll(
        totalLevelsCompleted: 50,
        totalStars: 150,
        totalXP: 5000,
        currentStreak: 7,
        achievementProgress: {},
        alreadyUnlocked: ['first_steps', 'star_collector_50'],
      );
      final ids = newly.map((a) => a.id).toList();
      expect(ids, isNot(contains('first_steps')));
      expect(ids, isNot(contains('star_collector_50')));
    });

    test('unlocks streak_week at streak 7', () {
      final newly = AchievementEngine.evaluateAll(
        totalLevelsCompleted: 0,
        totalStars: 0,
        totalXP: 0,
        currentStreak: 7,
        achievementProgress: {},
        alreadyUnlocked: [],
      );
      expect(newly.map((a) => a.id), contains('streak_week'));
    });

    test('unlocks multiple achievements in one call', () {
      final newly = AchievementEngine.evaluateAll(
        totalLevelsCompleted: 10,
        totalStars: 30,
        totalXP: 1000,
        currentStreak: 7,
        achievementProgress: {},
        alreadyUnlocked: [],
      );
      expect(newly.length, greaterThanOrEqualTo(2));
    });
  });

  // ─── progressFor ──────────────────────────────────────────────────────────

  group('AchievementEngine.progressFor', () {
    test('returns 0.0 for unstarted achievement', () {
      final pct = AchievementEngine.progressFor(
        achievementId: 'first_steps',
        totalLevelsCompleted: 0,
        totalStars: 0,
        totalXP: 0,
        currentStreak: 0,
        achievementProgress: {},
      );
      expect(pct, 0.0);
    });

    test('returns 1.0 for completed achievement', () {
      final pct = AchievementEngine.progressFor(
        achievementId: 'first_steps',
        totalLevelsCompleted: 1,
        totalStars: 3,
        totalXP: 100,
        currentStreak: 0,
        achievementProgress: {},
      );
      expect(pct, 1.0);
    });

    test('returns fractional progress', () {
      final pct = AchievementEngine.progressFor(
        achievementId: 'level_master_50',
        totalLevelsCompleted: 25,
        totalStars: 0,
        totalXP: 0,
        currentStreak: 0,
        achievementProgress: {},
      );
      expect(pct, closeTo(0.5, 0.01));
    });

    test('clamps at 1.0 when over threshold', () {
      final pct = AchievementEngine.progressFor(
        achievementId: 'first_steps',
        totalLevelsCompleted: 999,
        totalStars: 0,
        totalXP: 0,
        currentStreak: 0,
        achievementProgress: {},
      );
      expect(pct, 1.0);
    });

    test('returns 0.0 for unknown achievement', () {
      final pct = AchievementEngine.progressFor(
        achievementId: 'nonexistent',
        totalLevelsCompleted: 50,
        totalStars: 150,
        totalXP: 5000,
        currentStreak: 7,
        achievementProgress: {},
      );
      expect(pct, 0.0);
    });
  });
}
