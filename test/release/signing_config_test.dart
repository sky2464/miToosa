import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iPhone launch identity', () {
    test('Runner uses the locked iOS bundle identifier', () {
      final projectFile = File('ios/Runner.xcodeproj/project.pbxproj');
      expect(projectFile.existsSync(), isTrue);
      final projectText = projectFile.readAsStringSync();

      expect(
        projectText,
        contains('PRODUCT_BUNDLE_IDENTIFIER = dev.atoosa.mitoosa;'),
      );
      expect(
        projectText,
        contains('PRODUCT_BUNDLE_IDENTIFIER = dev.atoosa.mitoosa.RunnerTests;'),
      );
      expect(
        projectText,
        isNot(contains('PRODUCT_BUNDLE_IDENTIFIER = com.chicademy.mitoosa;')),
      );
      expect(
        projectText,
        isNot(contains('PRODUCT_BUNDLE_IDENTIFIER = com.mitoosa.app;')),
      );
    });

    test('release runbook points App Store work at the locked bundle id', () {
      final docsFile = File('docs/RELEASE-SIGNING.md');
      expect(docsFile.existsSync(), isTrue);
      final docsText = docsFile.readAsStringSync();

      expect(docsText, contains('dev.atoosa.mitoosa'));
      expect(docsText, isNot(contains('com.mitoosa.app')));
    });
  });

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

      final docsFile = File('docs/RELEASE-SIGNING.md');
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

    test(
      'git ignore patterns will ignore an Android key.properties path',
      () async {
        final process = await Process.run('git', [
          'check-ignore',
          '-q',
          'android/key.properties',
        ]);
        expect(
          process.exitCode,
          equals(0),
          reason: 'android/key.properties should be ignored by gitignore',
        );
      },
    );

    test(
      'runbook contains iOS, Verification, Secret rotation, Troubleshooting sections',
      () {
        // Regression guard for BL-01+02 task 4.1 — these headings document the
        // pbxproj escape hatch + cross-platform verification + key lifecycle.
        // The Android section is intentionally not asserted here (covered by
        // 'template and runbook exist' above).
        final docsFile = File('docs/RELEASE-SIGNING.md');
        expect(docsFile.existsSync(), isTrue);
        final docsText = docsFile.readAsStringSync();

        expect(
          docsText,
          contains('# iOS'),
          reason: 'iOS section heading missing from RELEASE-SIGNING.md',
        );
        expect(
          docsText,
          contains('# Verification'),
          reason:
              'Verification section heading missing from RELEASE-SIGNING.md',
        );
        expect(
          docsText,
          contains('# Secret rotation'),
          reason:
              'Secret rotation section heading missing from RELEASE-SIGNING.md',
        );
        expect(
          docsText,
          contains('# Troubleshooting'),
          reason:
              'Troubleshooting section heading missing from RELEASE-SIGNING.md',
        );
      },
    );
  });
}
