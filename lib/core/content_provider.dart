import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'models/gameplay_level.dart';
import 'models/puzzle.dart';
import 'engine/puzzle_generator.dart';

class TrackDefinition {
  final String id;
  final String name;
  final String subtitle;
  final PuzzleRule rule;
  final String icon;
  final int targetLevelCount;

  TrackDefinition({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.rule,
    this.icon = '🧩',
    this.targetLevelCount = 10,
  });

  factory TrackDefinition.fromJson(Map<String, dynamic> json) {
    return TrackDefinition(
      id: json['id'],
      name: json['name'],
      subtitle: json['subtitle'],
      rule: PuzzleRule.values.firstWhere((e) => e.name == json['rule']),
      icon: json['icon'] ?? '🧩',
      targetLevelCount: (json['levelCount'] as int?) ?? 10,
    );
  }
}

class ContentProvider {
  static final ContentProvider _instance = ContentProvider._internal();
  factory ContentProvider() => _instance;
  ContentProvider._internal();

  List<TrackDefinition> tracks = [];
  final PuzzleGenerator _generator = PuzzleGenerator();

  Future<void> init() async {
    final String jsonString = await rootBundle.loadString('assets/content/worlds.json');
    final List<dynamic> jsonList = jsonDecode(jsonString);
    tracks = jsonList.map((e) => TrackDefinition.fromJson(e)).toList();
  }

  /// Procedural level builder with progressive difficulty.
  GameplayLevel buildLevelForTrack(TrackDefinition track, int levelIndex) {
    // Difficulty ramps up gradually — slower at start for better onboarding
    final shapeCount = (3 + (levelIndex / 8).floor()).clamp(3, 10);
    final colorCount = (2 + (levelIndex / 12).floor()).clamp(2, 8);
    final choiceCount = (3 + (levelIndex / 15).floor()).clamp(3, 8);

    final difficulty = DifficultyParameters(
      shapeCount: shapeCount,
      colorCount: colorCount,
      choiceCount: choiceCount,
    );

    final puzzle = _generator.generate(
      rule: track.rule,
      difficulty: difficulty,
    );

    final successMessages = [
      'IQ +1! 🧠',
      'Synapse Connected! ⚡',
      'Memory Boost! 💪',
      'Dopamine Hit! 🎯',
      'Neuron Chain Formed! 🔗',
      'Genius Pattern! ✨',
      'Big Brain Move! 🧬',
      'Neural Pathway Built! 🛤️',
    ];
    final messageIdx = Random.secure().nextInt(successMessages.length);

    return GameplayLevel(
      title: '${track.name} — Lvl ${levelIndex + 1}',
      puzzle: puzzle,
      hint: puzzle.prompt,
      successMessage: successMessages[messageIdx],
      retryMessage: 'Try again, build that memory! 💭',
      perfectScore: 100 + (levelIndex * 10),
    );
  }
}
