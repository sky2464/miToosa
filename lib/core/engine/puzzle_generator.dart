import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/puzzle.dart';
import '../models/shape_item.dart';

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

class PuzzleGenerator {
  final Random _random;

  PuzzleGenerator([Random? random]) : _random = random ?? Random.secure();

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

  // ─── Helpers ───────────────────────────────────────────────

  String _uuid() => const Uuid().v4();

  List<ShapeColor> _pickColors(int count) {
    final colors = List<ShapeColor>.from(ShapeColor.values)..shuffle(_random);
    return colors.take(min(count, colors.length)).toList();
  }

  Shape _randomShape() => Shape.values[_random.nextInt(Shape.values.length)];

  ShapeColor _randomColor([List<ShapeColor>? palette]) {
    final source = palette ?? ShapeColor.values;
    return source[_random.nextInt(source.length)];
  }

  ShapeItem _randomItem({List<ShapeColor>? palette, ShapeFill fill = ShapeFill.filled}) {
    return ShapeItem(
      shape: _randomShape(),
      color: _randomColor(palette),
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
      (_) => _randomItem(palette: palette),
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

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

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
    final mutationCount = 1 + _random.nextInt(min(2, target.length));
    final indicesToMutate = <int>{};
    while (indicesToMutate.length < mutationCount) {
      indicesToMutate.add(_random.nextInt(target.length));
    }

    for (final idx in indicesToMutate) {
      // Decide whether to mutate shape, color, or both
      final mutationType = _random.nextInt(3);
      Shape newShape = target[idx].shape;
      ShapeColor newColor = target[idx].color;

      if (mutationType == 0 || mutationType == 2) {
        // Mutate shape
        int tries = 0;
        do {
          newShape = _randomShape();
          tries++;
        } while (newShape == target[idx].shape && tries < 20);
      }
      if (mutationType == 1 || mutationType == 2) {
        // Mutate color
        int tries = 0;
        do {
          newColor = _randomColor(palette);
          tries++;
        } while (newColor == target[idx].color && tries < 20);
      }

      mutated[idx] = ShapeItem(shape: newShape, color: newColor, fill: target[idx].fill);
    }

    return PuzzleOption(id: _uuid(), items: mutated);
  }

  // ─── countShapes (BUG FIXED) ──────────────────────────────

  Puzzle _generateCountShapes(DifficultyParameters difficulty) {
    final palette = _pickColors(difficulty.colorCount);
    final targetShape = _randomShape();
    final targetColor = _randomColor(palette);

    // FIX: Ensure count >= 1
    final targetCount = _random.nextInt(max(1, difficulty.shapeCount - 1)) + 1;

    final targetItems = <ShapeItem>[];
    for (int i = 0; i < targetCount; i++) {
      targetItems.add(ShapeItem(shape: targetShape, color: targetColor));
    }

    // Add noise shapes of different type
    while (targetItems.length < difficulty.shapeCount) {
      Shape noise;
      int tries = 0;
      do {
        noise = _randomShape();
        tries++;
      } while (noise == targetShape && tries < 20);
      targetItems.add(ShapeItem(shape: noise, color: _randomColor(palette)));
    }
    targetItems.shuffle(_random);

    final correctOptionId = _uuid();
    // Correct option shows the count as that many items of the shape
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: List.generate(targetCount, (_) => ShapeItem(shape: targetShape, color: targetColor)),
      label: '$targetCount',
    );

    final wrongOptions = <PuzzleOption>[];
    final usedCounts = {targetCount};

    // FIX: Bail-out counter + ensure fakeCount >= 1
    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final fakeCount = _random.nextInt(difficulty.shapeCount) + 1; // FIX: +1 ensures >= 1
      if (!usedCounts.contains(fakeCount)) {
        usedCounts.add(fakeCount);
        wrongOptions.add(PuzzleOption(
          id: _uuid(),
          items: List.generate(fakeCount, (_) => ShapeItem(shape: targetShape, color: targetColor)),
          label: '$fakeCount',
        ));
      }
    }

    // If we couldn't generate enough unique counts, fill remaining with nearby counts
    while (wrongOptions.length < difficulty.choiceCount - 1) {
      int fakeCount = wrongOptions.length + targetCount + 2;
      wrongOptions.add(PuzzleOption(
        id: _uuid(),
        items: List.generate(fakeCount.clamp(1, 12), (_) => ShapeItem(shape: targetShape, color: targetColor)),
        label: '${fakeCount.clamp(1, 12)}',
      ));
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

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
    final commonColor = _randomColor(palette);
    final commonShape = _randomShape();

    Shape oddShape;
    int tries = 0;
    do {
      oddShape = _randomShape();
      tries++;
    } while (oddShape == commonShape && tries < 30);

    final oddColor = commonColor; // Same color — odd by SHAPE

    final targetItems = List.generate(
      difficulty.shapeCount,
      (_) => ShapeItem(shape: commonShape, color: commonColor),
    );
    final oddIndex = _random.nextInt(difficulty.shapeCount);
    targetItems[oddIndex] = ShapeItem(shape: oddShape, color: oddColor);

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: [ShapeItem(shape: oddShape, color: oddColor)],
    );

    final wrongOptions = <PuzzleOption>[
      PuzzleOption(id: _uuid(), items: [ShapeItem(shape: commonShape, color: commonColor)])
    ];

    // FIX: Add bail-out and allow repeated noise if needed
    final usedShapes = {commonShape, oddShape};
    int noiseBailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && noiseBailout < 100) {
      noiseBailout++;
      Shape noise = _randomShape();
      if (!usedShapes.contains(noise)) {
        usedShapes.add(noise);
        wrongOptions.add(PuzzleOption(
          id: _uuid(),
          items: [ShapeItem(shape: noise, color: _randomColor(palette))],
        ));
      } else if (noiseBailout > 30) {
        // Fallback: allow any shape with a different color
        wrongOptions.add(PuzzleOption(
          id: _uuid(),
          items: [ShapeItem(shape: noise, color: _randomColor(palette))],
        ));
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

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
    final shape = _randomShape(); // Same shape, different colors

    final targetItems = List.generate(
      difficulty.shapeCount,
      (_) => ShapeItem(shape: shape, color: _randomColor(palette)),
    );

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(id: correctOptionId, items: List.from(targetItems));

    var wrongOptions = <PuzzleOption>[];
    for (int i = 0; i < difficulty.choiceCount - 1; i++) {
      final mutated = List<ShapeItem>.from(targetItems);
      final idx = _random.nextInt(mutated.length);
      ShapeColor newColor;
      int tries = 0;
      do {
        newColor = _randomColor(palette);
        tries++;
      } while (newColor == targetItems[idx].color && tries < 20);
      mutated[idx] = targetItems[idx].copyWith(color: newColor);
      wrongOptions.add(PuzzleOption(id: _uuid(), items: mutated));
    }

    wrongOptions = _deduplicateOptions(
      correctOption,
      wrongOptions,
      () {
        final mutated = List<ShapeItem>.from(targetItems);
        final idx = _random.nextInt(mutated.length);
        mutated[idx] = targetItems[idx].copyWith(color: _randomColor(palette));
        return [PuzzleOption(id: _uuid(), items: mutated)];
      },
    );

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

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

    // Create a full sequence, then remove one element
    final fullSequence = List.generate(
      difficulty.shapeCount,
      (_) => _randomItem(palette: palette),
    );

    final missingIndex = _random.nextInt(fullSequence.length);
    final missingItem = fullSequence[missingIndex];

    // Target shows the sequence with a "gap" represented by a placeholder
    final targetItems = List<ShapeItem>.from(fullSequence);
    targetItems[missingIndex] = const ShapeItem(
      shape: Shape.diamond,
      color: ShapeColor.yellow,
      fill: ShapeFill.outlined,
    ); // Visual placeholder for "?"

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(id: correctOptionId, items: [missingItem]);

    var wrongOptions = <PuzzleOption>[];
    for (int i = 0; i < difficulty.choiceCount - 1; i++) {
      wrongOptions.add(PuzzleOption(id: _uuid(), items: [_randomItem(palette: palette)]));
    }

    wrongOptions = _deduplicateOptions(
      correctOption,
      wrongOptions,
      () => [PuzzleOption(id: _uuid(), items: [_randomItem(palette: palette)])],
    );

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

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
    final patternLen = 2 + _random.nextInt(2); // 2 or 3
    final pattern = List.generate(patternLen, (_) => _randomItem(palette: palette));

    final seqLen = difficulty.shapeCount + 1;
    final fullSequence = List.generate(seqLen, (i) => pattern[i % patternLen]);

    // The "next" item is the last one; show everything except last
    final targetItems = fullSequence.sublist(0, fullSequence.length - 1);
    final nextItem = fullSequence.last;

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(id: correctOptionId, items: [nextItem]);

    var wrongOptions = <PuzzleOption>[];
    for (int i = 0; i < difficulty.choiceCount - 1; i++) {
      wrongOptions.add(PuzzleOption(id: _uuid(), items: [_randomItem(palette: palette)]));
    }

    wrongOptions = _deduplicateOptions(
      correctOption,
      wrongOptions,
      () => [PuzzleOption(id: _uuid(), items: [_randomItem(palette: palette)])],
    );

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

    return Puzzle(
      id: _uuid(),
      prompt: 'What comes next?',
      rule: PuzzleRule.sequenceNext,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── binaryDecode (NEW) ───────────────────────────────────

  Puzzle _generateBinaryDecode(DifficultyParameters difficulty) {
    // Show filled/outlined circles as binary (filled=1, outlined=0)
    final bitCount = min(difficulty.shapeCount, 6).clamp(3, 6);
    final targetValue = _random.nextInt(pow(2, bitCount).toInt() - 1) + 1;

    final targetItems = <ShapeItem>[];
    for (int bit = bitCount - 1; bit >= 0; bit--) {
      final isOne = (targetValue >> bit) & 1 == 1;
      targetItems.add(ShapeItem(
        shape: Shape.circle,
        color: isOne ? ShapeColor.teal : ShapeColor.red,
        fill: isOne ? ShapeFill.filled : ShapeFill.outlined,
      ));
    }

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: targetItems,
      label: '$targetValue',
    );

    final wrongOptions = <PuzzleOption>[];
    final usedValues = {targetValue};

    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final fakeValue = _random.nextInt(pow(2, bitCount).toInt() - 1) + 1;
      if (!usedValues.contains(fakeValue)) {
        usedValues.add(fakeValue);
        wrongOptions.add(PuzzleOption(
          id: _uuid(),
          items: targetItems,
          label: '$fakeValue',
        ));
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

    return Puzzle(
      id: _uuid(),
      prompt: 'Decode the binary (●=1, ○=0)',
      rule: PuzzleRule.binaryDecode,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── logicGate (NEW) ──────────────────────────────────────

  Puzzle _generateLogicGate(DifficultyParameters difficulty) {
    final gates = ['AND', 'OR', 'XOR'];
    final gate = gates[_random.nextInt(gates.length)];

    final a = _random.nextBool();
    final b = _random.nextBool();

    bool result;
    switch (gate) {
      case 'AND':
        result = a && b;
        break;
      case 'OR':
        result = a || b;
        break;
      case 'XOR':
        result = a ^ b;
        break;
      default:
        result = a && b;
    }

    // Visual: filled circle = TRUE, outlined circle = FALSE
    final targetItems = [
      ShapeItem(shape: Shape.circle, color: a ? ShapeColor.green : ShapeColor.red, fill: a ? ShapeFill.filled : ShapeFill.outlined),
      const ShapeItem(shape: Shape.star, color: ShapeColor.yellow, fill: ShapeFill.filled), // represents the gate
      ShapeItem(shape: Shape.circle, color: b ? ShapeColor.green : ShapeColor.red, fill: b ? ShapeFill.filled : ShapeFill.outlined),
    ];

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: [ShapeItem(
        shape: Shape.circle,
        color: result ? ShapeColor.green : ShapeColor.red,
        fill: result ? ShapeFill.filled : ShapeFill.outlined,
      )],
      label: result ? 'TRUE' : 'FALSE',
    );

    final wrongOption = PuzzleOption(
      id: _uuid(),
      items: [ShapeItem(
        shape: Shape.circle,
        color: !result ? ShapeColor.green : ShapeColor.red,
        fill: !result ? ShapeFill.filled : ShapeFill.outlined,
      )],
      label: !result ? 'TRUE' : 'FALSE',
    );

    final allOptions = [correctOption, wrongOption]..shuffle(_random);

    return Puzzle(
      id: _uuid(),
      prompt: '$gate gate: what is the output?',
      rule: PuzzleRule.logicGate,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── cipherBreak (NEW) ────────────────────────────────────

  Puzzle _generateCipherBreak(DifficultyParameters difficulty) {
    // Simple substitution: each shape maps to a letter, decode the "word"
    final letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    final shapes = List<Shape>.from(Shape.values)..shuffle(_random);
    final palette = _pickColors(difficulty.colorCount);

    final wordLen = min(difficulty.shapeCount, 4).clamp(2, 4);
    final cipherMap = <Shape, String>{};
    for (int i = 0; i < shapes.length && i < letters.length; i++) {
      cipherMap[shapes[i]] = letters[i];
    }

    // Build the "encoded word" as shapes
    final wordShapes = <Shape>[];
    for (int i = 0; i < wordLen; i++) {
      wordShapes.add(shapes[_random.nextInt(min(3, shapes.length))]);
    }

    final decodedWord = wordShapes.map((s) => cipherMap[s] ?? '?').join('');

    final targetItems = wordShapes
        .map((s) => ShapeItem(shape: s, color: _randomColor(palette)))
        .toList();

    // Show the cipher key as additional target items (use the first 3 mappings)
    final keyItems = <ShapeItem>[];
    for (int i = 0; i < min(3, shapes.length); i++) {
      keyItems.add(ShapeItem(shape: shapes[i], color: palette[i % palette.length]));
    }

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: targetItems,
      label: decodedWord,
    );

    final wrongOptions = <PuzzleOption>[];
    final usedWords = {decodedWord};

    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final fakeWord = List.generate(wordLen, (_) => letters[_random.nextInt(min(3, letters.length))]).join('');
      if (!usedWords.contains(fakeWord)) {
        usedWords.add(fakeWord);
        wrongOptions.add(PuzzleOption(
          id: _uuid(),
          items: targetItems,
          label: fakeWord,
        ));
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

    // Combine key + encoded word for display
    final displayItems = [...keyItems, ...targetItems];

    return Puzzle(
      id: _uuid(),
      prompt: 'Decode: ${cipherMap.entries.take(3).map((e) => '${_shapeName(e.key)}=${e.value}').join(', ')}',
      rule: PuzzleRule.cipherBreak,
      targetItems: displayItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── balanceEquation (NEW) ────────────────────────────────

  Puzzle _generateBalanceEquation(DifficultyParameters difficulty) {
    final palette = _pickColors(difficulty.colorCount);

    // Generate a simple equation: a + b = ?
    final a = _random.nextInt(5) + 1;
    final b = _random.nextInt(5) + 1;
    final answer = a + b;

    // Represent numbers as groups of shapes
    final shapeA = _randomShape();
    final shapeB = _randomShape();
    final colorA = _randomColor(palette);
    final colorB = _randomColor(palette);

    final leftSide = <ShapeItem>[
      ...List.generate(a, (_) => ShapeItem(shape: shapeA, color: colorA)),
      // Plus sign represented by a star
      const ShapeItem(shape: Shape.star, color: ShapeColor.yellow, fill: ShapeFill.outlined),
      ...List.generate(b, (_) => ShapeItem(shape: shapeB, color: colorB)),
    ];

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: List.generate(answer, (_) => const ShapeItem(shape: Shape.circle, color: ShapeColor.green)),
      label: '$answer',
    );

    final wrongOptions = <PuzzleOption>[];
    final usedAnswers = {answer};

    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final fakeAnswer = _random.nextInt(12) + 1;
      if (!usedAnswers.contains(fakeAnswer)) {
        usedAnswers.add(fakeAnswer);
        wrongOptions.add(PuzzleOption(
          id: _uuid(),
          items: List.generate(fakeAnswer.clamp(1, 12), (_) => const ShapeItem(shape: Shape.circle, color: ShapeColor.green)),
          label: '$fakeAnswer',
        ));
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

    return Puzzle(
      id: _uuid(),
      prompt: 'How many in total?',
      rule: PuzzleRule.balanceEquation,
      targetItems: leftSide,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ════════════════════════════════════════════════════════════
  // ═══ MATH PUZZLES ══════════════════════════════════════════
  // ════════════════════════════════════════════════════════════

  // ─── mathAddSub: Addition & Subtraction ───────────────────

  Puzzle _generateMathAddSub(DifficultyParameters difficulty) {
    // Scale difficulty: early = small numbers & addition, later = larger & subtraction
    final maxNum = 5 + difficulty.shapeCount * 3;
    final useSubtraction = _random.nextBool() && difficulty.shapeCount > 3;

    int a, b, answer;
    String op;
    if (useSubtraction) {
      a = _random.nextInt(maxNum) + difficulty.shapeCount;
      b = _random.nextInt(a) + 1; // Ensure positive result
      answer = a - b;
      op = '−';
    } else {
      a = _random.nextInt(maxNum) + 1;
      b = _random.nextInt(maxNum) + 1;
      answer = a + b;
      op = '+';
    }

    return _buildMathPuzzle(
      prompt: 'What is $a $op $b ?',
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.mathAddSub,
    );
  }

  // ─── mathMulDiv: Multiplication & Division ────────────────

  Puzzle _generateMathMulDiv(DifficultyParameters difficulty) {
    final tier = (difficulty.shapeCount / 3).floor().clamp(1, 4);
    final useDivision = _random.nextBool() && difficulty.shapeCount > 4;

    int a, b, answer;
    String op;
    if (useDivision) {
      // Generate clean division (no remainder)
      b = _random.nextInt(tier * 3) + 2;
      answer = _random.nextInt(tier * 3) + 1;
      a = b * answer;
      op = '÷';
    } else {
      a = _random.nextInt(tier * 3) + 1;
      b = _random.nextInt(tier * 3) + 1;
      answer = a * b;
      op = '×';
    }

    return _buildMathPuzzle(
      prompt: 'What is $a $op $b ?',
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.mathMulDiv,
    );
  }

  // ─── mathExponent: Powers & Square Roots ──────────────────

  Puzzle _generateMathExponent(DifficultyParameters difficulty) {
    final useRoot = _random.nextBool() && difficulty.shapeCount > 4;

    int answer;
    String prompt;
    if (useRoot) {
      // Perfect squares
      final roots = [2, 3, 4, 5, 6, 7, 8, 9];
      answer = roots[_random.nextInt(min(difficulty.shapeCount, roots.length))];
      final squared = answer * answer;
      prompt = 'What is √$squared ?';
    } else {
      final base = _random.nextInt(5) + 2;
      final exp = 2 + (_random.nextInt(2) * (difficulty.shapeCount > 5 ? 1 : 0));
      answer = pow(base, exp).toInt();
      prompt = 'What is $base${_superscript(exp)} ?';
    }

    return _buildMathPuzzle(
      prompt: prompt,
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.mathExponent,
    );
  }

  String _superscript(int n) {
    const superscripts = {'0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴',
      '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'};
    return n.toString().split('').map((c) => superscripts[c] ?? c).join();
  }

  // ─── mathModulo: Remainder ────────────────────────────────

  Puzzle _generateMathModulo(DifficultyParameters difficulty) {
    final maxA = 10 + difficulty.shapeCount * 5;
    final a = _random.nextInt(maxA) + difficulty.shapeCount + 2;
    final b = _random.nextInt(5) + 2;
    final answer = a % b;

    return _buildMathPuzzle(
      prompt: 'What is $a mod $b ?',
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.mathModulo,
      allowZero: true,
    );
  }

  // ─── mathFraction: Fraction Equivalence ───────────────────

  Puzzle _generateMathFraction(DifficultyParameters difficulty) {
    // Generate a fraction and ask to find the equivalent
    final denominators = [2, 3, 4, 5, 6, 8, 10];
    final d = denominators[_random.nextInt(min(difficulty.shapeCount, denominators.length))];
    final n = _random.nextInt(d - 1) + 1;

    // Find the GCD
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    final g = gcd(n, d);
    final simplifiedNum = n ~/ g;
    final simplifiedDen = d ~/ g;

    // The correct answer label is the simplified fraction
    final correctLabel = '$simplifiedNum/$simplifiedDen';
    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: const [],
      label: correctLabel,
    );

    // Generate wrong fractions
    final wrongOptions = <PuzzleOption>[];
    final usedLabels = {correctLabel};
    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final wn = _random.nextInt(d) + 1;
      final wd = denominators[_random.nextInt(denominators.length)];
      final wg = gcd(wn, wd);
      final label = '${wn ~/ wg}/${wd ~/ wg}';
      if (!usedLabels.contains(label)) {
        usedLabels.add(label);
        wrongOptions.add(PuzzleOption(id: _uuid(), items: const [], label: label));
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

    // Visual: show n filled circles out of d total circles
    final targetItems = List.generate(d, (i) => ShapeItem(
      shape: Shape.circle,
      color: i < n ? ShapeColor.teal : ShapeColor.red,
      fill: i < n ? ShapeFill.filled : ShapeFill.outlined,
    ));

    return Puzzle(
      id: _uuid(),
      prompt: 'Simplify $n/$d',
      rule: PuzzleRule.mathFraction,
      targetItems: targetItems,
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── mathAlgebra: Solve for X ─────────────────────────────

  Puzzle _generateMathAlgebra(DifficultyParameters difficulty) {
    // x + b = c  or  a*x = c
    final useMultiplication = _random.nextBool() && difficulty.shapeCount > 4;

    int answer;
    String prompt;
    if (useMultiplication) {
      final a = _random.nextInt(5) + 2;
      answer = _random.nextInt(8) + 1;
      final c = a * answer;
      prompt = 'Solve: ${a}x = $c';
    } else {
      final b = _random.nextInt(10 + difficulty.shapeCount) + 1;
      answer = _random.nextInt(10 + difficulty.shapeCount) + 1;
      final c = answer + b;
      prompt = 'Solve: x + $b = $c';
    }

    return _buildMathPuzzle(
      prompt: prompt,
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.mathAlgebra,
    );
  }

  // ════════════════════════════════════════════════════════════
  // ═══ GEOMETRY PUZZLES ═════════════════════════════════════
  // ════════════════════════════════════════════════════════════

  // ─── geometryArea: Calculate Area ─────────────────────────

  Puzzle _generateGeometryArea(DifficultyParameters difficulty) {
    final shapeTypes = ['square', 'rectangle', 'triangle'];
    final shapeType = shapeTypes[_random.nextInt(min(difficulty.shapeCount - 1, shapeTypes.length))];

    int answer;
    String prompt;
    Shape displayShape;

    switch (shapeType) {
      case 'square':
        final side = _random.nextInt(6) + 2;
        answer = side * side;
        prompt = 'Area of square with side $side?';
        displayShape = Shape.square;
        break;
      case 'rectangle':
        final w = _random.nextInt(6) + 2;
        final h = _random.nextInt(6) + 2;
        answer = w * h;
        prompt = 'Area of $w×$h rectangle?';
        displayShape = Shape.square;
        break;
      default: // triangle
        final base = (_random.nextInt(4) + 2) * 2; // Even for clean halving
        final height = _random.nextInt(6) + 2;
        answer = (base * height) ~/ 2;
        prompt = 'Area of triangle\nbase=$base, height=$height?';
        displayShape = Shape.triangle;
    }

    final targetItems = [
      ShapeItem(shape: displayShape, color: ShapeColor.blue, fill: ShapeFill.filled),
    ];

    return _buildMathPuzzle(
      prompt: prompt,
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.geometryArea,
      targetOverride: targetItems,
    );
  }

  // ─── geometryAngles: Missing Angles ───────────────────────

  Puzzle _generateGeometryAngles(DifficultyParameters difficulty) {
    // Triangle angles sum to 180
    final a1 = _random.nextInt(60) + 30;
    final a2 = _random.nextInt(60) + 30;
    final answer = 180 - a1 - a2;

    final targetItems = [
      const ShapeItem(shape: Shape.triangle, color: ShapeColor.orange, fill: ShapeFill.filled),
    ];

    return _buildMathPuzzle(
      prompt: 'Triangle angles: $a1°, $a2°, ?°',
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.geometryAngles,
      targetOverride: targetItems,
    );
  }

  // ─── geometrySymmetry: Lines of Symmetry ──────────────────

  Puzzle _generateGeometrySymmetry(DifficultyParameters difficulty) {
    // How many lines of symmetry does a shape have?
    final shapes = [
      (Shape.circle, 'circle', 99),        // infinite → we say "infinite"
      (Shape.square, 'square', 4),
      (Shape.triangle, 'equilateral triangle', 3),
      (Shape.hexagon, 'hexagon', 6),
      (Shape.star, '5-point star', 5),
      (Shape.diamond, 'diamond', 2),
    ];

    final pick = shapes[_random.nextInt(shapes.length)];
    final displayShape = pick.$1;
    final shapeName = pick.$2;
    final answer = pick.$3;

    final targetItems = [
      ShapeItem(shape: displayShape, color: ShapeColor.purple, fill: ShapeFill.filled),
    ];

    if (answer == 99) {
      // Special case: infinite symmetry
      final correctId = _uuid();
      final options = [
        PuzzleOption(id: correctId, items: const [], label: '∞'),
        PuzzleOption(id: _uuid(), items: const [], label: '4'),
        PuzzleOption(id: _uuid(), items: const [], label: '6'),
        PuzzleOption(id: _uuid(), items: const [], label: '1'),
      ]..shuffle(_random);

      return Puzzle(
        id: _uuid(),
        prompt: 'Lines of symmetry in a $shapeName?',
        rule: PuzzleRule.geometrySymmetry,
        targetItems: targetItems,
        options: options,
        correctOptionId: correctId,
      );
    }

    return _buildMathPuzzle(
      prompt: 'Lines of symmetry in a $shapeName?',
      answer: answer,
      difficulty: difficulty,
      rule: PuzzleRule.geometrySymmetry,
      targetOverride: targetItems,
    );
  }

  // ════════════════════════════════════════════════════════════
  // ═══ PHYSICS PUZZLES ═════════════════════════════════════
  // ════════════════════════════════════════════════════════════

  // ─── physicsGravity: Weight & Mass ────────────────────────

  Puzzle _generatePhysicsGravity(DifficultyParameters difficulty) {
    // Which is heavier? Represented by number of filled shapes
    final palette = _pickColors(difficulty.colorCount);
    final objectCount = min(difficulty.choiceCount, 4);

    // Generate objects with different weights
    final weights = <int>[];
    for (int i = 0; i < objectCount; i++) {
      int w;
      do {
        w = _random.nextInt(10) + 1;
      } while (weights.contains(w));
      weights.add(w);
    }

    final heaviestIdx = weights.indexOf(weights.reduce(max));
    final correctId = _uuid();

    final options = <PuzzleOption>[];
    for (int i = 0; i < objectCount; i++) {
      final id = i == heaviestIdx ? correctId : _uuid();
      final color = _randomColor(palette);
      options.add(PuzzleOption(
        id: id,
        items: List.generate(weights[i], (_) =>
          ShapeItem(shape: Shape.circle, color: color, fill: ShapeFill.filled)),
        label: '${weights[i]} kg',
      ));
    }
    options.shuffle(_random);

    // Target shows a downward arrow (represented by a triangle)
    final targetItems = [
      const ShapeItem(shape: Shape.triangle, color: ShapeColor.blue, fill: ShapeFill.filled),
    ];

    return Puzzle(
      id: _uuid(),
      prompt: 'Which is heaviest?',
      rule: PuzzleRule.physicsGravity,
      targetItems: targetItems,
      options: options,
      correctOptionId: correctId,
    );
  }

  // ─── physicsMomentum: Direction Puzzles ────────────────────

  Puzzle _generatePhysicsMomentum(DifficultyParameters difficulty) {
    // Two objects moving toward each other with different masses
    // After collision, which direction does the combined mass move?
    final m1 = _random.nextInt(5) + 1;
    final v1 = _random.nextInt(5) + 1; // moving right (+)
    final m2 = _random.nextInt(5) + 1;
    final v2 = _random.nextInt(5) + 1; // moving left (-)

    final totalMomentum = (m1 * v1) - (m2 * v2);

    final correctId = _uuid();
    final options = <PuzzleOption>[
      PuzzleOption(id: totalMomentum > 0 ? correctId : _uuid(), items: const [], label: 'Right →'),
      PuzzleOption(id: totalMomentum < 0 ? correctId : _uuid(), items: const [], label: '← Left'),
      PuzzleOption(id: totalMomentum == 0 ? correctId : _uuid(), items: const [], label: 'Stopped'),
    ]..shuffle(_random);

    final targetItems = [
      ...List.generate(m1, (_) => const ShapeItem(shape: Shape.circle, color: ShapeColor.blue, fill: ShapeFill.filled)),
      const ShapeItem(shape: Shape.star, color: ShapeColor.yellow, fill: ShapeFill.outlined), // vs
      ...List.generate(m2, (_) => const ShapeItem(shape: Shape.circle, color: ShapeColor.red, fill: ShapeFill.filled)),
    ];

    return Puzzle(
      id: _uuid(),
      prompt: '${m1}kg at ${v1}m/s → hits ← ${m2}kg at ${v2}m/s\nWhich way?',
      rule: PuzzleRule.physicsMomentum,
      targetItems: targetItems,
      options: options,
      correctOptionId: correctId,
    );
  }

  // ─── physicsBalance: Lever/Fulcrum ────────────────────────

  Puzzle _generatePhysicsBalance(DifficultyParameters difficulty) {
    // Torque balance: weight₁ × distance₁ = weight₂ × distance₂
    final w1 = _random.nextInt(5) + 1;
    final d1 = _random.nextInt(4) + 1;
    final d2 = _random.nextInt(4) + 1;

    // w2 = (w1 * d1) / d2 — only generate if it's a whole number
    int w2;
    int actualD2 = d2;
    if ((w1 * d1) % d2 != 0) {
      // Adjust d2 to make w2 whole
      actualD2 = 1;
      while ((w1 * d1) % actualD2 != 0 && actualD2 <= 8) {
        actualD2++;
      }
    }
    w2 = (w1 * d1) ~/ actualD2;

    final targetItems = [
      ...List.generate(w1, (_) => const ShapeItem(shape: Shape.square, color: ShapeColor.blue, fill: ShapeFill.filled)),
      const ShapeItem(shape: Shape.triangle, color: ShapeColor.yellow, fill: ShapeFill.outlined), // fulcrum
      const ShapeItem(shape: Shape.diamond, color: ShapeColor.green, fill: ShapeFill.outlined), // unknown
    ];

    return _buildMathPuzzle(
      prompt: '${w1}kg at ${d1}m = ?kg at ${actualD2}m\nBalance the lever!',
      answer: w2,
      difficulty: difficulty,
      rule: PuzzleRule.physicsBalance,
      targetOverride: targetItems,
    );
  }

  // ════════════════════════════════════════════════════════════
  // ═══ ADVANCED LOGIC ══════════════════════════════════════
  // ════════════════════════════════════════════════════════════

  // ─── numberGrid: Sudoku-style ─────────────────────────────

  Puzzle _generateNumberGrid(DifficultyParameters difficulty) {
    // Simple 2x2 grid where each row and column sums to a target
    final a = _random.nextInt(5) + 1;
    final b = _random.nextInt(5) + 1;
    final c = _random.nextInt(5) + 1;
    final answer = a + b - c; // This ensures the grid is solvable

    // Grid: [a, b]
    //       [c, ?]
    // Row sums and column sums must match

    return _buildMathPuzzle(
      prompt: 'Complete the grid:\n$a  $b\n$c  ?\n(rows sum equal)',
      answer: answer > 0 ? answer : answer.abs() + 2,
      difficulty: difficulty,
      rule: PuzzleRule.numberGrid,
    );
  }

  // ════════════════════════════════════════════════════════════
  // ═══ SHARED MATH BUILDER ═════════════════════════════════
  // ════════════════════════════════════════════════════════════

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
      // Generate plausible wrong answers near the correct one
      final offset = _random.nextInt(7) - 3; // -3 to +3
      int fake = answer + offset;
      if (!allowZero && fake <= 0) fake = _random.nextInt(answer + 5) + 1;
      if (fake < 0) fake = fake.abs();
      if (!usedAnswers.contains(fake)) {
        usedAnswers.add(fake);
        wrongOptions.add(PuzzleOption(
          id: _uuid(),
          items: const [],
          label: '$fake',
        ));
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(_random);

    return Puzzle(
      id: _uuid(),
      prompt: prompt,
      rule: rule,
      targetItems: targetOverride ?? const [],
      options: allOptions,
      correctOptionId: correctOptionId,
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  String _shapeName(Shape s) {
    return s.toString().split('.').last;
  }
}
