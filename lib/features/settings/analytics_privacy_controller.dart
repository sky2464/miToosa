import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/analytics_consent_service.dart';
import '../../core/crash_diagnostics_service.dart';
import '../../core/crash_reporter.dart';
import '../../data/privacy_preferences_repository.dart';
import '../../data/telemetry_provider.dart';

/// Orchestrates persisted analytics preference and Firebase consent application.
class AnalyticsPrivacyController {
  AnalyticsPrivacyController({
    required IPrivacyPreferencesRepository preferences,
    required AnalyticsConsentService consentService,
    CrashDiagnosticsService? crashDiagnostics,
    CrashReporter? crashReporter,
  }) : _preferences = preferences,
       _consentService = consentService,
       _crashDiagnostics = crashDiagnostics,
       _crashReporter = crashReporter;

  final IPrivacyPreferencesRepository _preferences;
  final AnalyticsConsentService _consentService;
  final CrashDiagnosticsService? _crashDiagnostics;
  final CrashReporter? _crashReporter;

  Future<bool> loadEnabled() => _preferences.isAnalyticsEnabled();

  Future<void> setEnabled(bool enabled) async {
    await _preferences.setAnalyticsEnabled(enabled);
    await _consentService.applyFromPreference(enabled);
    await _crashDiagnostics?.applyFromPreference(enabled);
    await _crashReporter?.setCollectionEnabled(enabled);
  }
}

final privacyPreferencesRepositoryProvider =
    Provider<IPrivacyPreferencesRepository>((ref) {
      return boundPrivacyPreferencesRepository;
    });

final analyticsConsentServiceProvider = Provider<AnalyticsConsentService>((
  ref,
) {
  return AnalyticsConsentService(FirebaseAnalyticsConsentAdapter());
});

final crashDiagnosticsServiceProvider = Provider<CrashDiagnosticsService?>((
  ref,
) {
  if (!kFirebaseEnabled) return null;
  return CrashDiagnosticsService(FirebaseCrashDiagnosticsAdapter());
});

final analyticsPrivacyControllerProvider = Provider<AnalyticsPrivacyController>(
  (ref) {
    return AnalyticsPrivacyController(
      preferences: ref.watch(privacyPreferencesRepositoryProvider),
      consentService: ref.watch(analyticsConsentServiceProvider),
      crashDiagnostics: ref.watch(crashDiagnosticsServiceProvider),
      crashReporter: kFirebaseEnabled ? boundCrashReporter : null,
    );
  },
);
