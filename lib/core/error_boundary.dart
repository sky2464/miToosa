import 'package:flutter/foundation.dart';

import 'crash_reporter.dart';

bool _reportingNestedError = false;

/// Routes framework and async errors through [reporter] while preserving
/// prior platform handlers.
void installErrorBoundary(CrashReporter reporter) {
  final previousFlutterHandler = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    _safeReport(() => reporter.recordFatal(
          details.exception,
          details.stack ?? StackTrace.current,
        ));
    previousFlutterHandler?.call(details);
  };

  final previousPlatformHandler = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    _safeReport(() => reporter.recordFatal(error, stack));
    if (previousPlatformHandler != null) {
      return previousPlatformHandler(error, stack);
    }
    return false;
  };
}

void _safeReport(Future<void> Function() report) {
  if (_reportingNestedError) return;
  _reportingNestedError = true;
  report().whenComplete(() => _reportingNestedError = false);
}

/// Debug-only nonfatal smoke path — not exposed in release Settings UI.
Future<void> runCrashReporterNonfatalSmoke(CrashReporter reporter) {
  return reporter.reportNonfatal(CrashNonfatalCategory.startupRecovery);
}
