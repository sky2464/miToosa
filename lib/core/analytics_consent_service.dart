import 'package:firebase_analytics/firebase_analytics.dart';

import '../data/privacy_preferences_repository.dart';

/// Boundary for Firebase analytics consent and collection calls.
abstract class AnalyticsConsentAdapter {
  Future<void> setConsent({
    required bool analyticsStorageConsentGranted,
    required bool adStorageConsentGranted,
    required bool adUserDataConsentGranted,
    required bool adPersonalizationSignalsConsentGranted,
  });

  Future<void> setAnalyticsCollectionEnabled(bool enabled);
}

class FirebaseAnalyticsConsentAdapter implements AnalyticsConsentAdapter {
  FirebaseAnalyticsConsentAdapter([FirebaseAnalytics? analytics])
    : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  @override
  Future<void> setConsent({
    required bool analyticsStorageConsentGranted,
    required bool adStorageConsentGranted,
    required bool adUserDataConsentGranted,
    required bool adPersonalizationSignalsConsentGranted,
  }) {
    return _analytics.setConsent(
      analyticsStorageConsentGranted: analyticsStorageConsentGranted,
      adStorageConsentGranted: adStorageConsentGranted,
      adUserDataConsentGranted: adUserDataConsentGranted,
      adPersonalizationSignalsConsentGranted:
          adPersonalizationSignalsConsentGranted,
    );
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) {
    return _analytics.setAnalyticsCollectionEnabled(enabled);
  }
}

/// Applies analytics preference with ad-related consent permanently denied.
class AnalyticsConsentService {
  AnalyticsConsentService(this._adapter);

  final AnalyticsConsentAdapter _adapter;

  Future<void> applyFromPreference(bool analyticsEnabled) async {
    await _adapter.setConsent(
      analyticsStorageConsentGranted: analyticsEnabled,
      adStorageConsentGranted: false,
      adUserDataConsentGranted: false,
      adPersonalizationSignalsConsentGranted: false,
    );
    await _adapter.setAnalyticsCollectionEnabled(analyticsEnabled);
  }
}

/// Records adapter calls for deterministic tests.
class RecordingAnalyticsConsentAdapter implements AnalyticsConsentAdapter {
  final List<String> callLog = [];
  bool? lastAnalyticsStorage;
  bool? lastAdStorage;
  bool? lastAdUserData;
  bool? lastAdPersonalization;
  bool? lastCollectionEnabled;

  @override
  Future<void> setConsent({
    required bool analyticsStorageConsentGranted,
    required bool adStorageConsentGranted,
    required bool adUserDataConsentGranted,
    required bool adPersonalizationSignalsConsentGranted,
  }) async {
    callLog.add('setConsent');
    lastAnalyticsStorage = analyticsStorageConsentGranted;
    lastAdStorage = adStorageConsentGranted;
    lastAdUserData = adUserDataConsentGranted;
    lastAdPersonalization = adPersonalizationSignalsConsentGranted;
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    callLog.add('setAnalyticsCollectionEnabled');
    lastCollectionEnabled = enabled;
  }
}

/// Bootstrap helper — preference must resolve before collection is enabled.
Future<void> bootstrapAnalyticsConsent({
  required IPrivacyPreferencesRepository preferences,
  required AnalyticsConsentService consentService,
}) async {
  final enabled = await preferences.isAnalyticsEnabled();
  await consentService.applyFromPreference(enabled);
}
