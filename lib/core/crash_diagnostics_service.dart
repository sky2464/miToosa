import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../data/privacy_preferences_repository.dart';
import 'crash_reporter.dart';

abstract class CrashDiagnosticsAdapter {
  Future<void> setCrashlyticsCollectionEnabled(bool enabled);
}

class FirebaseCrashDiagnosticsAdapter implements CrashDiagnosticsAdapter {
  FirebaseCrashDiagnosticsAdapter([FirebaseCrashlytics? crashlytics])
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) {
    return _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }
}

class CrashDiagnosticsService {
  CrashDiagnosticsService(this._adapter);

  final CrashDiagnosticsAdapter _adapter;

  Future<void> applyFromPreference(bool diagnosticsEnabled) {
    return _adapter.setCrashlyticsCollectionEnabled(diagnosticsEnabled);
  }
}

class RecordingCrashDiagnosticsAdapter implements CrashDiagnosticsAdapter {
  final List<String> callLog = [];
  bool? lastEnabled;

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    callLog.add('setCrashlyticsCollectionEnabled');
    lastEnabled = enabled;
  }
}

Future<void> bootstrapCrashDiagnostics({
  required IPrivacyPreferencesRepository preferences,
  required CrashDiagnosticsService diagnosticsService,
  required CrashReporter reporter,
}) async {
  final enabled = await preferences.isAnalyticsEnabled();
  await diagnosticsService.applyFromPreference(enabled);
  await reporter.setCollectionEnabled(enabled);
}
