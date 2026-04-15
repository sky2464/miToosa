import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'puzzle.dart';
import 'shape_item.dart';

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
          PuzzleOption(id: correctId, items: const [
            ShapeItem(shape: Shape.circle),
            ShapeItem(shape: Shape.square),
          ]),
          PuzzleOption(id: wrongId, items: const [
            ShapeItem(shape: Shape.square),
            ShapeItem(shape: Shape.triangle),
          ]),
        ],
        correctOptionId: correctId,
      ),
    );
  }

  int score(int incorrectAttempts) {
    final penalty = incorrectAttempts * 20;
    final scaled = (perfectScore * difficultyMultiplier).round();
    return (scaled - penalty).clamp(10, scaled);
  }

  /// Compute star rating (1-3) based on incorrect attempts.
  int stars(int incorrectAttempts) {
    if (incorrectAttempts == 0) return 3;
    if (incorrectAttempts == 1) return 2;
    return 1;
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
