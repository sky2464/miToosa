import 'dart:convert';

import 'package:flutter/services.dart';

import '../content_provider.dart';
import '../models/puzzle.dart';
import 'tutorial_definition.dart';

class TutorialCoverageException implements Exception {
  final String message;
  TutorialCoverageException(this.message);
  @override
  String toString() => message;
}

class TutorialRepository {
  final Map<String, TutorialDefinition> _byTrackId = {};
  final Map<PuzzleRule, TutorialDemoType> _ruleDemoTypes = {};

  List<TutorialDefinition> get definitions =>
      _byTrackId.values.toList(growable: false);

  TutorialDefinition? forTrack(String trackId) => _byTrackId[trackId];

  Future<void> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final list = jsonDecode(jsonString) as List<dynamic>;
    _byTrackId.clear();
    _ruleDemoTypes.clear();
    for (final raw in list) {
      final def = TutorialDefinition.fromJson(raw as Map<String, dynamic>);
      _byTrackId[def.trackId] = def;
      _ruleDemoTypes[def.rule] = def.demoType;
    }
  }

  /// Ensures every track and every active [PuzzleRule] has tutorial coverage.
  void validateAgainstTracks(List<TrackDefinition> tracks) {
    if (_byTrackId.isEmpty) {
      throw TutorialCoverageException('No tutorial definitions loaded');
    }
    for (final track in tracks) {
      final def = _byTrackId[track.id];
      if (def == null) {
        throw TutorialCoverageException('Missing tutorial for ${track.id}');
      }
      if (def.rule != track.rule) {
        throw TutorialCoverageException(
          'Tutorial rule mismatch for ${track.id}: ${def.rule} vs ${track.rule}',
        );
      }
      if (def.demoType != demoTypeForRule(track.rule)) {
        throw TutorialCoverageException('Demo type mismatch for ${track.id}');
      }
    }
    for (final rule in PuzzleRule.values) {
      if (!_ruleDemoTypes.containsKey(rule)) {
        throw TutorialCoverageException('Missing tutorial for rule $rule');
      }
    }
  }
}
