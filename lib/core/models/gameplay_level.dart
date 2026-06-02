import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import '../engine/progression_engine.dart';
import 'puzzle.dart';
import 'shape_item.dart';

/// Per-puzzle countdown duration based on session difficulty.
enum DifficultyTier {
  easy(label: 'Easy', seconds: 30),
  medium(label: 'Medium', seconds: 15),
  hard(label: 'Hard', seconds: 7),
  challenge(label: 'Challenge', seconds: 4);

  const DifficultyTier({required this.label, required this.seconds});
  final String label;
  final int seconds;

  Duration get duration => Duration(seconds: seconds);
}

class GameplayLevel extends Equatable {
  final String title;
  final Puzzle puzzle;
  final String? hint;
  final String successMessage;
  final String retryMessage;
  final int perfectScore;

  /// Scales [perfectScore] when computing the level's earned score.
  ///
  /// Values > 1.0 represent increased difficulty (higher potential score);
  /// values < 1.0 represent reduced difficulty. Defaults to 1.0 (standard).
  final double difficultyMultiplier;

  const GameplayLevel({
    required this.title,
    required this.puzzle,
    this.hint,
    required this.successMessage,
    required this.retryMessage,
    required this.perfectScore,
    this.difficultyMultiplier = 1.0,
  });

  /// Factory constructor representing a sample or starter level
  factory GameplayLevel.starterLevel() {
    final correctId = const Uuid().v4();
    final wrongId = const Uuid().v4();

    return GameplayLevel(
      title: 'Starter Puzzle',
      hint: 'Find the exact match',
      successMessage: 'Great job!',
      retryMessage: 'Try again!',
      perfectScore: 100,
      puzzle: Puzzle(
        id: const Uuid().v4(),
        prompt: 'Match the shapes',
        rule: PuzzleRule.matchIdentical,
        targetItems: const [
          ShapeItem(shape: Shape.circle),
          ShapeItem(shape: Shape.square),
        ],
        options: [
          PuzzleOption(
            id: correctId,
            items: const [
              ShapeItem(shape: Shape.circle),
              ShapeItem(shape: Shape.square),
            ],
          ),
          PuzzleOption(
            id: wrongId,
            items: const [
              ShapeItem(shape: Shape.square),
              ShapeItem(shape: Shape.triangle),
            ],
          ),
        ],
        correctOptionId: correctId,
      ),
    );
  }

  int score(int incorrectAttempts) {
    final penalty = incorrectAttempts * 20;
    final scaled = (perfectScore * difficultyMultiplier).round();
    // Ensure the floor (10) never exceeds the ceiling (scaled) to avoid
    // ArgumentError from clamp when scaled < 10 (e.g. low perfectScore
    // combined with a sub-1.0 adaptive multiplier).
    final floor = scaled < 10 ? scaled : 10;
    return (scaled - penalty).clamp(floor, scaled);
  }

  /// Compute star rating (0–5) based on incorrect attempts.
  /// When [hintUsed] is true the result is capped at 3.
  int stars(int incorrectAttempts, {bool hintUsed = false}) {
    final raw = ProgressionEngine.computeStars(incorrectAttempts);
    return hintUsed ? raw.clamp(0, 3) : raw;
  }

  @override
  List<Object?> get props => [
    title,
    puzzle,
    hint,
    successMessage,
    retryMessage,
    perfectScore,
    difficultyMultiplier,
  ];
}
