import 'package:equatable/equatable.dart';
import 'shape_item.dart';

enum Shape { circle, square, triangle, star, hexagon, diamond }

enum PuzzleRule {
  // ── Pattern & Visual ──
  matchIdentical,
  countShapes,
  oddOneOut,
  colorPattern,
  findMissing,
  sequenceNext,
  // ── CS & Security ──
  binaryDecode,
  logicGate,
  cipherBreak,
  // ── Math: Arithmetic ──
  balanceEquation,
  mathAddSub, // Addition & subtraction
  mathMulDiv, // Multiplication & division
  mathExponent, // Powers & square roots
  mathModulo, // Remainder / modulo
  mathFraction, // Fraction equivalence & comparison
  mathAlgebra, // Solve for x
  // ── Math: Geometry ──
  geometryArea, // Calculate area from shape dimensions
  geometryAngles, // Find missing angles
  geometrySymmetry, // Lines of symmetry / reflection
  // ── Physics ──
  physicsGravity, // Which falls first? Weight/mass puzzles
  physicsMomentum, // Collision/direction puzzles
  physicsBalance, // Lever/fulcrum balance puzzles
  // ── Advanced Logic ──
  numberGrid, // Sudoku-style number placement
}

class PuzzleOption extends Equatable {
  final String id;
  final List<ShapeItem> items;

  /// Optional text label for text-based puzzle options (binary, logic, etc.)
  final String? label;

  const PuzzleOption({required this.id, required this.items, this.label});

  /// Convenience: raw shapes list for backwards compatibility
  List<Shape> get shapes => items.map((i) => i.shape).toList();

  /// Visual equality — are the displayed items identical?
  bool visuallyEquals(PuzzleOption other) {
    if (items.length != other.items.length) return false;
    for (int i = 0; i < items.length; i++) {
      if (items[i] != other.items[i]) return false;
    }
    if (label != other.label) return false;
    return true;
  }

  @override
  List<Object?> get props => [id, items, label];
}

class Puzzle extends Equatable {
  final String id;
  final String prompt;
  final PuzzleRule rule;
  final List<ShapeItem> targetItems;
  final List<PuzzleOption> options;
  final String correctOptionId;

  const Puzzle({
    required this.id,
    required this.prompt,
    required this.rule,
    required this.targetItems,
    required this.options,
    required this.correctOptionId,
  });

  /// Convenience: raw target shapes for backwards compat
  List<Shape> get targetShapes => targetItems.map((i) => i.shape).toList();

  bool validateAnswer(String optionId) {
    return optionId == correctOptionId;
  }

  @override
  List<Object?> get props => [
    id,
    prompt,
    rule,
    targetItems,
    options,
    correctOptionId,
  ];
}
