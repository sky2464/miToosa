import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('go_router is not declared in pubspec.yaml (BL-38 AC-006)', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('go_router:'), isFalse);
  });

  test('no production import of go_router under lib/', () {
    final libDir = Directory('lib');
    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final content = entity.readAsStringSync();
      expect(
        content.contains("package:go_router"),
        isFalse,
        reason: entity.path,
      );
    }
  });
}
