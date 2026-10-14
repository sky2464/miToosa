import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// BL-38 AC-005: core engine stays free of Flutter/Hive/feature imports.
void main() {
  final repoRoot = Directory.current.path;
  final engineDir =
      '$repoRoot${Platform.pathSeparator}lib${Platform.pathSeparator}core${Platform.pathSeparator}engine';
  const forbidden = [
    'package:flutter/',
    'package:hive',
    'package:flutter_riverpod',
    'package:mitoosa/features/',
    'package:mitoosa/data/',
  ];

  test('core engine has no forbidden imports', () {
    final dir = Directory(engineDir);
    expect(dir.existsSync(), isTrue);
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      for (final needle in forbidden) {
        expect(
          content.contains(needle),
          isFalse,
          reason: '${entity.path} must not import $needle',
        );
      }
    }
  });
}
