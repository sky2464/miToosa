import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/content_provider.dart';

Future<List<dynamic>> _loadWorldsJsonRows() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final jsonString = await rootBundle.loadString('assets/content/worlds.json');
  return jsonDecode(jsonString) as List<dynamic>;
}

List<TrackDefinition> _parseTracks(List<dynamic> rows) {
  return rows
      .map((row) => TrackDefinition.fromJson(row as Map<String, dynamic>))
      .toList();
}

void main() {
  group('BL-30 catalog validation', () {
    test('T-001 catalog schema coverage @smoke', () async {
      final rows = await _loadWorldsJsonRows();
      final tracks = _parseTracks(rows);

      expect(tracks, hasLength(CatalogValidator.expectedTrackCount));
      expect(
        tracks.map((t) => t.id).toSet(),
        hasLength(CatalogValidator.expectedTrackCount),
      );

      for (final row in rows) {
        CatalogValidator.validateTrackRecord(row as Map<String, dynamic>);
      }

      CatalogValidator.validateTracks(tracks);

      for (final track in tracks) {
        expect(
          TrackCategory.allowlist,
          contains(track.category),
          reason: 'track ${track.id} category',
        );
        final row = rows.firstWhere(
          (r) => (r as Map<String, dynamic>)['id'] == track.id,
        ) as Map<String, dynamic>;
        expect(row['iconAsset'], isNotNull);
        expect(row['iconAsset'], isNotEmpty);
      }
    });

    test('T-002 category filter membership @smoke', () async {
      final rows = await _loadWorldsJsonRows();
      for (final row in rows) {
        CatalogValidator.validateTrackRecord(row as Map<String, dynamic>);
      }
      final tracks = _parseTracks(rows);

      final byCategory = <String, List<TrackDefinition>>{};
      for (final track in tracks) {
        byCategory.putIfAbsent(track.category, () => []).add(track);
      }

      for (final category in TrackCategory.allowlist) {
        expect(
          byCategory[category],
          isNotNull,
          reason: 'category $category should have at least one track',
        );
        expect(
          byCategory[category]!,
          isNotEmpty,
          reason: 'category $category should not be empty',
        );
      }
    });

    test('T-003 artwork resolution @smoke', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final rows = await _loadWorldsJsonRows();

      for (final row in rows) {
        final json = row as Map<String, dynamic>;
        CatalogValidator.validateTrackRecord(json);
        final iconAsset = json['iconAsset'] as String;
        await rootBundle.load(iconAsset);
      }
    });

    test('T-004 invalid content fails fast', () {
      expect(
        () => CatalogValidator.validateTrackRecord({
          'id': 'track_invalid',
          'name': 'Invalid Track',
          'subtitle': 'Missing category metadata',
          'rule': 'matchIdentical',
          'iconAsset': 'assets/images/icons/track_memory.png',
        }),
        throwsA(isA<CatalogValidationException>()),
      );
    });

    test('T-005 registered asset reader audit @smoke', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final contents = file.readAsStringSync();
        expect(
          contents.contains('levels.json'),
          isFalse,
          reason: '${file.path} must not reference levels.json',
        );
      }

      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec.contains('assets/content/levels.json'),
        isFalse,
        reason: 'levels.json should not be registered in pubspec.yaml',
      );
    });
  });
}
