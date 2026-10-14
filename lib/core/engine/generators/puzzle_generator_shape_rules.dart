part of '../puzzle_generator.dart';

mixin PuzzleGeneratorShapeRules on PuzzleGeneratorSupport {
  // ─── countShapes (BUG FIXED) ──────────────────────────────

  Puzzle _generateCountShapes(DifficultyParameters difficulty) {
    final palette = _pickColors(difficulty.colorCount);
    final targetShape = randomShape();
    final targetColor = randomColor(palette);

    // FIX: Ensure count >= 1
    final targetCount = random.nextInt(max(1, difficulty.shapeCount - 1)) + 1;

    final targetItems = <ShapeItem>[];
    for (int i = 0; i < targetCount; i++) {
      targetItems.add(ShapeItem(shape: targetShape, color: targetColor));
    }

    // Add noise shapes of different type
    while (targetItems.length < difficulty.shapeCount) {
      Shape noise;
      int tries = 0;
      do {
        noise = randomShape();
        tries++;
      } while (noise == targetShape && tries < 20);
      targetItems.add(ShapeItem(shape: noise, color: randomColor(palette)));
    }
    targetItems.shuffle(random);

    final correctOptionId = _uuid();
    // Correct option shows the count as that many items of the shape
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: List.generate(
        targetCount,
        (_) => ShapeItem(shape: targetShape, color: targetColor),
      ),
      label: '$targetCount',
    );

    final wrongOptions = <PuzzleOption>[];
    final usedCounts = {targetCount};

    // FIX: Bail-out counter + ensure fakeCount >= 1
    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final fakeCount =
          random.nextInt(difficulty.shapeCount) + 1; // FIX: +1 ensures >= 1
      if (!usedCounts.contains(fakeCount)) {
        usedCounts.add(fakeCount);
        wrongOptions.add(
          PuzzleOption(
            id: _uuid(),
            items: List.generate(
              fakeCount,
              (_) => ShapeItem(shape: targetShape, color: targetColor),
            ),
            label: '$fakeCount',
          ),
        );
      }
    }

    // If we couldn't generate enough unique counts, fill remaining with nearby counts
    while (wrongOptions.length < difficulty.choiceCount - 1) {
      int fakeCount = wrongOptions.length + targetCount + 2;
      wrongOptions.add(
        PuzzleOption(
          id: _uuid(),
          items: List.generate(
            fakeCount.clamp(1, 12),
            (_) => ShapeItem(shape: targetShape, color: targetColor),
          ),
          label: '${fakeCount.clamp(1, 12)}',
        ),
      );
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    return Puzzle(
      id: _uuid(),
      prompt: 'Count the ${_shapeName(targetShape)}s',
      rule: PuzzleRule.countShapes,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── oddOneOut (BUG FIXED) ────────────────────────────────

  Puzzle _generateOddOneOut(DifficultyParameters difficulty) {
    final palette = _pickColors(difficulty.colorCount);
    final commonColor = randomColor(palette);
    final commonShape = randomShape();

    Shape oddShape;
    int tries = 0;
    do {
      oddShape = randomShape();
      tries++;
    } while (oddShape == commonShape && tries < 30);

    final oddColor = commonColor; // Same color — odd by SHAPE

    final targetItems = List.generate(
      difficulty.shapeCount,
      (_) => ShapeItem(shape: commonShape, color: commonColor),
    );
    final oddIndex = random.nextInt(difficulty.shapeCount);
    targetItems[oddIndex] = ShapeItem(shape: oddShape, color: oddColor);

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: [ShapeItem(shape: oddShape, color: oddColor)],
    );

    final wrongOptions = <PuzzleOption>[
      PuzzleOption(
        id: _uuid(),
        items: [ShapeItem(shape: commonShape, color: commonColor)],
      ),
    ];

    // FIX: Add bail-out and allow repeated noise if needed
    final usedShapes = {commonShape, oddShape};
    int noiseBailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 &&
        noiseBailout < 100) {
      noiseBailout++;
      Shape noise = randomShape();
      if (!usedShapes.contains(noise)) {
        usedShapes.add(noise);
        wrongOptions.add(
          PuzzleOption(
            id: _uuid(),
            items: [ShapeItem(shape: noise, color: randomColor(palette))],
          ),
        );
      } else if (noiseBailout > 30) {
        // Fallback: allow any shape with a different color
        wrongOptions.add(
          PuzzleOption(
            id: _uuid(),
            items: [ShapeItem(shape: noise, color: randomColor(palette))],
          ),
        );
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    return Puzzle(
      id: _uuid(),
      prompt: 'Pick the odd one out',
      rule: PuzzleRule.oddOneOut,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── colorPattern (NEW) ───────────────────────────────────

  Puzzle _generateColorPattern(DifficultyParameters difficulty) {
    final palette = _pickColors(max(3, difficulty.colorCount));
    final shape = randomShape(); // Same shape, different colors

    final targetItems = List.generate(
      difficulty.shapeCount,
      (_) => ShapeItem(shape: shape, color: randomColor(palette)),
    );

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: List.from(targetItems),
    );

    var wrongOptions = <PuzzleOption>[];
    for (int i = 0; i < difficulty.choiceCount - 1; i++) {
      final mutated = List<ShapeItem>.from(targetItems);
      final idx = random.nextInt(mutated.length);
      ShapeColor newColor;
      int tries = 0;
      do {
        newColor = randomColor(palette);
        tries++;
      } while (newColor == targetItems[idx].color && tries < 20);
      mutated[idx] = targetItems[idx].copyWith(color: newColor);
      wrongOptions.add(PuzzleOption(id: _uuid(), items: mutated));
    }

    wrongOptions = _deduplicateOptions(correctOption, wrongOptions, () {
      final mutated = List<ShapeItem>.from(targetItems);
      final idx = random.nextInt(mutated.length);
      mutated[idx] = targetItems[idx].copyWith(color: randomColor(palette));
      return [PuzzleOption(id: _uuid(), items: mutated)];
    });

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    return Puzzle(
      id: _uuid(),
      prompt: 'Find the matching color pattern',
      rule: PuzzleRule.colorPattern,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── findMissing (NEW) ────────────────────────────────────

  Puzzle _generateFindMissing(DifficultyParameters difficulty) {
    final palette = _pickColors(difficulty.colorCount);

    // Build a repeating pattern (same approach as sequenceNext) so the
    // "gap" is always inferable from a repeated value still visible
    // elsewhere in the sequence, rather than a value only the generator
    // knows.
    final patternLen = 2 + random.nextInt(2); // 2 or 3
    final pattern = List.generate(
      patternLen,
      (_) => randomItem(palette: palette),
    );

    // At least 2 full cycles so every pattern slot repeats at least once
    // even after one occurrence is hidden as the gap.
    final cycles = max(2, (difficulty.shapeCount / patternLen).ceil());
    final fullSequence = List.generate(
      patternLen * cycles,
      (i) => pattern[i % patternLen],
    );

    final missingIndex = random.nextInt(fullSequence.length);
    final missingItem = fullSequence[missingIndex];

    // Target shows the sequence with a "gap" represented by a placeholder
    final targetItems = List<ShapeItem>.from(fullSequence);
    targetItems[missingIndex] = const ShapeItem(
      shape: Shape.diamond,
      color: ShapeColor.yellow,
      fill: ShapeFill.outlined,
    ); // Visual placeholder for "?"

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: [missingItem],
    );

    // Keep distractors visually distinct from every pattern value, not
    // just the missing one, so nothing on screen hints at a second
    // plausible answer.
    ShapeItem randomDistractorItem() {
      ShapeItem candidate;
      int tries = 0;
      do {
        candidate = randomItem(palette: palette);
        tries++;
      } while (pattern.contains(candidate) && tries < 20);
      return candidate;
    }

    var wrongOptions = <PuzzleOption>[];
    for (int i = 0; i < difficulty.choiceCount - 1; i++) {
      wrongOptions.add(
        PuzzleOption(id: _uuid(), items: [randomDistractorItem()]),
      );
    }

    wrongOptions = _deduplicateOptions(
      correctOption,
      wrongOptions,
      () => [
        PuzzleOption(id: _uuid(), items: [randomDistractorItem()]),
      ],
    );

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    return Puzzle(
      id: _uuid(),
      prompt: 'What fills the gap?',
      rule: PuzzleRule.findMissing,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── sequenceNext (NEW) ───────────────────────────────────

  Puzzle _generateSequenceNext(DifficultyParameters difficulty) {
    final palette = _pickColors(difficulty.colorCount);

    // Create a repeating pattern of length 2-3 and show 4-6 items
    final patternLen = 2 + random.nextInt(2); // 2 or 3
    final pattern = List.generate(
      patternLen,
      (_) => randomItem(palette: palette),
    );

    final seqLen = difficulty.shapeCount + 1;
    final fullSequence = List.generate(seqLen, (i) => pattern[i % patternLen]);

    // The "next" item is the last one; show everything except last
    final targetItems = fullSequence.sublist(0, fullSequence.length - 1);
    final nextItem = fullSequence.last;

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(id: correctOptionId, items: [nextItem]);

    var wrongOptions = <PuzzleOption>[];
    for (int i = 0; i < difficulty.choiceCount - 1; i++) {
      wrongOptions.add(
        PuzzleOption(
          id: _uuid(),
          items: [randomItem(palette: palette)],
        ),
      );
    }

    wrongOptions = _deduplicateOptions(
      correctOption,
      wrongOptions,
      () => [
        PuzzleOption(
          id: _uuid(),
          items: [randomItem(palette: palette)],
        ),
      ],
    );

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    return Puzzle(
      id: _uuid(),
      prompt: 'What comes next?',
      rule: PuzzleRule.sequenceNext,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }
}
