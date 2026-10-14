import '../models/puzzle.dart';

enum TutorialDemoType {
  shapeMatch,
  count,
  oddOneOut,
  sequence,
  binary,
  boolean,
  cipher,
  math,
  geometry,
  physics,
  grid,
}

class TutorialDemoOption {
  final String id;
  final String label;

  const TutorialDemoOption({required this.id, required this.label});

  factory TutorialDemoOption.fromJson(Map<String, dynamic> json) {
    return TutorialDemoOption(
      id: json['id'] as String,
      label: json['label'] as String,
    );
  }
}

class TutorialDefinition {
  final String trackId;
  final PuzzleRule rule;
  final String goal;
  final List<String> steps;
  final TutorialDemoType demoType;
  final String correctAction;
  final String objectiveTemplate;
  final String demoPrompt;
  final List<TutorialDemoOption> demoOptions;

  const TutorialDefinition({
    required this.trackId,
    required this.rule,
    required this.goal,
    required this.steps,
    required this.demoType,
    required this.correctAction,
    required this.objectiveTemplate,
    required this.demoPrompt,
    required this.demoOptions,
  });

  factory TutorialDefinition.fromJson(Map<String, dynamic> json) {
    return TutorialDefinition(
      trackId: json['trackId'] as String,
      rule: PuzzleRule.values.firstWhere((e) => e.name == json['rule']),
      goal: json['goal'] as String,
      steps: (json['steps'] as List<dynamic>).cast<String>(),
      demoType: TutorialDemoType.values.byName(json['demoType'] as String),
      correctAction: json['correctAction'] as String,
      objectiveTemplate: json['objectiveTemplate'] as String,
      demoPrompt: json['demoPrompt'] as String,
      demoOptions: (json['demoOptions'] as List<dynamic>)
          .map((e) => TutorialDemoOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

TutorialDemoType demoTypeForRule(PuzzleRule rule) {
  switch (rule) {
    case PuzzleRule.matchIdentical:
      return TutorialDemoType.shapeMatch;
    case PuzzleRule.countShapes:
      return TutorialDemoType.count;
    case PuzzleRule.oddOneOut:
      return TutorialDemoType.oddOneOut;
    case PuzzleRule.colorPattern:
    case PuzzleRule.findMissing:
    case PuzzleRule.sequenceNext:
      return TutorialDemoType.sequence;
    case PuzzleRule.binaryDecode:
      return TutorialDemoType.binary;
    case PuzzleRule.logicGate:
      return TutorialDemoType.boolean;
    case PuzzleRule.cipherBreak:
      return TutorialDemoType.cipher;
    case PuzzleRule.balanceEquation:
    case PuzzleRule.mathAddSub:
    case PuzzleRule.mathMulDiv:
    case PuzzleRule.mathExponent:
    case PuzzleRule.mathModulo:
    case PuzzleRule.mathFraction:
    case PuzzleRule.mathAlgebra:
      return TutorialDemoType.math;
    case PuzzleRule.geometryArea:
    case PuzzleRule.geometryAngles:
    case PuzzleRule.geometrySymmetry:
      return TutorialDemoType.geometry;
    case PuzzleRule.physicsGravity:
    case PuzzleRule.physicsMomentum:
    case PuzzleRule.physicsBalance:
      return TutorialDemoType.physics;
    case PuzzleRule.numberGrid:
      return TutorialDemoType.grid;
  }
}
