import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw _placeholderError();
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw _placeholderError();
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Fuchsia is not supported by this placeholder configuration.',
        );
    }
  }

  static UnsupportedError _placeholderError() {
    return UnsupportedError(
      'firebase_options.dart placeholder in use. Run: flutterfire configure --project=<your-firebase-project-id>',
    );
  }
}
