import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/progression_engine.dart';
import 'package:mitoosa/data/player_progress.dart';

void main() {
  test('PlayerProgress calculateHash and isValid behave correctly', () {
    final progress = PlayerProgress(
      playerId: 'user-123',
      totalXP: 100,
      coins: 5,
      levelStars: {'lvl1': 3},
    );

    final secret = 'test-secret-key';

    // Initial: no integrity hash -> considered valid (migration/new)
    expect(progress.integrityHash, isNull);
    expect(progress.isValid(secret), isTrue);

    // After calculating and assigning an integrity hash, isValid should be true
    final h = progress.calculateHash(secret);
    progress.integrityHash = h;
    expect(progress.isValid(secret), isTrue);

    // Mutate a sensitive field and expect validation to fail
    progress.totalXP = 200;
    expect(progress.isValid(secret), isFalse);
  });

  group('PlayerProgress — adaptive difficulty migration fallback', () {
    test('fresh record defaults to standard mode with empty history', () {
      final p = PlayerProgress.fresh(playerId: 'new-player');
      expect(p.difficultyMode, DifficultyMode.standard);
      expect(p.adaptiveHistory, isEmpty);
      expect(p.adaptiveVersion, 0);
    });

    test('recordLevelResult appends star to history and sets version to 2', () {
      final p = PlayerProgress.fresh(playerId: 'player-abc');
      p.recordLevelResult(3);
      expect(p.adaptiveHistory, [3]);
      expect(p.adaptiveVersion, 2);
    });

    test('recordLevelResult keeps at most 20 entries', () {
      final p = PlayerProgress.fresh(playerId: 'player-abc');
      for (int i = 0; i < 25; i++) {
        p.recordLevelResult(i.isEven ? 3 : 1);
      }
      expect(p.adaptiveHistory.length, 20);
      // i=24 is even → stars=3; that was the last recorded entry.
      expect(p.adaptiveHistory.last, 3);
    });

    test('hash is invalidated after recording level results', () {
      final p = PlayerProgress.fresh(playerId: 'player-xyz');
      p.totalXP = 50;
      p.levelStars = {'w1-0': 2};

      final secret = 'hmac-secret';
      p.integrityHash = p.calculateHash(secret);
      expect(p.isValid(secret), isTrue);

      // Adaptive fields are now covered by the hash — recording a result
      // changes adaptiveHistory + adaptiveVersion, invalidating the hash.
      p.recordLevelResult(2);
      expect(p.isValid(secret), isFalse);

      // Re-signing after mutation restores validity.
      p.integrityHash = p.calculateHash(secret);
      expect(p.isValid(secret), isTrue);
    });

    test('toggling difficultyMode invalidates the hash', () {
      final p = PlayerProgress.fresh(playerId: 'player-xyz');
      p.totalXP = 80;
      final secret = 'hmac-key';
      p.integrityHash = p.calculateHash(secret);

      p.difficultyMode = DifficultyMode.adaptive;
      // difficultyMode is now covered by the HMAC.
      expect(p.isValid(secret), isFalse);

      // Re-signing after mutation restores validity.
      p.integrityHash = p.calculateHash(secret);
      expect(p.isValid(secret), isTrue);
    });
  });

  group('PlayerProgress — schema v2 new fields', () {
    test('fresh() defaults: hearts=5, diamonds=0, heartRefuelAt=null, seenTutorialWorlds=[]', () {
      final p = PlayerProgress.fresh(playerId: 'v2-player');
      expect(p.hearts, 5);
      expect(p.diamonds, 0);
      expect(p.heartRefuelAt, isNull);
      expect(p.seenTutorialWorlds, isEmpty);
    });

    test('constructor with explicit new field values', () {
      final now = DateTime(2026, 4, 14, 10, 0);
      final p = PlayerProgress(
        playerId: 'p1',
        hearts: 3,
        diamonds: 2,
        heartRefuelAt: now,
        seenTutorialWorlds: ['track_1', 'track_2'],
      );
      expect(p.hearts, 3);
      expect(p.diamonds, 2);
      expect(p.heartRefuelAt, now);
      expect(p.seenTutorialWorlds, ['track_1', 'track_2']);
    });

    test('constructor omitting new fields applies defaults', () {
      final p = PlayerProgress(playerId: 'legacy');
      expect(p.hearts, 5);
      expect(p.diamonds, 0);
      expect(p.heartRefuelAt, isNull);
      expect(p.seenTutorialWorlds, isEmpty);
    });

    test('hearts field is mutable', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 2;
      expect(p.hearts, 2);
    });

    test('diamonds field is mutable', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.diamonds = 5;
      expect(p.diamonds, 5);
    });
  });

  group('PlayerProgress — adaptiveVersion migration (schema v1 → v2)', () {
    test('migrateAdaptiveHistory scales [1,2,3] → [2,3,5]', () {
      // This is the pure function used by the Hive adapter on read.
      expect(ProgressionEngine.migrateAdaptiveHistory([1, 2, 3]), [2, 3, 5]);
    });

    test('migrateAdaptiveHistory on empty list returns empty list', () {
      expect(ProgressionEngine.migrateAdaptiveHistory([]), isEmpty);
    });
  });

  // ─── Task 6: heart / diamond mutation methods ──────────────────────────────

  group('PlayerProgress — deductHeart', () {
    test('reduces hearts by 1', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 3;
      p.deductHeart();
      expect(p.hearts, 2);
    });

    test('floors at 0 when hearts is already 0', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 0;
      p.deductHeart();
      expect(p.hearts, 0);
    });
  });

  group('PlayerProgress — refuelHeartsWithDiamond', () {
    test('sets hearts to 5 and decrements diamonds by 1', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 1;
      p.diamonds = 2;
      final ok = p.refuelHeartsWithDiamond();
      expect(ok, true);
      expect(p.hearts, 5);
      expect(p.diamonds, 1);
    });

    test('returns false and does nothing when diamonds == 0', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 1;
      p.diamonds = 0;
      final ok = p.refuelHeartsWithDiamond();
      expect(ok, false);
      expect(p.hearts, 1);
      expect(p.diamonds, 0);
    });
  });

  group('PlayerProgress — addDiamond', () {
    test('adds diamonds by given count', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.addDiamond(3);
      expect(p.diamonds, 3);
    });

    test('defaults to adding 1 when no count supplied', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.addDiamond();
      expect(p.diamonds, 1);
    });
  });

  group('PlayerProgress — checkAndRefuelHeart', () {
    test('does nothing and returns false when hearts == 5', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 5;
      final now = DateTime.now();
      final ok = p.checkAndRefuelHeart(now);
      expect(ok, false);
      expect(p.hearts, 5);
    });

    test('does nothing when heartRefuelAt is in the future', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 3;
      p.heartRefuelAt = now.add(const Duration(minutes: 10));
      final ok = p.checkAndRefuelHeart(now);
      expect(ok, false);
      expect(p.hearts, 3);
    });

    test('grants 1 heart when timer has elapsed', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 2;
      // Schedule refuel time 30 minutes in the past
      p.heartRefuelAt = now.subtract(const Duration(minutes: 30));
      final ok = p.checkAndRefuelHeart(now);
      expect(ok, true);
      expect(p.hearts, 3);
    });

    test('schedules next refuel when hearts still below 5 after grant', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 2;
      p.heartRefuelAt = now.subtract(const Duration(minutes: 30));
      p.checkAndRefuelHeart(now);
      // Should now be 3 (< 5), so next refuel scheduled
      expect(p.heartRefuelAt, isNotNull);
    });

    test('clears heartRefuelAt when hearts reach 5 after grant', () {
      final now = DateTime(2026, 1, 1, 12, 0);
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 4;
      p.heartRefuelAt = now.subtract(const Duration(minutes: 30));
      p.checkAndRefuelHeart(now);
      expect(p.hearts, 5);
      expect(p.heartRefuelAt, isNull);
    });

    test('does nothing when heartRefuelAt is null', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 3;
      p.heartRefuelAt = null;
      final ok = p.checkAndRefuelHeart(DateTime.now());
      expect(ok, false);
      expect(p.hearts, 3);
    });
  });

  group('PlayerProgress — refuelHeartLowerLevel', () {
    test('adds 1 heart when below max', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 3;
      p.refuelHeartLowerLevel();
      expect(p.hearts, 4);
    });

    test('does not exceed 5', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 5;
      p.refuelHeartLowerLevel();
      expect(p.hearts, 5);
    });
  });

  group('PlayerProgress — markTutorialSeen', () {
    test('adds worldId when not already present', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.markTutorialSeen('track_1');
      expect(p.seenTutorialWorlds, ['track_1']);
    });

    test('does not add duplicate worldId', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.markTutorialSeen('track_1');
      p.markTutorialSeen('track_1');
      expect(p.seenTutorialWorlds.length, 1);
    });

    test('can accumulate multiple distinct worlds', () {
      final p = PlayerProgress.fresh(playerId: 'p');
      p.markTutorialSeen('track_1');
      p.markTutorialSeen('track_2');
      expect(p.seenTutorialWorlds, containsAll(['track_1', 'track_2']));
    });
  });

  group('PlayerProgress — shareAndRefuel', () {
    final today = DateTime(2026, 4, 14);

    test('grants +1 heart when hearts < 5 and not shared today', () {
      final p = PlayerProgress(playerId: 'u', hearts: 3, lastShareDate: null);
      final granted = p.shareAndRefuel(today);
      expect(granted, isTrue);
      expect(p.hearts, 4);
      expect(p.lastShareDate, today);
    });

    test('does not grant heart when already shared today', () {
      final p = PlayerProgress(playerId: 'u', hearts: 3, lastShareDate: today);
      final granted = p.shareAndRefuel(today);
      expect(granted, isFalse);
      expect(p.hearts, 3);
    });

    test('does not grant heart when hearts already at 5', () {
      final p = PlayerProgress(playerId: 'u', hearts: 5, lastShareDate: null);
      final granted = p.shareAndRefuel(today);
      expect(granted, isFalse);
      expect(p.hearts, 5);
    });

    test('grants heart on a new calendar day even if shared yesterday', () {
      final yesterday = DateTime(2026, 4, 13);
      final p = PlayerProgress(playerId: 'u', hearts: 2, lastShareDate: yesterday);
      final granted = p.shareAndRefuel(today);
      expect(granted, isTrue);
      expect(p.hearts, 3);
    });

    test('grants heart across month boundary (Mar 31 → Apr 1)', () {
      final mar31 = DateTime(2026, 3, 31);
      final apr1 = DateTime(2026, 4, 1);
      final p = PlayerProgress(playerId: 'u', hearts: 2, lastShareDate: mar31);
      expect(p.shareAndRefuel(apr1), isTrue);
      expect(p.hearts, 3);
    });

    test('grants heart across year boundary (Dec 31 → Jan 1)', () {
      final dec31 = DateTime(2025, 12, 31);
      final jan1 = DateTime(2026, 1, 1);
      final p = PlayerProgress(playerId: 'u', hearts: 2, lastShareDate: dec31);
      expect(p.shareAndRefuel(jan1), isTrue);
      expect(p.hearts, 3);
    });

    test('does NOT grant heart same calendar day at a later hour', () {
      final morning = DateTime(2026, 4, 14, 7, 0);
      final evening = DateTime(2026, 4, 14, 22, 0);
      final p = PlayerProgress(playerId: 'u', hearts: 3, lastShareDate: morning);
      expect(p.shareAndRefuel(evening), isFalse);
      expect(p.hearts, 3);
    });

    test('lastShareDate is updated to the new date after a successful grant', () {
      final apr1 = DateTime(2026, 4, 1);
      final apr2 = DateTime(2026, 4, 2);
      final p = PlayerProgress(playerId: 'u', hearts: 2, lastShareDate: apr1);
      p.shareAndRefuel(apr2);
      expect(p.lastShareDate, apr2);
    });
  });

  group('PlayerProgress — checkAndRefuelHeart time precision', () {
    test('next refuel scheduled exactly 30 min from now', () {
      final now = DateTime(2026, 4, 14, 10, 0);
      final expected = DateTime(2026, 4, 14, 10, 30);
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 2;
      p.heartRefuelAt = now.subtract(const Duration(minutes: 30));
      p.checkAndRefuelHeart(now);
      expect(p.hearts, 3);
      expect(p.heartRefuelAt, expected);
    });

    test('checkAndRefuelHeart grants heart on exact due-time', () {
      final due = DateTime(2026, 4, 14, 10, 30);
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 3;
      p.heartRefuelAt = due;
      expect(p.checkAndRefuelHeart(due), isTrue);
      expect(p.hearts, 4);
    });

    test('heartRefuelAt cleared when hearts reach 5 after refuel', () {
      final now = DateTime(2026, 4, 14, 10, 0);
      final p = PlayerProgress.fresh(playerId: 'p');
      p.hearts = 4;
      p.heartRefuelAt = now.subtract(const Duration(minutes: 30));
      p.checkAndRefuelHeart(now);
      expect(p.hearts, 5);
      expect(p.heartRefuelAt, isNull);
    });
  });
}
