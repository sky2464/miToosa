import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics_consent_service.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';

void main() {
  group('bootstrapAnalyticsConsent @smoke T-001', () {
    test('loads preference before enabling collection', () async {
      final preferences = FakePrivacyPreferencesRepository()..storedValue = false;
      final adapter = RecordingAnalyticsConsentAdapter();
      final service = AnalyticsConsentService(adapter);

      await bootstrapAnalyticsConsent(
        preferences: preferences,
        consentService: service,
      );

      expect(adapter.callLog, ['setConsent', 'setAnalyticsCollectionEnabled']);
      expect(adapter.lastCollectionEnabled, isFalse);
      expect(adapter.lastAnalyticsStorage, isFalse);
    });
  });

  group('AnalyticsConsentService @smoke T-002', () {
    test('grants analytics storage only and denies all ad flags when enabled', () async {
      final adapter = RecordingAnalyticsConsentAdapter();
      final service = AnalyticsConsentService(adapter);

      await service.applyFromPreference(true);

      expect(adapter.lastAnalyticsStorage, isTrue);
      expect(adapter.lastAdStorage, isFalse);
      expect(adapter.lastAdUserData, isFalse);
      expect(adapter.lastAdPersonalization, isFalse);
      expect(adapter.lastCollectionEnabled, isTrue);
    });

    test('denies analytics and ad flags when disabled', () async {
      final adapter = RecordingAnalyticsConsentAdapter();
      final service = AnalyticsConsentService(adapter);

      await service.applyFromPreference(false);

      expect(adapter.lastAnalyticsStorage, isFalse);
      expect(adapter.lastAdStorage, isFalse);
      expect(adapter.lastAdUserData, isFalse);
      expect(adapter.lastAdPersonalization, isFalse);
      expect(adapter.lastCollectionEnabled, isFalse);
    });
  });

  group('AnalyticsConsentService @smoke T-003', () {
    test('opt-out survives repository reload', () async {
      final preferences = FakePrivacyPreferencesRepository();
      final adapter = RecordingAnalyticsConsentAdapter();
      final service = AnalyticsConsentService(adapter);

      await preferences.setAnalyticsEnabled(false);
      await bootstrapAnalyticsConsent(
        preferences: preferences,
        consentService: service,
      );

      final adapterAfterReload = RecordingAnalyticsConsentAdapter();
      final serviceAfterReload = AnalyticsConsentService(adapterAfterReload);
      await bootstrapAnalyticsConsent(
        preferences: preferences,
        consentService: serviceAfterReload,
      );

      expect(adapterAfterReload.lastCollectionEnabled, isFalse);
      expect(adapterAfterReload.lastAnalyticsStorage, isFalse);
    });
  });
}
