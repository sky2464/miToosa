import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/puzzle.dart';
import '../models/shape_item.dart';

part 'generators/puzzle_generator_support.dart';
part 'generators/puzzle_generator_shape_rules.dart';
part 'generators/puzzle_generator_logic_rules.dart';
part 'generators/puzzle_generator_math_rules.dart';
part 'generators/puzzle_generator_science_rules.dart';
part 'generators/puzzle_generator_grid_rules.dart';

mixin PuzzleGeneratorBase {
  Random get random;
}

class DifficultyParameters {
  final int shapeCount;
  final int colorCount;
  final int choiceCount;

  const DifficultyParameters({
    this.shapeCount = 3,
    this.colorCount = 3,
    this.choiceCount = 4,
  });
}

class _PuzzleGeneratorEngine
    with
        PuzzleGeneratorBase,
        PuzzleGeneratorSupport,
        PuzzleGeneratorShapeRules,
        PuzzleGeneratorLogicRules,
        PuzzleGeneratorMathRules,
        PuzzleGeneratorScienceRules,
        PuzzleGeneratorGridRules {
  @override
  final Random random;

  _PuzzleGeneratorEngine(this.random);

  Puzzle generate({
    required PuzzleRule rule,
    required DifficultyParameters difficulty,
  }) {
    return switch (rule) {
      PuzzleRule.matchIdentical => _generateMatchIdentical(difficulty),
      PuzzleRule.countShapes => _generateCountShapes(difficulty),
      PuzzleRule.oddOneOut => _generateOddOneOut(difficulty),
      PuzzleRule.colorPattern => _generateColorPattern(difficulty),
      PuzzleRule.findMissing => _generateFindMissing(difficulty),
      PuzzleRule.sequenceNext => _generateSequenceNext(difficulty),
      PuzzleRule.binaryDecode => _generateBinaryDecode(difficulty),
      PuzzleRule.logicGate => _generateLogicGate(difficulty),
      PuzzleRule.cipherBreak => _generateCipherBreak(difficulty),
      PuzzleRule.balanceEquation => _generateBalanceEquation(difficulty),
      PuzzleRule.mathAddSub => _generateMathAddSub(difficulty),
      PuzzleRule.mathMulDiv => _generateMathMulDiv(difficulty),
      PuzzleRule.mathExponent => _generateMathExponent(difficulty),
      PuzzleRule.mathModulo => _generateMathModulo(difficulty),
      PuzzleRule.mathFraction => _generateMathFraction(difficulty),
      PuzzleRule.mathAlgebra => _generateMathAlgebra(difficulty),
      PuzzleRule.geometryArea => _generateGeometryArea(difficulty),
      PuzzleRule.geometryAngles => _generateGeometryAngles(difficulty),
      PuzzleRule.geometrySymmetry => _generateGeometrySymmetry(difficulty),
      PuzzleRule.physicsGravity => _generatePhysicsGravity(difficulty),
      PuzzleRule.physicsMomentum => _generatePhysicsMomentum(difficulty),
      PuzzleRule.physicsBalance => _generatePhysicsBalance(difficulty),
      PuzzleRule.numberGrid => _generateNumberGrid(difficulty),
    };
  }
}

class PuzzleGenerator {
  final _PuzzleGeneratorEngine _engine;

  PuzzleGenerator([Random? random])
    : _engine = _PuzzleGeneratorEngine(random ?? Random.secure());

  Puzzle generate({
    required PuzzleRule rule,
    required DifficultyParameters difficulty,
  }) => _engine.generate(rule: rule, difficulty: difficulty);
}
