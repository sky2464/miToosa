import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/core/tutorial/tutorial_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            return '.';
          },
        );
  });

  test('tutorial definitions cover all tracks and puzzle rules', () async {
    final provider = ContentProvider();
    await provider.init();
    expect(provider.tutorials.definitions.length, 23);
    provider.tutorials.validateAgainstTracks(provider.tracks);
  });

  test('loads tutorials asset independently', () async {
    final repo = TutorialRepository();
    await repo.loadFromAsset('assets/content/tutorials.json');
    expect(repo.forTrack('track_1'), isNotNull);
  });
}
