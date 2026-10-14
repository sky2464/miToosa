part of '../puzzle_generator.dart';

mixin PuzzleGeneratorGridRules on PuzzleGeneratorSupport {
  Puzzle _generateNumberGrid(DifficultyParameters difficulty) {
    final a = random.nextInt(5) + 1;
    final b = random.nextInt(5) + 1;
    final c = random.nextInt(a + b - 1) + 1;
    final answer = a + b - c;

    return _buildMathPuzzle(
      prompt: 'Complete the grid:\n$a  $b\n$c  ?\n(rows sum equal)',
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.numberGrid,
    );
  }
}
