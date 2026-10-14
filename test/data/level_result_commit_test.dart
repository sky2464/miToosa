/// BL-41 — a completed puzzle commits every effect of its result once.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';

void main() {
  group('PlayerProgress.commitLevelResult (BL-41)', () {
    PlayerProgress commit(
      PlayerProgress p, {
      String levelId = 'track_0',
      int levelIndex = 0,
      int stars = 3,
      bool hintUsed = false,
    }) {
      p.commitLevelResult(
        levelId: levelId,
        levelIndex: levelIndex,
        stars: stars,
        hintUsed: hintUsed,
        timeSeconds: 42,
        difficultyName: 'easy',
      );
      return p;
    }

    test(
      'first clear records star, XP, bests, history and rewards together',
      () {
        final p = PlayerProgress.fresh(playerId: 'a');
        final unlocked = p.commitLevelResult(
          levelId: 'track_0',
          levelIndex: 0,
          stars: 3,
          hintUsed: false,
          timeSeconds: 42,
          difficultyName: 'easy',
        );

        expect(p.levelStars['track_0'], 3);
        expect(p.totalXP, 6);
        expect(p.levelXP['track_0'], 6);
        expect(p.levelBestTime['track_0'], 42);
        expect(p.levelBestDifficulty['track_0'], 'easy');
        expect(p.adaptiveHistory, [3]);
        expect(p.dailyXP, 6);
        expect(unlocked, ['first_steps']);
        expect(p.unlockedAchievements, ['first_steps']);
        // 10 + 3*5 + 20 first-clear bonus, plus the 10-coin first_steps reward.
        expect(p.coins, 45 + 10);
      },
    );

    test(
      'replaying a cleared level awards no first-clear bonus or duplicate achievement',
      () {
        final p = PlayerProgress.fresh(playerId: 'b');
        commit(p);
        final coinsAfterFirst = p.coins;

        final unlocked = p.commitLevelResult(
          levelId: 'track_0',
          levelIndex: 0,
          stars: 3,
          hintUsed: false,
          timeSeconds: 99,
        );

        expect(unlocked, isEmpty);
        expect(p.unlockedAchievements, ['first_steps']);
        expect(p.coins - coinsAfterFirst, 10 + 3 * 5);
      },
    );

    test('a weaker replay never lowers a stored star rating', () {
      final p = PlayerProgress.fresh(playerId: 'c');
      commit(p, stars: 4);
      commit(p, stars: 1);
      expect(p.levelStars['track_0'], 4);
    });

    test('a stronger replay upgrades the stored star rating', () {
      final p = PlayerProgress.fresh(playerId: 'd');
      commit(p, stars: 2);
      commit(p, stars: 5);
      expect(p.levelStars['track_0'], 5);
    });

    test('hint use reduces XP but still commits the star', () {
      final p = PlayerProgress.fresh(playerId: 'e');
      commit(p, stars: 5, hintUsed: true);
      expect(p.levelStars['track_0'], 5);
      expect(p.totalXP, 9);
    });

    test('refuel fires when the level index is below the completed count', () {
      final p = PlayerProgress.fresh(playerId: 'f')..hearts = 2;
      commit(p, levelIndex: 0);
      expect(p.hearts, 3);

      commit(p, levelId: 'track_2', levelIndex: 2, stars: 2);
      expect(p.hearts, 3, reason: 'index 2 is not below 2 completed levels');
    });
  });
}
