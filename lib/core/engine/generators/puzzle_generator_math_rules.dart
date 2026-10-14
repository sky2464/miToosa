part of '../puzzle_generator.dart';

mixin PuzzleGeneratorMathRules on PuzzleGeneratorSupport {
  // ─── mathAddSub: Addition & Subtraction ───────────────────

  Puzzle _generateMathAddSub(DifficultyParameters difficulty) {
    // Scale difficulty: early = small numbers & addition, later = larger & subtraction
    final maxNum = 5 + difficulty.shapeCount * 3;
    final useSubtraction = random.nextBool() && difficulty.shapeCount > 3;

    int a, b, answer;
    String op;
    if (useSubtraction) {
      a = random.nextInt(maxNum) + difficulty.shapeCount;
      b = random.nextInt(a) + 1; // Ensure positive result
      answer = a - b;
      op = '−';
    } else {
      a = random.nextInt(maxNum) + 1;
      b = random.nextInt(maxNum) + 1;
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
    final useDivision = random.nextBool() && difficulty.shapeCount > 4;

    int a, b, answer;
    String op;
    if (useDivision) {
      // Generate clean division (no remainder)
      b = random.nextInt(tier * 3) + 2;
      answer = random.nextInt(tier * 3) + 1;
      a = b * answer;
      op = '÷';
    } else {
      a = random.nextInt(tier * 3) + 1;
      b = random.nextInt(tier * 3) + 1;
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
    final useRoot = random.nextBool() && difficulty.shapeCount > 4;

    int answer;
    String prompt;
    if (useRoot) {
      // Perfect squares
      final roots = [2, 3, 4, 5, 6, 7, 8, 9];
      answer = roots[random.nextInt(min(difficulty.shapeCount, roots.length))];
      final squared = answer * answer;
      prompt = 'What is √$squared ?';
    } else {
      final base = random.nextInt(5) + 2;
      final exp = 2 + (random.nextInt(2) * (difficulty.shapeCount > 5 ? 1 : 0));
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
    const superscripts = {
      '0': '⁰',
      '1': '¹',
      '2': '²',
      '3': '³',
      '4': '⁴',
      '5': '⁵',
      '6': '⁶',
      '7': '⁷',
      '8': '⁸',
      '9': '⁹',
    };
    return n.toString().split('').map((c) => superscripts[c] ?? c).join();
  }

  // ─── mathModulo: Remainder ────────────────────────────────

  Puzzle _generateMathModulo(DifficultyParameters difficulty) {
    final maxA = 10 + difficulty.shapeCount * 5;
    final a = random.nextInt(maxA) + difficulty.shapeCount + 2;
    final b = random.nextInt(5) + 2;
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
    final d =
        denominators[random.nextInt(
          min(difficulty.shapeCount, denominators.length),
        )];
    final n = random.nextInt(d - 1) + 1;

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
      final wn = random.nextInt(d) + 1;
      final wd = denominators[random.nextInt(denominators.length)];
      final wg = gcd(wn, wd);
      final label = '${wn ~/ wg}/${wd ~/ wg}';
      if (!usedLabels.contains(label)) {
        usedLabels.add(label);
        wrongOptions.add(
          PuzzleOption(id: _uuid(), items: const [], label: label),
        );
      }
    }

    final allOptions = [correctOption, ...wrongOptions]..shuffle(random);

    // Visual: show n filled circles out of d total circles
    final targetItems = List.generate(
      d,
      (i) => ShapeItem(
        shape: Shape.circle,
        color: i < n ? ShapeColor.teal : ShapeColor.red,
        fill: i < n ? ShapeFill.filled : ShapeFill.outlined,
      ),
    );

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
    final useMultiplication = random.nextBool() && difficulty.shapeCount > 4;

    int answer;
    String prompt;
    if (useMultiplication) {
      final a = random.nextInt(5) + 2;
      answer = random.nextInt(8) + 1;
      final c = a * answer;
      prompt = 'Solve: ${a}x = $c';
    } else {
      final b = random.nextInt(10 + difficulty.shapeCount) + 1;
      answer = random.nextInt(10 + difficulty.shapeCount) + 1;
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
}
