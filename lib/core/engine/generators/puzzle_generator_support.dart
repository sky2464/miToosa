part of '../puzzle_generator.dart';

mixin PuzzleGeneratorSupport on PuzzleGeneratorBase {
  // ─── Helpers ───────────────────────────────────────────────

  String _uuid() => const Uuid().v4();

  List<ShapeColor> _pickColors(int count) {
    final colors = List<ShapeColor>.from(ShapeColor.values)..shuffle(random);
    return colors.take(min(count, colors.length)).toList();
  }

  Shape randomShape() => Shape.values[random.nextInt(Shape.values.length)];

  ShapeColor randomColor([List<ShapeColor>? palette]) {
    final source = palette ?? ShapeColor.values;
    return source[random.nextInt(source.length)];
  }

  ShapeItem randomItem({
    List<ShapeColor>? palette,
    ShapeFill fill = ShapeFill.filled,
  }) {
    return ShapeItem(
      shape: randomShape(),
      color: randomColor(palette),
      fill: fill,
    );
  }

  /// Ensure no two options are visually identical. Regenerate duplicates.
  List<PuzzleOption> _deduplicateOptions(
    PuzzleOption correct,
    List<PuzzleOption> wrongOptions,
    List<PuzzleOption> Function() regenerateOne,
  ) {
    final maxAttempts = 50;
    final result = <PuzzleOption>[...wrongOptions];

    for (int i = 0; i < result.length; i++) {
      int attempts = 0;
      while (attempts < maxAttempts &&
          (result[i].visuallyEquals(correct) ||
              result.take(i).any((prev) => prev.visuallyEquals(result[i])))) {
        final replacements = regenerateOne();
        if (replacements.isNotEmpty) {
          result[i] = replacements[0];
        }
        attempts++;
      }
    }

    return result;
  }

  // ─── matchIdentical (BUG FIXED) ──────────────────────────

  Puzzle _generateMatchIdentical(DifficultyParameters difficulty) {
    final palette = _pickColors(difficulty.colorCount);
    final targetItems = List.generate(
      difficulty.shapeCount,
      (_) => randomItem(palette: palette),
    );

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(id: correctOptionId, items: targetItems);

    var wrongOptions = <PuzzleOption>[];
    for (int i = 0; i < difficulty.choiceCount - 1; i++) {
      wrongOptions.add(_mutateOption(targetItems, palette));
    }

    // FIX: Ensure no wrong option is visually identical to correct or each other
    wrongOptions = _deduplicateOptions(
      correctOption,
      wrongOptions,
      () => [_mutateOption(targetItems, palette)],
    );

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    return Puzzle(
      id: _uuid(),
      prompt: 'Find the identical match',
      rule: PuzzleRule.matchIdentical,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  PuzzleOption _mutateOption(List<ShapeItem> target, List<ShapeColor> palette) {
    final mutated = List<ShapeItem>.from(target);
    // Mutate 1-2 elements for variety
    final mutationCount = 1 + random.nextInt(min(2, target.length));
    final indicesToMutate = <int>{};
    while (indicesToMutate.length < mutationCount) {
      indicesToMutate.add(random.nextInt(target.length));
    }

    for (final idx in indicesToMutate) {
      // Decide whether to mutate shape, color, or both
      final mutationType = random.nextInt(3);
      Shape newShape = target[idx].shape;
      ShapeColor newColor = target[idx].color;

      if (mutationType == 0 || mutationType == 2) {
        // Mutate shape
        int tries = 0;
        do {
          newShape = randomShape();
          tries++;
        } while (newShape == target[idx].shape && tries < 20);
      }
      if (mutationType == 1 || mutationType == 2) {
        // Mutate color
        int tries = 0;
        do {
          newColor = randomColor(palette);
          tries++;
        } while (newColor == target[idx].color && tries < 20);
      }

      mutated[idx] = ShapeItem(
        shape: newShape,
        color: newColor,
        fill: target[idx].fill,
      );
    }

    return PuzzleOption(id: _uuid(), items: mutated);
  }

  Puzzle _buildMathPuzzle({
    required String prompt,
    required int answer,
    required DifficultyParameters difficulty,
    required PuzzleRule rule,
    bool allowZero = false,
    List<ShapeItem>? targetOverride,
  }) {
    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: const [],
      label: '$answer',
    );

    final wrongOptions = <PuzzleOption>[];
    final usedAnswers = {answer};

    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final offset = random.nextInt(7) - 3;
      int fake = answer + offset;
      if (!allowZero && fake <= 0) fake = random.nextInt(answer + 5) + 1;
      if (fake < 0) fake = fake.abs();
      if (!usedAnswers.contains(fake)) {
        usedAnswers.add(fake);
        wrongOptions.add(
          PuzzleOption(id: _uuid(), items: const [], label: '$fake'),
        );
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    return Puzzle(
      id: _uuid(),
      prompt: prompt,
      rule: rule,
      targetItems: targetOverride ?? const [],
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  String _shapeName(Shape s) {
    return s.toString().split('.').last;
  }
}
