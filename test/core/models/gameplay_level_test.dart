import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/models/gameplay_level.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/core/models/shape_item.dart';

GameplayLevel _level({required int perfectScore, double multiplier = 1.0}) {
  return GameplayLevel(
    title: 'Test',
    successMessage: 'Good',
    retryMessage: 'Retry',
    perfectScore: perfectScore,
    difficultyMultiplier: multiplier,
    puzzle: const Puzzle(
      id: 'test',
      prompt: 'Match',
      rule: PuzzleRule.matchIdentical,
      targetItems: [ShapeItem(shape: Shape.circle)],
      options: [
        PuzzleOption(
          id: 'c',
          items: [ShapeItem(shape: Shape.circle)],
        ),
        PuzzleOption(
          id: 'w',
          items: [ShapeItem(shape: Shape.square)],
        ),
      ],
      correctOptionId: 'c',
    ),
  );
}

void main() {
  group('GameplayLevel — score() with difficultyMultiplier', () {
    test('multiplier=1.0, 0 incorrect → perfectScore', () {
      expect(_level(perfectScore: 100).score(0), 100);
    });

    test('multiplier=1.5, 0 incorrect → 150 (scaled up)', () {
      expect(_level(perfectScore: 100, multiplier: 1.5).score(0), 150);
    });

    test('multiplier=0.75, 0 incorrect → 75 (scaled down)', () {
      expect(_level(perfectScore: 100, multiplier: 0.75).score(0), 75);
    });

    test(
      'penalty deducted from scaled score (multiplier=1.5, 2 incorrect → 110)',
      () {
        expect(_level(perfectScore: 100, multiplier: 1.5).score(2), 110);
      },
    );

    test('score never goes below 10 even with large incorrect count', () {
      expect(_level(perfectScore: 100).score(50), 10);
    });

    test('score never goes below 10 with multiplier < 1 and heavy penalty', () {
      expect(_level(perfectScore: 100, multiplier: 0.75).score(100), 10);
    });

    test('penalty exactly equals scaled score → returns 10 (not 0)', () {
      // scaled = 100, penalty = 5 * 20 = 100 → 100 - 100 = 0 → floor at 10
      expect(_level(perfectScore: 100).score(5), 10);
    });

    // ── Bug regression: clamp(10, scaled) throws when scaled < 10 ──────────
    test('perfectScore=12 multiplier=0.75 (scaled=9) never throws', () {
      // scaled = (12 * 0.75).round() = 9 — previously threw ArgumentError
      expect(
        () => _level(perfectScore: 12, multiplier: 0.75).score(0),
        returnsNormally,
      );
    });

    test(
      'perfectScore=12 multiplier=0.75 floors to scaled value (9), not 10',
      () {
        // scaled = (12 * 0.75).round() = 9 — floor is scaled itself, not 10
        expect(_level(perfectScore: 12, multiplier: 0.75).score(0), 9);
      },
    );
  });
}
