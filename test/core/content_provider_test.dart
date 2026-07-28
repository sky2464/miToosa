import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/core/models/puzzle.dart';

void main() {
  group('TrackDefinition', () {
    test('fromJson reads levelCount as targetLevelCount', () {
      final json = {
        'id': 'track_1',
        'name': 'Pattern Match',
        'subtitle': 'Match identical patterns',
        'rule': 'matchIdentical',
        'icon': '🧩',
        'iconAsset': 'assets/images/icons/track_pattern_match.png',
        'levelCount': 15,
      };
      expect(TrackDefinition.fromJson(json).targetLevelCount, 15);
    });

    test('fromJson defaults to 10 when levelCount is absent', () {
      final json = {
        'id': 'track_x',
        'name': 'Legacy',
        'subtitle': 'Old entry',
        'rule': 'countShapes',
        'icon': '🔢',
        'iconAsset': 'assets/images/icons/track_shape_counter.png',
      };
      expect(TrackDefinition.fromJson(json).targetLevelCount, 10);
    });

    test('fromJson is deterministic across calls', () {
      final json = {
        'id': 'track_5',
        'name': 'Missing Piece',
        'subtitle': 'Fill in the blanks',
        'rule': 'findMissing',
        'icon': '🧠',
        'iconAsset': 'assets/images/icons/track_memory.png',
        'levelCount': 10,
      };
      final count1 = TrackDefinition.fromJson(json).targetLevelCount;
      final count2 = TrackDefinition.fromJson(json).targetLevelCount;
      expect(count1, count2);
    });

    test('programmatic constructor defaults targetLevelCount to 10', () {
      final track = TrackDefinition(
        id: 't',
        name: 'T',
        subtitle: 'S',
        rule: PuzzleRule.oddOneOut,
      );
      expect(track.targetLevelCount, 10);
    });

    test('programmatic constructor respects explicit targetLevelCount', () {
      final track = TrackDefinition(
        id: 't',
        name: 'T',
        subtitle: 'S',
        rule: PuzzleRule.mathMulDiv,
        targetLevelCount: 12,
      );
      expect(track.targetLevelCount, 12);
    });

    test('fromJson reads category from JSON', () {
      final json = {
        'id': 'track_logic',
        'name': 'Logic Gates',
        'subtitle': 'Boolean puzzles',
        'rule': 'logicGate',
        'icon': '🔀',
        'category': 'logic',
        'iconAsset': 'assets/images/icons/track_logic_gates.png',
      };
      expect(TrackDefinition.fromJson(json).category, 'logic');
    });

    test('fromJson defaults category to Default when absent', () {
      final json = {
        'id': 'track_legacy',
        'name': 'Legacy',
        'subtitle': 'No category field',
        'rule': 'countShapes',
        'icon': '🔢',
      };
      expect(TrackDefinition.fromJson(json).category, 'Default');
    });

    test('fromJson reads iconAsset from JSON', () {
      final json = {
        'id': 'track_memory',
        'name': 'Memory Match',
        'subtitle': 'Recall patterns',
        'rule': 'matchIdentical',
        'icon': '🧠',
        'category': 'memory',
        'iconAsset': 'assets/images/icons/track_memory.png',
      };
      expect(
        TrackDefinition.fromJson(json).iconAsset,
        'assets/images/icons/track_memory.png',
      );
    });

    test('fromJson defaults iconAsset to empty when absent', () {
      final json = {
        'id': 'track_legacy',
        'name': 'Legacy',
        'subtitle': 'No iconAsset field',
        'rule': 'oddOneOut',
        'icon': '🧩',
        'category': 'memory',
      };
      expect(TrackDefinition.fromJson(json).iconAsset, '');
    });
  });
}
