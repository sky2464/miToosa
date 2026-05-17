import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android release signing scaffolding', () {
    test('gitignore contains expected secret patterns', () {
      final gitignore = File('.gitignore');
      expect(gitignore.existsSync(), isTrue);
      final gitignoreText = gitignore.readAsStringSync();

      expect(gitignoreText, contains('android/key.properties'));
      expect(gitignoreText, contains('*.keystore'));
      expect(gitignoreText, contains('*.jks'));
    });

    test('template and runbook exist', () {
      final templateFile = File('android/key.properties.template');
      expect(templateFile.existsSync(), isTrue);

      final docsFile = File('Docs/RELEASE-SIGNING.md');
      expect(docsFile.existsSync(), isTrue);
    });

    test('build.gradle includes release key properties guard', () {
      final buildFile = File('android/app/build.gradle.kts');
      expect(buildFile.existsSync(), isTrue);
      final buildText = buildFile.readAsStringSync();

      expect(buildText, contains('rootProject.file("android/key.properties")'));
      expect(buildText, contains('GradleException'));
      expect(buildText, contains('Missing:'));
    });

    test('git ignore patterns will ignore an Android key.properties path', () async {
      final process = await Process.run('git', ['check-ignore', '-q', 'android/key.properties']);
      expect(process.exitCode, equals(0), reason: 'android/key.properties should be ignored by gitignore');
    });
  });
}
