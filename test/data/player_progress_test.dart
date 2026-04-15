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

    test('recordLevelResult appends star to history and sets version to 1', () {
      final p = PlayerProgress.fresh(playerId: 'player-abc');
      p.recordLevelResult(3);
      expect(p.adaptiveHistory, [3]);
      expect(p.adaptiveVersion, 1);
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

    test('hash remains valid after recording level results', () {
      final p = PlayerProgress.fresh(playerId: 'player-xyz');
      p.totalXP = 50;
      p.levelStars = {'w1-0': 2};

      final secret = 'hmac-secret';
      p.integrityHash = p.calculateHash(secret);
      expect(p.isValid(secret), isTrue);

      // Adaptive fields are not part of the hash — recording a result should
      // not invalidate the signed progress record.
      p.recordLevelResult(2);
      expect(p.isValid(secret), isTrue);
    });

    test('toggling difficultyMode does not invalidate the hash', () {
      final p = PlayerProgress.fresh(playerId: 'player-xyz');
      p.totalXP = 80;
      final secret = 'hmac-key';
      p.integrityHash = p.calculateHash(secret);

      p.difficultyMode = DifficultyMode.adaptive;
      // difficultyMode is a preference field not covered by the HMAC.
      expect(p.isValid(secret), isTrue);
    });
  });
}
