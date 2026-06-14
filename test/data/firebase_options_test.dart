import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('iOS options reference configured Firebase project', () {
      const options = DefaultFirebaseOptions.ios;

      expect(options.projectId, 'mitoosa-2121b');
      expect(options.iosBundleId, 'dev.atoosa.mitoosa');
      expect(options.appId, '1:567413645788:ios:03903b33a13cb4f4fc6f19');
      expect(options.apiKey, isNotEmpty);
    });

    test('non-iOS platforms throw a clear unsupported error', () {
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(
          isA<UnsupportedError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('only configured for iOS'),
              contains('flutterfire configure'),
            ),
          ),
        ),
      );
    });

    test('GoogleService-Info.plist exists locally after configure', () {
      final plist = File('ios/Runner/GoogleService-Info.plist');
      expect(plist.existsSync(), isTrue);
      expect(
        plist.readAsStringSync(),
        allOf(
          contains('dev.atoosa.mitoosa'),
          contains('mitoosa-2121b'),
        ),
      );
    });

    test('GoogleService-Info.plist is gitignored', () {
      final gitignore = File('.gitignore');
      expect(gitignore.readAsStringSync(), contains('**/GoogleService-Info.plist'));
    });
  });
}
