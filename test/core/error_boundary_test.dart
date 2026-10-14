import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/crash_reporter.dart';
import 'package:mitoosa/core/error_boundary.dart';

void main() {
  test('installErrorBoundary forwards Flutter errors to reporter', () async {
    final reporter = RecordingCrashReporter();
    final previous = FlutterError.onError;
    installErrorBoundary(reporter);

    FlutterError.onError?.call(
      FlutterErrorDetails(exception: StateError('boundary-test')),
    );

    expect(reporter.callLog, contains('recordFatal'));
    FlutterError.onError = previous;
  });

  test('nonfatal smoke invokes reporter', () async {
    final reporter = RecordingCrashReporter();
    await runCrashReporterNonfatalSmoke(reporter);
    expect(reporter.callLog, contains('reportNonfatal'));
  });
}
