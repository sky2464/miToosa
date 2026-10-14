import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// BL-38 AC-005 (T-005): core engine stays free of Flutter/Hive/UI imports.
void main() {
  const forbidden = <String>[
    'package:flutter/',
    'package:flutter_riverpod/',
    'package:hive',
    'package:mitoosa/features/',
    'package:mitoosa/widgets/',
  ];

  test('lib/core/engine has no forbidden imports @smoke T-005', () {
    final engineDir = Directory('lib/core/engine');
    expect(engineDir.existsSync(), isTrue);

    for (final entity in engineDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = File(entity.path).readAsStringSync();
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
