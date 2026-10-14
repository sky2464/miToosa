import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/crash_reporter.dart';

void main() {
  group('RecordingCrashReporter', () {
    test('disabling collection skips fatal reports', () async {
      final reporter = RecordingCrashReporter();
      await reporter.setCollectionEnabled(false);
      await reporter.recordFatal(StateError('test'), StackTrace.current);
      expect(reporter.callLog, ['setCollectionEnabled']);
    });

    test('records nonfatal with category', () async {
      final reporter = RecordingCrashReporter();
      await reporter.reportNonfatal(CrashNonfatalCategory.persistence);
      expect(reporter.lastNonfatalCategory, CrashNonfatalCategory.persistence);
    });
  });

  group('sanitizeCrashMessage', () {
    test('truncates long messages', () {
      final long = List.filled(250, 'x').join();
      final sanitized = sanitizeCrashMessage(long);
      expect(sanitized.length, lessThanOrEqualTo(201));
    });
  });
}
