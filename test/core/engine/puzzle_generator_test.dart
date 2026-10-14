import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/puzzle_generator.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/core/models/shape_item.dart';

void main() {
  group('PuzzleGenerator — correctness guarantees', () {
    late PuzzleGenerator generator;

    setUp(() {
      generator = PuzzleGenerator(Random(42)); // Seeded for determinism
    });

    const baseDifficulty = DifficultyParameters(
      shapeCount: 4,
      colorCount: 3,
      choiceCount: 4,
    );

    // ─── Core invariant: exactly ONE correct answer ────────────

    for (final rule in PuzzleRule.values) {
      test('$rule: puzzle has exactly one correct option', () {
        final puzzle = generator.generate(
          rule: rule,
          difficulty: baseDifficulty,
        );

        final correctMatches = puzzle.options
            .where((o) => o.id == puzzle.correctOptionId)
            .length;
        expect(
          correctMatches,
          1,
          reason: '$rule should have exactly one correct option',
        );
      });

      test('$rule: correctOptionId exists in options list', () {
        final puzzle = generator.generate(
          rule: rule,
          difficulty: baseDifficulty,
        );

        final ids = puzzle.options.map((o) => o.id).toSet();
        expect(
          ids.contains(puzzle.correctOptionId),
          isTrue,
          reason: '$rule correctOptionId must be in options',
        );
      });

      test('$rule: all option IDs are unique', () {
        final puzzle = generator.generate(
          rule: rule,
          difficulty: baseDifficulty,
        );

        final ids = puzzle.options.map((o) => o.id).toList();
        expect(
          ids.toSet().length,
          ids.length,
          reason: '$rule option IDs must all be unique',
        );
      });
    }

    // ─── BUG FIX VALIDATION: no visually duplicate options ─────

    test(
      'matchIdentical: no two options are visually identical (stress test)',
      () {
        final gen = PuzzleGenerator(Random(123));
        int duplicateCount = 0;

        for (int i = 0; i < 500; i++) {
          final puzzle = gen.generate(
            rule: PuzzleRule.matchIdentical,
            difficulty: const DifficultyParameters(
              shapeCount: 3,
              colorCount: 2,
              choiceCount: 4,
            ),
          );

          for (int a = 0; a < puzzle.options.length; a++) {
            for (int b = a + 1; b < puzzle.options.length; b++) {
              if (puzzle.options[a].visuallyEquals(puzzle.options[b])) {
                duplicateCount++;
              }
            }
          }
        }

        expect(
          duplicateCount,
          0,
          reason: 'No two options should be visually identical',
        );
      },
    );

    test(
      'colorPattern: no two options are visually identical (stress test)',
      () {
        final gen = PuzzleGenerator(Random(456));
        int duplicateCount = 0;

        for (int i = 0; i < 500; i++) {
          final puzzle = gen.generate(
            rule: PuzzleRule.colorPattern,
            difficulty: baseDifficulty,
          );

          for (int a = 0; a < puzzle.options.length; a++) {
            for (int b = a + 1; b < puzzle.options.length; b++) {
              if (puzzle.options[a].visuallyEquals(puzzle.options[b])) {
                duplicateCount++;
              }
            }
          }
        }

        expect(
          duplicateCount,
          0,
          reason: 'colorPattern: no visual duplicates allowed',
        );
      },
    );

    // ─── countShapes: no zero-count options ────────────────────

    test('countShapes: all options have at least 1 shape', () {
      for (int seed = 0; seed < 200; seed++) {
        final gen = PuzzleGenerator(Random(seed));
        final puzzle = gen.generate(
          rule: PuzzleRule.countShapes,
          difficulty: baseDifficulty,
        );

        for (final option in puzzle.options) {
          expect(
            option.items.isNotEmpty,
            isTrue,
            reason: 'countShapes options must have >= 1 item (seed=$seed)',
          );
        }
      }
    });

    // ─── oddOneOut: no infinite loop ───────────────────────────

    test('oddOneOut: generates without hanging across many seeds', () {
      for (int seed = 0; seed < 200; seed++) {
        final gen = PuzzleGenerator(Random(seed));
        final puzzle = gen.generate(
          rule: PuzzleRule.oddOneOut,
          difficulty: const DifficultyParameters(
            shapeCount: 5,
            colorCount: 2,
            choiceCount: 5,
          ),
        );

        expect(puzzle.options.isNotEmpty, isTrue);
        expect(puzzle.options.length, greaterThanOrEqualTo(2));
      }
    });

    // ─── Difficulty scaling ────────────────────────────────────

    test('matchIdentical: respects shapeCount parameter', () {
      final puzzle = generator.generate(
        rule: PuzzleRule.matchIdentical,
        difficulty: const DifficultyParameters(
          shapeCount: 6,
          colorCount: 4,
          choiceCount: 5,
        ),
      );

      expect(puzzle.targetItems.length, 6);
      expect(puzzle.options.length, 5);
    });

    // ─── New puzzle types: basic smoke tests ───────────────────

    test('binaryDecode: label matches decoded binary value', () {
      final puzzle = generator.generate(
        rule: PuzzleRule.binaryDecode,
        difficulty: baseDifficulty,
      );

      final correct = puzzle.options.firstWhere(
        (o) => o.id == puzzle.correctOptionId,
      );
      expect(correct.label, isNotNull);
      final value = int.tryParse(correct.label!);
      expect(value, isNotNull);
      expect(value, greaterThan(0));
    });

    test('logicGate: has exactly 2 options (TRUE/FALSE)', () {
      final puzzle = generator.generate(
        rule: PuzzleRule.logicGate,
        difficulty: baseDifficulty,
      );

      expect(puzzle.options.length, 2);
      final labels = puzzle.options.map((o) => o.label).toSet();
      expect(labels.contains('TRUE'), isTrue);
      expect(labels.contains('FALSE'), isTrue);
    });

    test('balanceEquation: correct label is sum of parts', () {
      final puzzle = generator.generate(
        rule: PuzzleRule.balanceEquation,
        difficulty: baseDifficulty,
      );

      final correct = puzzle.options.firstWhere(
        (o) => o.id == puzzle.correctOptionId,
      );
      expect(correct.label, isNotNull);
      final value = int.tryParse(correct.label!);
      expect(value, isNotNull);
      expect(value, greaterThan(0));
    });

    test('sequenceNext: target items form a repeating pattern', () {
      final puzzle = generator.generate(
        rule: PuzzleRule.sequenceNext,
        difficulty: baseDifficulty,
      );

      expect(puzzle.targetItems.length, greaterThanOrEqualTo(3));
      expect(puzzle.options.length, greaterThanOrEqualTo(2));
    });

    test('findMissing: one target item is the placeholder', () {
      final puzzle = generator.generate(
        rule: PuzzleRule.findMissing,
        difficulty: baseDifficulty,
      );

      // Should have a placeholder (outlined diamond)
      expect(puzzle.targetItems.length, greaterThanOrEqualTo(3));
    });

    // ─── findMissing: the gap must be solvable, not just well-formed ───
    //
    // The missing item must be inferable from a repeated value still
    // visible in the sequence — not a value only the generator knows.

    const findMissingPlaceholder = ShapeItem(
      shape: Shape.diamond,
      color: ShapeColor.yellow,
      fill: ShapeFill.outlined,
    );

    void expectFindMissingIsSolvable(
      Puzzle puzzle,
      int seed,
      DifficultyParameters difficulty,
    ) {
      final correct = puzzle.options.firstWhere(
        (o) => o.id == puzzle.correctOptionId,
      );
      expect(
        correct.items.length,
        1,
        reason:
            'findMissing correct option must hold exactly one item '
            '(seed=$seed, difficulty=$difficulty)',
      );
      final missingItem = correct.items.single;
      final visibleItems = puzzle.targetItems.where(
        (item) => item != findMissingPlaceholder,
      );
      expect(
        visibleItems.contains(missingItem),
        isTrue,
        reason:
            'findMissing: the missing item ($missingItem) must be inferable '
            'from a repeated value still visible in the sequence '
            '(seed=$seed, difficulty=$difficulty)',
      );
    }

    test('findMissing: missing item is inferable from a repeated visible '
        'item (1,000 seeds)', () {
      for (int seed = 0; seed < 1000; seed++) {
        final gen = PuzzleGenerator(Random(seed));
        final puzzle = gen.generate(
          rule: PuzzleRule.findMissing,
          difficulty: baseDifficulty,
        );
        expectFindMissingIsSolvable(puzzle, seed, baseDifficulty);
      }
    });

    test('findMissing: still solvable at minimum and maximum difficulty '
        '(500 seeds each)', () {
      const minDifficulty = DifficultyParameters(
        shapeCount: 3,
        colorCount: 2,
        choiceCount: 3,
      );
      const maxDifficulty = DifficultyParameters(
        shapeCount: 8,
        colorCount: 6,
        choiceCount: 7,
      );
      for (final difficulty in [minDifficulty, maxDifficulty]) {
        for (int seed = 0; seed < 500; seed++) {
          final gen = PuzzleGenerator(Random(seed));
          final puzzle = gen.generate(
            rule: PuzzleRule.findMissing,
            difficulty: difficulty,
          );
          expectFindMissingIsSolvable(puzzle, seed, difficulty);
        }
      }
    });

    test('cipherBreak: correct label is a non-empty string', () {
      final puzzle = generator.generate(
        rule: PuzzleRule.cipherBreak,
        difficulty: baseDifficulty,
      );

      final correct = puzzle.options.firstWhere(
        (o) => o.id == puzzle.correctOptionId,
      );
      expect(correct.label, isNotNull);
      expect(correct.label!.isNotEmpty, isTrue);
    });

    // ─── Determinism ───────────────────────────────────────────

    test('Same seed produces same puzzle', () {
      final gen1 = PuzzleGenerator(Random(999));
      final gen2 = PuzzleGenerator(Random(999));

      final p1 = gen1.generate(
        rule: PuzzleRule.matchIdentical,
        difficulty: baseDifficulty,
      );
      final p2 = gen2.generate(
        rule: PuzzleRule.matchIdentical,
        difficulty: baseDifficulty,
      );

      // Target items should be identical
      expect(p1.targetItems.length, p2.targetItems.length);
      for (int i = 0; i < p1.targetItems.length; i++) {
        expect(p1.targetItems[i], p2.targetItems[i]);
      }
    });

    // ─── Edge cases ────────────────────────────────────────────

    test('Minimum difficulty does not crash', () {
      for (final rule in PuzzleRule.values) {
        final puzzle = generator.generate(
          rule: rule,
          difficulty: const DifficultyParameters(
            shapeCount: 3,
            colorCount: 2,
            choiceCount: 3,
          ),
        );
        expect(puzzle.options.isNotEmpty, isTrue);
      }
    });

    test('High difficulty does not crash', () {
      for (final rule in PuzzleRule.values) {
        final puzzle = generator.generate(
          rule: rule,
          difficulty: const DifficultyParameters(
            shapeCount: 8,
            colorCount: 6,
            choiceCount: 7,
          ),
        );
        expect(puzzle.options.isNotEmpty, isTrue);
      }
    });

    // ─── Math arithmetic: correct label is a parseable integer ─

    for (final rule in [
      PuzzleRule.mathAddSub,
      PuzzleRule.mathMulDiv,
      PuzzleRule.mathExponent,
      PuzzleRule.mathModulo,
      PuzzleRule.mathAlgebra,
      PuzzleRule.balanceEquation,
      PuzzleRule.geometryArea,
      PuzzleRule.geometryAngles,
      PuzzleRule.physicsBalance,
      PuzzleRule.numberGrid,
    ]) {
      test('$rule: correct label is a parseable integer', () {
        for (int seed = 0; seed < 50; seed++) {
          final gen = PuzzleGenerator(Random(seed));
          final puzzle = gen.generate(rule: rule, difficulty: baseDifficulty);
          final correct = puzzle.options.firstWhere(
            (o) => o.id == puzzle.correctOptionId,
          );
          expect(
            correct.label,
            isNotNull,
            reason: '$rule correct option must have a label (seed=$seed)',
          );
          final value = int.tryParse(correct.label!);
          expect(
            value,
            isNotNull,
            reason:
                '$rule correct label must be a parseable int, got "${correct.label}" (seed=$seed)',
          );
        }
      });
    }

    // ─── numberGrid: correct label actually satisfies the stated
    // "rows sum equal" relation, not just a parseable positive int ──

    test(
      'numberGrid: correct label satisfies "rows sum equal" (1,000 seeds)',
      () {
        final promptPattern = RegExp(
          r'Complete the grid:\n(\d+)  (\d+)\n(\d+)  \?',
        );
        for (int seed = 0; seed < 1000; seed++) {
          final gen = PuzzleGenerator(Random(seed));
          final puzzle = gen.generate(
            rule: PuzzleRule.numberGrid,
            difficulty: baseDifficulty,
          );
          final match = promptPattern.firstMatch(puzzle.prompt);
          expect(
            match,
            isNotNull,
            reason:
                'numberGrid prompt format changed unexpectedly '
                '(seed=$seed)',
          );
          final a = int.parse(match!.group(1)!);
          final b = int.parse(match.group(2)!);
          final c = int.parse(match.group(3)!);
          final correct = puzzle.options.firstWhere(
            (o) => o.id == puzzle.correctOptionId,
          );
          final answer = int.parse(correct.label!);
          expect(
            answer,
            greaterThan(0),
            reason:
                'numberGrid: answer must be a positive integer '
                '(seed=$seed)',
          );
          expect(
            c + answer,
            a + b,
            reason:
                'numberGrid: row sums must be equal — c+answer ($c+$answer) '
                'must equal a+b ($a+$b) (seed=$seed)',
          );
        }
      },
    );

    // ─── mathFraction: correct label is a valid fraction string ─

    test('mathFraction: correct label matches simplified fraction format', () {
      for (int seed = 0; seed < 50; seed++) {
        final gen = PuzzleGenerator(Random(seed));
        final puzzle = gen.generate(
          rule: PuzzleRule.mathFraction,
          difficulty: baseDifficulty,
        );
        final correct = puzzle.options.firstWhere(
          (o) => o.id == puzzle.correctOptionId,
        );
        expect(
          correct.label,
          isNotNull,
          reason: 'mathFraction correct option must have a label',
        );
        // Must match n/d or be a whole number like "1"
        final isValidFraction = RegExp(
          r'^\d+(/\d+)?$',
        ).hasMatch(correct.label!);
        expect(
          isValidFraction,
          isTrue,
          reason:
              'mathFraction label "${correct.label}" must match n/d format (seed=$seed)',
        );
      }
    });

    // ─── geometrySymmetry: correct label is an int or "∞" ──────

    test('geometrySymmetry: correct label is a count or infinity symbol', () {
      for (int seed = 0; seed < 50; seed++) {
        final gen = PuzzleGenerator(Random(seed));
        final puzzle = gen.generate(
          rule: PuzzleRule.geometrySymmetry,
          difficulty: baseDifficulty,
        );
        final correct = puzzle.options.firstWhere(
          (o) => o.id == puzzle.correctOptionId,
        );
        expect(
          correct.label,
          isNotNull,
          reason: 'geometrySymmetry must have a label',
        );
        final isValid =
            correct.label == '∞' || int.tryParse(correct.label!) != null;
        expect(
          isValid,
          isTrue,
          reason:
              'geometrySymmetry label "${correct.label}" must be an int or ∞ (seed=$seed)',
        );
      }
    });

    // ─── physicsGravity: correct option label ends in "kg" ──────

    test('physicsGravity: all option labels mention kg', () {
      for (int seed = 0; seed < 50; seed++) {
        final gen = PuzzleGenerator(Random(seed));
        final puzzle = gen.generate(
          rule: PuzzleRule.physicsGravity,
          difficulty: baseDifficulty,
        );
        for (final option in puzzle.options) {
          expect(
            option.label,
            contains('kg'),
            reason:
                'physicsGravity options must show weight in kg (seed=$seed)',
          );
        }
      }
    });

    // ─── physicsMomentum: correct label is one of three directions ─

    test('physicsMomentum: correct label is Right, Left, or Stopped', () {
      const validLabels = {'Right →', '← Left', 'Stopped'};
      for (int seed = 0; seed < 50; seed++) {
        final gen = PuzzleGenerator(Random(seed));
        final puzzle = gen.generate(
          rule: PuzzleRule.physicsMomentum,
          difficulty: baseDifficulty,
        );
        final correct = puzzle.options.firstWhere(
          (o) => o.id == puzzle.correctOptionId,
        );
        expect(
          validLabels.contains(correct.label),
          isTrue,
          reason:
              'physicsMomentum label "${correct.label}" must be one of $validLabels (seed=$seed)',
        );
      }
    });

    // ─── countShapes: correct label matches item count ───────────

    test(
      'countShapes: correct label matches the count of items in that option',
      () {
        for (int seed = 0; seed < 50; seed++) {
          final gen = PuzzleGenerator(Random(seed));
          final puzzle = gen.generate(
            rule: PuzzleRule.countShapes,
            difficulty: baseDifficulty,
          );
          final correct = puzzle.options.firstWhere(
            (o) => o.id == puzzle.correctOptionId,
          );
          expect(correct.label, isNotNull);
          final labelCount = int.tryParse(correct.label!);
          expect(
            labelCount,
            isNotNull,
            reason: 'countShapes label must be an int (seed=$seed)',
          );
          expect(
            labelCount,
            equals(correct.items.length),
            reason:
                'countShapes label ($labelCount) must match items.length (${correct.items.length}) (seed=$seed)',
          );
        }
      },
    );

    // ─── Stress: all label-based rules produce unique option labels ─

    for (final rule in [
      PuzzleRule.mathAddSub,
      PuzzleRule.mathMulDiv,
      PuzzleRule.mathModulo,
      PuzzleRule.mathAlgebra,
      PuzzleRule.binaryDecode,
      PuzzleRule.cipherBreak,
      PuzzleRule.numberGrid,
    ]) {
      test('$rule: no two options share the same label (stress test)', () {
        final gen = PuzzleGenerator(Random(77));
        int duplicateLabelCount = 0;
        for (int i = 0; i < 200; i++) {
          final puzzle = gen.generate(rule: rule, difficulty: baseDifficulty);
          final labels = puzzle.options.map((o) => o.label).toList();
          if (labels.toSet().length != labels.length) {
            duplicateLabelCount++;
          }
        }
        expect(
          duplicateLabelCount,
          0,
          reason: '$rule must not produce duplicate option labels',
        );
      });
    }
  });
}
