part of '../puzzle_generator.dart';

mixin PuzzleGeneratorLogicRules on PuzzleGeneratorSupport {
  // ─── binaryDecode (NEW) ───────────────────────────────────

  Puzzle _generateBinaryDecode(DifficultyParameters difficulty) {
    // Show filled/outlined circles as binary (filled=1, outlined=0)
    final bitCount = min(difficulty.shapeCount, 6).clamp(3, 6);
    final targetValue = random.nextInt(pow(2, bitCount).toInt() - 1) + 1;

    final targetItems = <ShapeItem>[];
    for (int bit = bitCount - 1; bit >= 0; bit--) {
      final isOne = (targetValue >> bit) & 1 == 1;
      targetItems.add(
        ShapeItem(
          shape: Shape.circle,
          color: isOne ? ShapeColor.teal : ShapeColor.red,
          fill: isOne ? ShapeFill.filled : ShapeFill.outlined,
        ),
      );
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
      final fakeValue = random.nextInt(pow(2, bitCount).toInt() - 1) + 1;
      if (!usedValues.contains(fakeValue)) {
        usedValues.add(fakeValue);
        wrongOptions.add(
          PuzzleOption(id: _uuid(), items: targetItems, label: '$fakeValue'),
        );
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

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
    final gate = gates[random.nextInt(gates.length)];

    final a = random.nextBool();
    final b = random.nextBool();

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
      ShapeItem(
        shape: Shape.circle,
        color: a ? ShapeColor.green : ShapeColor.red,
        fill: a ? ShapeFill.filled : ShapeFill.outlined,
      ),
      const ShapeItem(
        shape: Shape.star,
        color: ShapeColor.yellow,
        fill: ShapeFill.filled,
      ), // represents the gate
      ShapeItem(
        shape: Shape.circle,
        color: b ? ShapeColor.green : ShapeColor.red,
        fill: b ? ShapeFill.filled : ShapeFill.outlined,
      ),
    ];

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: [
        ShapeItem(
          shape: Shape.circle,
          color: result ? ShapeColor.green : ShapeColor.red,
          fill: result ? ShapeFill.filled : ShapeFill.outlined,
        ),
      ],
      label: result ? 'TRUE' : 'FALSE',
    );

    final wrongOption = PuzzleOption(
      id: _uuid(),
      items: [
        ShapeItem(
          shape: Shape.circle,
          color: !result ? ShapeColor.green : ShapeColor.red,
          fill: !result ? ShapeFill.filled : ShapeFill.outlined,
        ),
      ],
      label: !result ? 'TRUE' : 'FALSE',
    );

    final allOptions = [correctOption, wrongOption]..shuffle(random);

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
    final shapes = List<Shape>.from(Shape.values)..shuffle(random);
    final palette = _pickColors(difficulty.colorCount);

    final wordLen = min(difficulty.shapeCount, 4).clamp(2, 4);
    final cipherMap = <Shape, String>{};
    for (int i = 0; i < shapes.length && i < letters.length; i++) {
      cipherMap[shapes[i]] = letters[i];
    }

    // Build the "encoded word" as shapes
    final wordShapes = <Shape>[];
    for (int i = 0; i < wordLen; i++) {
      wordShapes.add(shapes[random.nextInt(min(3, shapes.length))]);
    }

    final decodedWord = wordShapes.map((s) => cipherMap[s] ?? '?').join('');

    final targetItems = wordShapes
        .map((s) => ShapeItem(shape: s, color: randomColor(palette)))
        .toList();

    // Show the cipher key as additional target items (use the first 3 mappings)
    final keyItems = <ShapeItem>[];
    for (int i = 0; i < min(3, shapes.length); i++) {
      keyItems.add(
        ShapeItem(shape: shapes[i], color: palette[i % palette.length]),
      );
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
      final fakeWord = List.generate(
        wordLen,
        (_) => letters[random.nextInt(min(3, letters.length))],
      ).join('');
      if (!usedWords.contains(fakeWord)) {
        usedWords.add(fakeWord);
        wrongOptions.add(
          PuzzleOption(id: _uuid(), items: targetItems, label: fakeWord),
        );
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    // Combine key + encoded word for display
    final displayItems = [...keyItems, ...targetItems];

    return Puzzle(
      id: _uuid(),
      prompt:
          'Decode: ${cipherMap.entries.take(3).map((e) => '${_shapeName(e.key)}=${e.value}').join(', ')}',
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
    final a = random.nextInt(5) + 1;
    final b = random.nextInt(5) + 1;
    final answer = a + b;

    // Represent numbers as groups of shapes
    final shapeA = randomShape();
    final shapeB = randomShape();
    final colorA = randomColor(palette);
    final colorB = randomColor(palette);

    final leftSide = <ShapeItem>[
      ...List.generate(a, (_) => ShapeItem(shape: shapeA, color: colorA)),
      // Plus sign represented by a star
      const ShapeItem(
        shape: Shape.star,
        color: ShapeColor.yellow,
        fill: ShapeFill.outlined,
      ),
      ...List.generate(b, (_) => ShapeItem(shape: shapeB, color: colorB)),
    ];

    final correctOptionId = _uuid();
    final correctOption = PuzzleOption(
      id: correctOptionId,
      items: List.generate(
        answer,
        (_) => const ShapeItem(shape: Shape.circle, color: ShapeColor.green),
      ),
      label: '$answer',
    );

    final wrongOptions = <PuzzleOption>[];
    final usedAnswers = {answer};

    int bailout = 0;
    while (wrongOptions.length < difficulty.choiceCount - 1 && bailout < 100) {
      bailout++;
      final fakeAnswer = random.nextInt(12) + 1;
      if (!usedAnswers.contains(fakeAnswer)) {
        usedAnswers.add(fakeAnswer);
        wrongOptions.add(
          PuzzleOption(
            id: _uuid(),
            items: List.generate(
              fakeAnswer.clamp(1, 12),
              (_) =>
                  const ShapeItem(shape: Shape.circle, color: ShapeColor.green),
            ),
            label: '$fakeAnswer',
          ),
        );
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

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
}
