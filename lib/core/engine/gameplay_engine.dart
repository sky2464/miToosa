import '../models/gameplay_level.dart';

sealed class GameplayPhase {
  const GameplayPhase();

  bool get isReady => this is PhaseReady;
  bool get isPlaying => this is PhasePlaying;
  bool get isCompleted => this is PhaseCompleted;
}

class PhaseReady extends GameplayPhase {
  const PhaseReady();
}

class PhasePlaying extends GameplayPhase {
  const PhasePlaying();
}

class PhaseCompleted extends GameplayPhase {
  final int score;
  const PhaseCompleted(this.score);
}

enum GameplayFeedbackStyle { success, warning, error, info }

class GameplayFeedback {
  final GameplayFeedbackStyle style;
  final String message;

  const GameplayFeedback({required this.style, required this.message});
}

class GameplayState {
  final GameplayLevel level;
  final GameplayPhase phase;
  final int incorrectAttempts;
  final String? selectedOptionId;
  final GameplayFeedback? feedback;

  int get score => phase is PhaseCompleted ? (phase as PhaseCompleted).score : 0;

  const GameplayState({
    required this.level,
    this.phase = const PhaseReady(),
    this.incorrectAttempts = 0,
    this.selectedOptionId,
    this.feedback,
  });

  GameplayState copyWith({
    GameplayLevel? level,
    GameplayPhase? phase,
    int? incorrectAttempts,
    String? selectedOptionId,
    GameplayFeedback? feedback,
    bool clearFeedback = false,
  }) {
    return GameplayState(
      level: level ?? this.level,
      phase: phase ?? this.phase,
      incorrectAttempts: incorrectAttempts ?? this.incorrectAttempts,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
    );
  }
}

class GameplayEngine {
  static GameplayState start(GameplayState state) {
    if (!state.phase.isReady) return state;
    return state.copyWith(phase: const PhasePlaying());
  }

  static GameplayState selectOption(GameplayState state, String optionId) {
    if (!state.phase.isPlaying) return state;

    if (state.level.puzzle.validateAnswer(optionId)) {
      final score = state.level.score(state.incorrectAttempts);
      return state.copyWith(
        selectedOptionId: optionId,
        phase: PhaseCompleted(score),
        feedback: GameplayFeedback(
          style: GameplayFeedbackStyle.success,
          message: state.level.successMessage,
        ),
      );
    } else {
      return state.copyWith(
        selectedOptionId: optionId,
        incorrectAttempts: state.incorrectAttempts + 1,
        feedback: GameplayFeedback(
          style: GameplayFeedbackStyle.warning,
          message: state.level.retryMessage,
        ),
      );
    }
  }
}
