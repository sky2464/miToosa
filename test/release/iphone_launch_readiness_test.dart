import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iPhone launch readiness docs', () {
    test('launch checklist locks iPhone App Store and Firebase decisions', () {
      final file = File('docs/IPHONE-LAUNCH-READINESS.md');
      expect(file.existsSync(), isTrue);
      final text = file.readAsStringSync();

      expect(text, contains('dev.atoosa.mitoosa'));
      expect(text, contains('iPhone/iOS only'));
      expect(text, contains('Firebase + Google Analytics'));
      expect(text, contains('FIREBASE_ENABLED=true'));
      expect(text, contains('TestFlight install on a real iPhone'));
      expect(text, contains('App Privacy questionnaire'));
    });

    test('metadata draft includes App Store submission fields', () {
      final file = File('docs/APP-STORE-METADATA.md');
      expect(file.existsSync(), isTrue);
      final text = file.readAsStringSync();

      for (final required in [
        'Name',
        'Subtitle',
        'Category',
        'Keywords',
        'Privacy Policy URL',
        'Support URL',
        'Age rating',
        'Export compliance',
        'Screenshot capture plan',
      ]) {
        expect(text, contains(required), reason: '$required missing');
      }
    });

    test('company readiness checklist captures human-only formation steps', () {
      final file = File('docs/COMPANY-REGISTRATION-READINESS.md');
      expect(file.existsSync(), isTrue);
      final text = file.readAsStringSync();

      for (final required in [
        'Legal entity name',
        'DBA',
        'Registered agent',
        'Principal business address',
        'EIN',
        'Business bank account',
        'IP and asset ownership',
      ]) {
        expect(text, contains(required), reason: '$required missing');
      }
    });

    test('launch docs do not keep stale bundle ids as active instructions', () {
      final launchDocs = [
        File('docs/IPHONE-LAUNCH-READINESS.md'),
        File('docs/APP-STORE-METADATA.md'),
        File('docs/RELEASE-SIGNING.md'),
        File('docs/release/BL-01-02-3.2-xcode-automatic-signing.md'),
        File(
          'docs/release/BL-01-02-5.2-apple-distribution-app-store-connect.md',
        ),
      ];

      for (final file in launchDocs) {
        expect(file.existsSync(), isTrue, reason: file.path);
        final text = file.readAsStringSync();
        expect(text, isNot(contains('com.mitoosa.app')), reason: file.path);
        expect(
          text,
          isNot(contains('com.chicademy.mitoosa')),
          reason: file.path,
        );
      }
    });
  });
}
