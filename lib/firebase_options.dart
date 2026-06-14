import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw _unsupportedPlatform('web');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw _unsupportedPlatform(defaultTargetPlatform.name);
    }
  }

  static UnsupportedError _unsupportedPlatform(String platform) {
    return UnsupportedError(
      'DefaultFirebaseOptions are only configured for iOS. '
      'Run: flutterfire configure --project=mitoosa-2121b --platforms=ios '
      '--ios-bundle-id=dev.atoosa.mitoosa (requested platform: $platform).',
    );
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCe46TYy3mjgn0kWYe8DQfEHZXUBUwq1cs',
    appId: '1:567413645788:ios:03903b33a13cb4f4fc6f19',
    messagingSenderId: '567413645788',
    projectId: 'mitoosa-2121b',
    storageBucket: 'mitoosa-2121b.firebasestorage.app',
    iosBundleId: 'dev.atoosa.mitoosa',
  );
}
