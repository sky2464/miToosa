import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/gameplay_engine.dart';
import 'package:mitoosa/core/models/gameplay_level.dart';
import 'package:mitoosa/features/gameplay/gameplay_view_model.dart';

void main() {
  late ProviderContainer container;
  late GameplayLevel level;

  setUp(() {
    level = GameplayLevel.starterLevel();
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  GameplayViewModel notifier() =>
      container.read(gameplayViewModelProvider(level).notifier);
  GameplayState state() => container.read(gameplayViewModelProvider(level));

  group('GameplayViewModel — useHint', () {
    test('useHint with hearts > 0: sets hintUsed=true, returns true', () {
      expect(notifier().useHint(hearts: 3), true);
      expect(state().hintUsed, true);
    });

    test('useHint with 0 hearts: returns false, hintUsed stays false', () {
      expect(notifier().useHint(hearts: 0), false);
      expect(state().hintUsed, false);
    });

    test('useHint when already used: returns false, state unchanged', () {
      notifier().useHint(hearts: 3);
      expect(state().hintUsed, true);
      final result = notifier().useHint(hearts: 3);
      expect(result, false);
    });
  });

  group('GameplayLevel.stars — hint cap', () {
    test('hintUsed=false: stars not capped (0 incorrect → 5)', () {
      expect(level.stars(0, hintUsed: false), 5);
    });

    test('hintUsed=true: stars capped at 3 (0 incorrect would be 5 → 3)', () {
      expect(level.stars(0, hintUsed: true), 3);
    });

    test('hintUsed=true: stars below 3 not raised (7 incorrect → 0, not 3)', () {
      expect(level.stars(7, hintUsed: true), 0);
    });

    test('hintUsed=true: 2 incorrect (normally 3 stars) stays 3', () {
      expect(level.stars(2, hintUsed: true), 3);
    });
  });

  group('GameplayViewModel — startRun, tickTimer, completeLevel', () {
    test('startRun sets isRunActive, levelsInRun, runTimeRemaining', () {
      notifier().startRun(10);
      expect(state().isRunActive, true);
      expect(state().levelsInRun, 10);
      expect(state().runTimeRemaining, const Duration(minutes: 10));
      expect(state().levelsCompleted, 0);
    });

    test('tickTimer decrements runTimeRemaining', () {
      notifier().startRun(10);
      notifier().tickTimer(const Duration(seconds: 30));
      expect(
        state().runTimeRemaining,
        const Duration(minutes: 9, seconds: 30),
      );
    });

    test('tickTimer reaching zero sets isRunActive=false', () {
      notifier().startRun(10);
      notifier().tickTimer(const Duration(minutes: 10));
      expect(state().isRunActive, false);
      expect(state().runTimeRemaining, Duration.zero);
    });

    test('tickTimer beyond zero clamps to Duration.zero', () {
      notifier().startRun(10);
      notifier().tickTimer(const Duration(minutes: 15));
      expect(state().runTimeRemaining, Duration.zero);
      expect(state().isRunActive, false);
    });

    test('tickTimer does nothing when run is not active', () {
      notifier().tickTimer(const Duration(minutes: 5));
      expect(state().runTimeRemaining, Duration.zero);
      expect(state().isRunActive, false);
    });

    test('completeLevel increments levelsCompleted', () {
      notifier().startRun(3);
      final bonus1 = notifier().completeLevel();
      expect(bonus1, false);
      expect(state().levelsCompleted, 1);
    });

    test('completeLevel returns true and deactivates run when all levels done', () {
      notifier().startRun(3);
      notifier().completeLevel();
      notifier().completeLevel();
      final bonus = notifier().completeLevel();
      expect(bonus, true);
      expect(state().levelsCompleted, 3);
      expect(state().isRunActive, false);
    });

    test('completeLevel returns false when run is not active', () {
      final bonus = notifier().completeLevel();
      expect(bonus, false);
      expect(state().levelsCompleted, 0);
    });
  });

  group('GameplayViewModel — puzzle timer', () {
    test('setDifficultyTier initialises timer with tier seconds', () {
      notifier().setDifficultyTier(DifficultyTier.medium);
      expect(state().difficultyTier, DifficultyTier.medium);
      expect(state().puzzleTimeRemaining, 15);
      expect(state().puzzleTimerPaused, false);
    });

    test('tickPuzzleTimer decrements by 1 second', () {
      notifier().setDifficultyTier(DifficultyTier.easy);
      expect(state().puzzleTimeRemaining, 30);

      final expired = notifier().tickPuzzleTimer();
      expect(expired, false);
      expect(state().puzzleTimeRemaining, 29);
    });

    test('tickPuzzleTimer returns true and increments incorrectAttempts on expiry', () {
      notifier().setDifficultyTier(DifficultyTier.challenge);
      // Tick down from 4 to 0
      for (var i = 0; i < 3; i++) {
        expect(notifier().tickPuzzleTimer(), false);
      }
      // 4th tick expires
      final expired = notifier().tickPuzzleTimer();
      expect(expired, true);
      expect(state().puzzleTimeRemaining, 0);
      expect(state().incorrectAttempts, 1);
      expect(state().feedback?.style, GameplayFeedbackStyle.error);
    });

    test('tickPuzzleTimer does nothing when paused', () {
      notifier().setDifficultyTier(DifficultyTier.hard);
      notifier().pausePuzzleTimer();
      final expired = notifier().tickPuzzleTimer();
      expect(expired, false);
      expect(state().puzzleTimeRemaining, 7);
    });

    test('resetPuzzleTimer restores full duration', () {
      notifier().setDifficultyTier(DifficultyTier.medium);
      notifier().tickPuzzleTimer();
      notifier().tickPuzzleTimer();
      expect(state().puzzleTimeRemaining, 13);

      notifier().resetPuzzleTimer();
      expect(state().puzzleTimeRemaining, 15);
    });

    test('tickPuzzleTimer returns false when no tier is set', () {
      expect(notifier().tickPuzzleTimer(), false);
    });
  });
}
