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

  /// Reveals the hint for the current level at the cost of 1 heart.
  /// [hearts] is the caller's current heart count.
  /// Returns true and sets hintUsed=true if the hint can be used;
  /// returns false if already used or [hearts] == 0.
  bool useHint({required int hearts}) {
    if (state.hintUsed || hearts <= 0) return false;
    state = state.copyWith(hintUsed: true);
    return true;
  }

  /// Begins a timed run covering [totalLevels] levels.
  /// Allocates 1 minute per level as the countdown budget.
  void startRun(int totalLevels) {
    state = state.copyWith(
      isRunActive: true,
      levelsInRun: totalLevels,
      runTimeRemaining: Duration(minutes: totalLevels),
      levelsCompleted: 0,
    );
  }

  /// Advances the countdown by [elapsed]. Deactivates run when time runs out.
  void tickTimer(Duration elapsed) {
    if (!state.isRunActive) return;
    final remaining = state.runTimeRemaining - elapsed;
    if (remaining <= Duration.zero) {
      state = state.copyWith(
        isRunActive: false,
        runTimeRemaining: Duration.zero,
      );
    } else {
      state = state.copyWith(runTimeRemaining: remaining);
    }
  }

  /// Records one completed level during an active run.
  /// Returns true (run bonus earned) when all levels in the run are done.
  bool completeLevel() {
    if (!state.isRunActive) return false;
    final newCompleted = state.levelsCompleted + 1;
    final runComplete = newCompleted >= state.levelsInRun;
    state = state.copyWith(
      levelsCompleted: newCompleted,
      isRunActive: runComplete ? false : true,
    );
    return runComplete;
  }
}
