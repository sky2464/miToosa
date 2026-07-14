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

    test('launch readiness marks FlutterFire configure complete', () {
      final file = File('docs/IPHONE-LAUNCH-READINESS.md');
      final text = file.readAsStringSync();

      expect(
        text,
        contains(
          '[x] Replace placeholder `lib/firebase_options.dart` by running `flutterfire configure`',
        ),
      );
      expect(
        text,
        contains(
          '[x] Confirm generated config replaces `lib/firebase_options.dart`.',
        ),
      );
      expect(
        text,
        contains(
          '[x] Confirm `ios/Runner/GoogleService-Info.plist` exists locally',
        ),
      );
    });

    test('metadata draft includes App Store submission fields', () {
      final file = File('docs/APP-STORE-METADATA.md');
      expect(file.existsSync(), isTrue);
      final text = file.readAsStringSync();

      for (final required in [
        'Name',
        'Subtitle',
        'Description',
        'Keywords',
        "What's New",
        'Category',
        'Privacy Policy URL',
        'Support URL',
        'Age rating',
        'Export compliance',
        'Screenshot capture plan',
      ]) {
        expect(text, contains(required), reason: '$required missing');
      }
    });

    test('metadata uses manual-deferred URL placeholders not bare TODO', () {
      final text = File('docs/APP-STORE-METADATA.md').readAsStringSync();

      expect(text, contains('manual-deferred'));
      expect(text, isNot(contains('TODO: publish and paste final URL')));
      expect(text, contains('Privacy Policy URL'));
      expect(text, contains('Support URL'));
    });

    test(
      'privacy policy aligns with Firebase and Google Analytics launch posture',
      () {
        final file = File('docs/PRIVACY-POLICY.md');
        expect(file.existsSync(), isTrue);
        final text = file.readAsStringSync();

        expect(text, contains('FIREBASE_ENABLED=true'));
        expect(text, anyOf(contains('Firebase'), contains('Google Analytics')));
        expect(text, contains('Hive'));
        expect(text, isNot(contains('does not make any network requests')));
        expect(text, isNot(contains('No analytics sent to any server')));
      },
    );

    test('support page exists with contact channels and cross-links', () {
      final file = File('docs/SUPPORT.md');
      expect(file.existsSync(), isTrue);
      final text = file.readAsStringSync();

      expect(text, contains('sky2464@gmail.com'));
      expect(text, contains('Response expectations'));
      expect(text, contains('PRIVACY-POLICY.md'));
      expect(text, contains('USER-GUIDE.md'));
    });

    test(
      'screenshot checklist lists required scenes sizes and quality bar',
      () {
        final text = File('docs/APP-STORE-METADATA.md').readAsStringSync();

        for (final scene in [
          'Onboarding',
          'Tracks',
          'Gameplay',
          'Progress',
          'Settings',
        ]) {
          expect(text, contains(scene), reason: '$scene scene missing');
        }
        expect(text, contains('6.7'));
        expect(text, contains('Quality bar'));
        expect(text, contains('debug banners'));
      },
    );

    test(
      'launch docs cross-link BL-26 artifacts and keep manual gates open',
      () {
        final launchText = File('docs/LAUNCH.md').readAsStringSync();
        final readinessText = File(
          'docs/IPHONE-LAUNCH-READINESS.md',
        ).readAsStringSync();

        for (final artifact in [
          'APP-STORE-METADATA.md',
          'PRIVACY-POLICY.md',
          'SUPPORT.md',
        ]) {
          expect(launchText, contains(artifact));
          expect(readinessText, contains(artifact));
        }

        expect(launchText, contains('manual-deferred'));
        expect(readinessText, contains('manual-deferred'));
        expect(
          launchText,
          isNot(contains('[x] Publish public privacy/support URLs')),
        );
      },
    );

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

    test(
      'TestFlight QA artifacts cover required scenarios and are cross-linked',
      () {
        final checklist = File('docs/qa/iphone-testflight-qa-checklist.md');
        final evidenceTemplate = File(
          'docs/qa/iphone-testflight-evidence-template.md',
        );

        expect(checklist.existsSync(), isTrue);
        expect(evidenceTemplate.existsSync(), isTrue);

        final checklistText = checklist.readAsStringSync();
        for (final required in [
          'Cold Launch',
          'Onboarding',
          'Full Gameplay Session',
          'Share Bonus',
          'Offline Mode',
          'VoiceOver',
          'Dynamic Type',
          'Wedge Copy',
          'Force-Quit Persistence',
          'Settings and Support Links',
          'Firebase DebugView',
        ]) {
          expect(
            checklistText,
            contains(required),
            reason: '$required missing',
          );
        }

        final evidenceText = evidenceTemplate.readAsStringSync();
        for (final required in [
          'Build number',
          'Device model',
          'iOS version',
          'Tester',
          'Date',
          'AC ID',
          'Pass / Fail',
        ]) {
          expect(evidenceText, contains(required), reason: '$required missing');
        }

        for (final file in [
          File('docs/IPHONE-LAUNCH-READINESS.md'),
          File('docs/LAUNCH.md'),
          File('docs/qa/wedge-qa-checklist.md'),
        ]) {
          expect(
            file.readAsStringSync(),
            contains('iphone-testflight-qa-checklist.md'),
            reason: '${file.path} missing TestFlight QA checklist link',
          );
        }
      },
    );
  });
}
