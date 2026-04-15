import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mitoosa/core/engine/gameplay_engine.dart';
import 'package:mitoosa/core/models/gameplay_level.dart';

part 'gameplay_view_model.g.dart';

@riverpod
class GameplayViewModel extends _$GameplayViewModel {
  @override
  GameplayState build(GameplayLevel level) {
    return GameplayState(level: level);
  }

  void start() {
    if (state.phase.isReady) {
      state = state.copyWith(phase: const PhasePlaying());
    }
  }

  void selectOption(String optionId) {
    if (state.phase.isPlaying) {
      if (state.level.puzzle.validateAnswer(optionId)) {
        final finalScore = state.level.score(state.incorrectAttempts);
        state = state.copyWith(
          selectedOptionId: optionId,
          phase: PhaseCompleted(finalScore),
          feedback: const GameplayFeedback(
            style: GameplayFeedbackStyle.success,
            message: 'Correct!',
          ),
        );
      } else {
        state = state.copyWith(
          selectedOptionId: optionId,
          incorrectAttempts: state.incorrectAttempts + 1,
          feedback: const GameplayFeedback(
            style: GameplayFeedbackStyle.warning,
            message: 'Try again!',
          ),
        );
      }
    }
  }

  void restart() {
    state = GameplayState(level: state.level);
  }
}
