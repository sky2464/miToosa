import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/gameplay_engine.dart';
import 'package:mitoosa/core/models/gameplay_level.dart';

void main() {
  group('GameplayEngine domain parity tests', () {
    late GameplayLevel sampleLevel;
    late GameplayState initialState;
    
    setUp(() {
      sampleLevel = GameplayLevel.starterLevel();
      initialState = GameplayState(level: sampleLevel);
    });

    test('Engine transitions phase from ready to playing correctly', () {
      expect(initialState.phase.isReady, true);
      
      final nextState = GameplayEngine.start(initialState);
      expect(nextState.phase.isPlaying, true);
    });

    test('Engine succeeds upon correct selection without penalty', () {
      var state = GameplayEngine.start(initialState);

      final correctId = sampleLevel.puzzle.correctOptionId;
      state = GameplayEngine.selectOption(state, correctId);

      expect(state.phase.isCompleted, true);
      expect(state.score, sampleLevel.perfectScore);
    });

    test('Engine increments incorrect attempts on wrong selection', () {
      var state = GameplayEngine.start(initialState);

      final wrongOption = sampleLevel.puzzle.options.firstWhere(
            (o) => o.id != sampleLevel.puzzle.correctOptionId,
      );

      state = GameplayEngine.selectOption(state, wrongOption.id);
      expect(state.phase.isPlaying, true);
      expect(state.incorrectAttempts, 1);
      expect(state.feedback?.style, GameplayFeedbackStyle.warning);
    });

    test('Score decreases with incorrect attempts', () {
      var state = GameplayEngine.start(initialState);

      final wrongOption = sampleLevel.puzzle.options.firstWhere(
            (o) => o.id != sampleLevel.puzzle.correctOptionId,
      );

      state = GameplayEngine.selectOption(state, wrongOption.id);
      state = GameplayEngine.selectOption(state, wrongOption.id);

      final correctId = sampleLevel.puzzle.correctOptionId;
      state = GameplayEngine.selectOption(state, correctId);

      expect(state.phase.isCompleted, true);
      expect(state.score, lessThan(sampleLevel.perfectScore));
      expect(state.incorrectAttempts, 2);
    });

    test('Star rating uses 0–5 scale', () {
      expect(sampleLevel.stars(0), 5);
      expect(sampleLevel.stars(1), 4);
      expect(sampleLevel.stars(2), 3);
      expect(sampleLevel.stars(4), 2);
      expect(sampleLevel.stars(6), 1);
      expect(sampleLevel.stars(7), 0);
    });
  });

  group('GameplayState — hintUsed and run fields', () {
    late GameplayLevel level;

    setUp(() {
      level = GameplayLevel.starterLevel();
    });

    test('defaults: hintUsed=false, isRunActive=false, runTimeRemaining=zero, levelsInRun=0, levelsCompleted=0', () {
      final state = GameplayState(level: level);
      expect(state.hintUsed, false);
      expect(state.isRunActive, false);
      expect(state.runTimeRemaining, Duration.zero);
      expect(state.levelsInRun, 0);
      expect(state.levelsCompleted, 0);
    });

    test('copyWith sets hintUsed independently', () {
      final state = GameplayState(level: level);
      final updated = state.copyWith(hintUsed: true);
      expect(updated.hintUsed, true);
      expect(state.hintUsed, false); // original unchanged
    });

    test('copyWith sets run fields independently', () {
      final state = GameplayState(level: level);
      final updated = state.copyWith(
        isRunActive: true,
        runTimeRemaining: const Duration(minutes: 10),
        levelsInRun: 10,
        levelsCompleted: 3,
      );
      expect(updated.isRunActive, true);
      expect(updated.runTimeRemaining, const Duration(minutes: 10));
      expect(updated.levelsInRun, 10);
      expect(updated.levelsCompleted, 3);
    });

    test('copyWith without new fields preserves existing values', () {
      final state = GameplayState(
        level: level,
        hintUsed: true,
        isRunActive: true,
        levelsInRun: 5,
      );
      final updated = state.copyWith(incorrectAttempts: 1);
      expect(updated.hintUsed, true);
      expect(updated.isRunActive, true);
      expect(updated.levelsInRun, 5);
      expect(updated.incorrectAttempts, 1);
    });
  });
}
