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
  });
}
