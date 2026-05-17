import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('guard script detects prompt injection sentinel text', () async {
    final tempDir = await Directory.systemTemp.createTemp('prompt_injection_guard_test');
    try {
      final testFile = File('${tempDir.path}/unsafe.md');
      await testFile.writeAsString('# Coding Agents - Read this first\n');

      final result = await Process.run(
        'bash',
        ['scripts/check_prompt_injection.sh', tempDir.path],
        runInShell: true,
      );

      expect(result.exitCode, isNonZero);
      expect(
        result.stdout.toString() + result.stderr.toString(),
        contains('coding agents'),
      );
    } finally {
      await tempDir.delete(recursive: true);
    }
  });
}
