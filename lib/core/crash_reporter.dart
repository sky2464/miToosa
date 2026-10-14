/// Privacy-bounded crash and nonfatal reporting boundary (BL-37).
library;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

CrashReporter? _boundCrashReporter;

void bindCrashReporter(CrashReporter reporter) {
  _boundCrashReporter = reporter;
}

CrashReporter get boundCrashReporter =>
    _boundCrashReporter ?? NoopCrashReporter();

/// Whitelisted nonfatal categories — no arbitrary user strings.
enum CrashNonfatalCategory {
  startupRecovery,
  contentLoad,
  persistence,
  engagement,
}

abstract class CrashReporter {
  Future<void> setCollectionEnabled(bool enabled);

  Future<void> recordFatal(Object error, StackTrace stack);

  Future<void> reportNonfatal(
    CrashNonfatalCategory category, {
    Object? error,
    StackTrace? stack,
  });
}

String sanitizeCrashMessage(Object? error) {
  final raw = error?.toString() ?? 'unknown';
  if (raw.length <= 200) return raw;
  return '${raw.substring(0, 200)}…';
}

class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;
  bool _collectionEnabled = true;

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    _collectionEnabled = enabled;
    await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> recordFatal(Object error, StackTrace stack) async {
    if (!_collectionEnabled) return;
    await _crashlytics.recordError(
      sanitizeCrashMessage(error),
      stack,
      fatal: true,
    );
  }

  @override
  Future<void> reportNonfatal(
    CrashNonfatalCategory category, {
    Object? error,
    StackTrace? stack,
  }) async {
    if (!_collectionEnabled) return;
    await _crashlytics.setCustomKey('category', category.name);
    await _crashlytics.recordError(
      sanitizeCrashMessage(error ?? category.name),
      stack ?? StackTrace.current,
      fatal: false,
    );
  }
}

class NoopCrashReporter implements CrashReporter {
  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> recordFatal(Object error, StackTrace stack) async {}

  @override
  Future<void> reportNonfatal(
    CrashNonfatalCategory category, {
    Object? error,
    StackTrace? stack,
  }) async {}
}

/// Records reporter calls for deterministic tests.
class RecordingCrashReporter implements CrashReporter {
  final List<String> callLog = [];
  bool? lastCollectionEnabled;
  CrashNonfatalCategory? lastNonfatalCategory;
  Object? lastFatalError;
  bool _collectionEnabled = true;

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    callLog.add('setCollectionEnabled');
    lastCollectionEnabled = enabled;
    _collectionEnabled = enabled;
  }

  @override
  Future<void> recordFatal(Object error, StackTrace stack) async {
    if (!_collectionEnabled) return;
    callLog.add('recordFatal');
    lastFatalError = error;
  }

  @override
  Future<void> reportNonfatal(
    CrashNonfatalCategory category, {
    Object? error,
    StackTrace? stack,
  }) async {
    if (!_collectionEnabled) return;
    callLog.add('reportNonfatal');
    lastNonfatalCategory = category;
  }
}
