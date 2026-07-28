import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedPreferencesPrivacyPreferencesRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults analytics to enabled when unset (T-001)', () async {
      final repo = await SharedPreferencesPrivacyPreferencesRepository.create();
      expect(await repo.isAnalyticsEnabled(), isTrue);
    });

    test('persists opt-out and survives reload (T-003)', () async {
      final repo = await SharedPreferencesPrivacyPreferencesRepository.create();
      await repo.setAnalyticsEnabled(false);

      final reloaded =
          await SharedPreferencesPrivacyPreferencesRepository.create();
      expect(await reloaded.isAnalyticsEnabled(), isFalse);
    });

    test('re-enabling analytics persists true', () async {
      final repo = await SharedPreferencesPrivacyPreferencesRepository.create();
      await repo.setAnalyticsEnabled(false);
      await repo.setAnalyticsEnabled(true);

      final reloaded =
          await SharedPreferencesPrivacyPreferencesRepository.create();
      expect(await reloaded.isAnalyticsEnabled(), isTrue);
    });
  });

  group('FakePrivacyPreferencesRepository', () {
    test('defaults to enabled', () async {
      final repo = FakePrivacyPreferencesRepository();
      expect(await repo.isAnalyticsEnabled(), isTrue);
    });
  });
}
