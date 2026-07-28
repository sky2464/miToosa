import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics_consent_service.dart';
import '../../data/privacy_preferences_repository.dart';

/// Orchestrates persisted analytics preference and Firebase consent application.
class AnalyticsPrivacyController {
  AnalyticsPrivacyController({
    required IPrivacyPreferencesRepository preferences,
    required AnalyticsConsentService consentService,
  }) : _preferences = preferences,
       _consentService = consentService;

  final IPrivacyPreferencesRepository _preferences;
  final AnalyticsConsentService _consentService;

  Future<bool> loadEnabled() => _preferences.isAnalyticsEnabled();

  Future<void> setEnabled(bool enabled) async {
    await _preferences.setAnalyticsEnabled(enabled);
    await _consentService.applyFromPreference(enabled);
  }
}

final privacyPreferencesRepositoryProvider =
    Provider<IPrivacyPreferencesRepository>((ref) {
      return boundPrivacyPreferencesRepository;
    });

final analyticsConsentServiceProvider = Provider<AnalyticsConsentService>((ref) {
  return AnalyticsConsentService(FirebaseAnalyticsConsentAdapter());
});

final analyticsPrivacyControllerProvider = Provider<AnalyticsPrivacyController>((
  ref,
) {
  return AnalyticsPrivacyController(
    preferences: ref.watch(privacyPreferencesRepositoryProvider),
    consentService: ref.watch(analyticsConsentServiceProvider),
  );
});
