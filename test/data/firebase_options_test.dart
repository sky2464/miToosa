import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/firebase_options.dart';

void main() {
  test('placeholder firebase options throws a clear unsupported error', () {
    expect(
      () => DefaultFirebaseOptions.currentPlatform,
      throwsA(
        isA<UnsupportedError>().having(
          (error) => error.message,
          'message',
          contains('flutterfire configure'),
        ),
      ),
    );
  });
}
