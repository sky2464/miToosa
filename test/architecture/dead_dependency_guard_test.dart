import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// BL-38 AC-006: proven-dead dependencies stay out of production config.
void main() {
  final repoRoot = Directory.current.path;

  test('go_router is not declared in pubspec.yaml', () {
    final pubspec = File(
      '$repoRoot${Platform.pathSeparator}pubspec.yaml',
    ).readAsStringSync();
    expect(pubspec.contains('go_router'), isFalse);
  });

  test('go_router has no production Dart readers under lib/', () {
    final lib = Directory('$repoRoot${Platform.pathSeparator}lib');
    for (final entity in lib.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      expect(
        content.contains('go_router'),
        isFalse,
        reason: '${entity.path} references go_router',
      );
    }
  });
}
