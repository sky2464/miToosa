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

    test('Star rating returns 3 for perfect, 2 for one miss, 1 for more', () {
      expect(sampleLevel.stars(0), 3);
      expect(sampleLevel.stars(1), 2);
      expect(sampleLevel.stars(2), 1);
      expect(sampleLevel.stars(5), 1);
    });
  });
}
