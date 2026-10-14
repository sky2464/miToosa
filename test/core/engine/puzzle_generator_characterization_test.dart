import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/puzzle_generator.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/core/models/shape_item.dart';

/// BL-38 AC-002 (T-002): seeded generator output is stable across modularization.
final _uuidPattern = RegExp(
  r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
);

String _puzzleFingerprint(Puzzle puzzle) {
  String itemSig(ShapeItem item) => '${item.shape.name}:${item.color.name}';
  final targetSig = puzzle.targetItems.map(itemSig).join(',');
  final optionSig = puzzle.options
      .map((o) => '${o.id}=${o.label ?? o.items.map(itemSig).join('+')}')
      .join(';');
  final raw =
      '${puzzle.rule.name}|${puzzle.prompt}|t:$targetSig|o:$optionSig|c:${puzzle.correctOptionId}';
  return raw.replaceAll(_uuidPattern, '');
}

void main() {
  group('PuzzleGenerator seeded characterization @smoke T-002', () {
    const seed = 4242;
    const difficulty = DifficultyParameters(
      shapeCount: 4,
      colorCount: 3,
      choiceCount: 4,
    );

    final expected = Map<String, String>.from(
      jsonDecode(
            File(
              'test/fixtures/bl38/puzzle_generator_seed_4242.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>,
    );

    final generator = PuzzleGenerator(Random(seed));

    for (final rule in PuzzleRule.values) {
      test('$rule matches seeded fingerprint', () {
        final puzzle = generator.generate(rule: rule, difficulty: difficulty);
        expect(_puzzleFingerprint(puzzle), expected[rule.name]);
      });
    }
  });
}
