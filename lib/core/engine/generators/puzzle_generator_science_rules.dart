part of '../puzzle_generator.dart';

mixin PuzzleGeneratorScienceRules on PuzzleGeneratorSupport {
  // ─── geometryArea: Calculate Area ─────────────────────────

  Puzzle _generateGeometryArea(DifficultyParameters difficulty) {
    final shapeTypes = ['square', 'rectangle', 'triangle'];
    final shapeType =
        shapeTypes[random.nextInt(
          min(difficulty.shapeCount - 1, shapeTypes.length),
        )];

    int answer;
    String prompt;
    Shape displayShape;

    switch (shapeType) {
      case 'square':
        final side = random.nextInt(6) + 2;
        answer = side * side;
        prompt = 'Area of square with side $side?';
        displayShape = Shape.square;
        break;
      case 'rectangle':
        final w = random.nextInt(6) + 2;
        final h = random.nextInt(6) + 2;
        answer = w * h;
        prompt = 'Area of $w×$h rectangle?';
        displayShape = Shape.square;
        break;
      default: // triangle
        final base = (random.nextInt(4) + 2) * 2; // Even for clean halving
        final height = random.nextInt(6) + 2;
        answer = (base * height) ~/ 2;
        prompt = 'Area of triangle\nbase=$base, height=$height?';
        displayShape = Shape.triangle;
    }

    final targetItems = [
      ShapeItem(
        shape: displayShape,
        color: ShapeColor.blue,
        fill: ShapeFill.filled,
      ),
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
    final a1 = random.nextInt(60) + 30;
    final a2 = random.nextInt(60) + 30;
    final answer = 180 - a1 - a2;

    final targetItems = [
      const ShapeItem(
        shape: Shape.triangle,
        color: ShapeColor.orange,
        fill: ShapeFill.filled,
      ),
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
      (Shape.circle, 'circle', 99), // infinite → we say "infinite"
      (Shape.square, 'square', 4),
      (Shape.triangle, 'equilateral triangle', 3),
      (Shape.hexagon, 'hexagon', 6),
      (Shape.star, '5-point star', 5),
      (Shape.diamond, 'diamond', 2),
    ];

    final pick = shapes[random.nextInt(shapes.length)];
    final displayShape = pick.$1;
    final shapeName = pick.$2;
    final answer = pick.$3;

    final targetItems = [
      ShapeItem(
        shape: displayShape,
        color: ShapeColor.purple,
        fill: ShapeFill.filled,
      ),
    ];

    if (answer == 99) {
      // Special case: infinite symmetry
      final correctId = _uuid();
      final options = [
        PuzzleOption(id: correctId, items: const [], label: '∞'),
        PuzzleOption(id: _uuid(), items: const [], label: '4'),
        PuzzleOption(id: _uuid(), items: const [], label: '6'),
        PuzzleOption(id: _uuid(), items: const [], label: '1'),
      ]..shuffle(random);

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
        w = random.nextInt(10) + 1;
      } while (weights.contains(w));
      weights.add(w);
    }

    final heaviestIdx = weights.indexOf(weights.reduce(max));
    final correctId = _uuid();

    final options = <PuzzleOption>[];
    for (int i = 0; i < objectCount; i++) {
      final id = i == heaviestIdx ? correctId : _uuid();
      final color = randomColor(palette);
      options.add(
        PuzzleOption(
          id: id,
          items: List.generate(
            weights[i],
            (_) => ShapeItem(
              shape: Shape.circle,
              color: color,
              fill: ShapeFill.filled,
            ),
          ),
          label: '${weights[i]} kg',
        ),
      );
    }
    options.shuffle(random);

    // Target shows a downward arrow (represented by a triangle)
    final targetItems = [
      const ShapeItem(
        shape: Shape.triangle,
        color: ShapeColor.blue,
        fill: ShapeFill.filled,
      ),
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
    final m1 = random.nextInt(5) + 1;
    final v1 = random.nextInt(5) + 1; // moving right (+)
    final m2 = random.nextInt(5) + 1;
    final v2 = random.nextInt(5) + 1; // moving left (-)

    final totalMomentum = (m1 * v1) - (m2 * v2);

    final correctId = _uuid();
    final options = <PuzzleOption>[
      PuzzleOption(
        id: totalMomentum > 0 ? correctId : _uuid(),
        items: const [],
        label: 'Right →',
      ),
      PuzzleOption(
        id: totalMomentum < 0 ? correctId : _uuid(),
        items: const [],
        label: '← Left',
      ),
      PuzzleOption(
        id: totalMomentum == 0 ? correctId : _uuid(),
        items: const [],
        label: 'Stopped',
      ),
    ]..shuffle(random);

    final targetItems = [
      ...List.generate(
        m1,
        (_) => const ShapeItem(
          shape: Shape.circle,
          color: ShapeColor.blue,
          fill: ShapeFill.filled,
        ),
      ),
      const ShapeItem(
        shape: Shape.star,
        color: ShapeColor.yellow,
        fill: ShapeFill.outlined,
      ), // vs
      ...List.generate(
        m2,
        (_) => const ShapeItem(
          shape: Shape.circle,
          color: ShapeColor.red,
          fill: ShapeFill.filled,
        ),
      ),
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
    final w1 = random.nextInt(5) + 1;
    final d1 = random.nextInt(4) + 1;
    final d2 = random.nextInt(4) + 1;

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
      ...List.generate(
        w1,
        (_) => const ShapeItem(
          shape: Shape.square,
          color: ShapeColor.blue,
          fill: ShapeFill.filled,
        ),
      ),
      const ShapeItem(
        shape: Shape.triangle,
        color: ShapeColor.yellow,
        fill: ShapeFill.outlined,
      ), // fulcrum
      const ShapeItem(
        shape: Shape.diamond,
        color: ShapeColor.green,
        fill: ShapeFill.outlined,
      ), // unknown
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
}
