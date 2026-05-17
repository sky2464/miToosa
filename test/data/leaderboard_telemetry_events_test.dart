/// BL-04 — Format / stability tests for leaderboard telemetry event names.
///
/// These tests pin the event taxonomy so a careless rename surfaces as
/// a test failure rather than a silent analytics dashboard gap. They
/// also enforce the naming convention (snake_case, leaderboard_ prefix,
/// ASCII, no whitespace).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/leaderboard_telemetry_events.dart';

void main() {
  group('LeaderboardTelemetryEvents — name format conformance', () {
    final snakeCasePattern = RegExp(r'^[a-z][a-z0-9_]*$');

    test('every event is snake_case lowercase ASCII', () {
      for (final name in LeaderboardTelemetryEvents.all) {
        expect(snakeCasePattern.hasMatch(name), isTrue,
            reason: '"$name" violates snake_case rule');
      }
    });

    test('every event has the "leaderboard_" prefix', () {
      for (final name in LeaderboardTelemetryEvents.all) {
        expect(name.startsWith('leaderboard_'), isTrue,
            reason: '"$name" must be prefixed for analytics namespacing');
      }
    });

    test('no event contains whitespace or hyphens', () {
      for (final name in LeaderboardTelemetryEvents.all) {
        expect(name.contains(' '), isFalse,
            reason: '"$name" contains a space');
        expect(name.contains('-'), isFalse,
            reason: '"$name" contains a hyphen (use underscore)');
      }
    });

    test('no event exceeds 40 chars (GA4 event-name limit)', () {
      for (final name in LeaderboardTelemetryEvents.all) {
        expect(name.length, lessThanOrEqualTo(40),
            reason: '"$name" exceeds the GA4 40-char event-name limit');
      }
    });

    test('event names are unique', () {
      final set = LeaderboardTelemetryEvents.all.toSet();
      expect(set.length, equals(LeaderboardTelemetryEvents.all.length),
          reason: 'duplicate event name in LeaderboardTelemetryEvents.all');
    });
  });

  group('LeaderboardTelemetryEvents — stability pinning', () {
    // Each test below pins the exact string. Renaming any of these
    // requires updating the test, which forces a deliberate decision
    // (and a changelog entry, per the spec's observability story).
    test('viewOpen', () {
      expect(LeaderboardTelemetryEvents.viewOpen,
          equals('leaderboard_view_open'));
    });
    test('submitSuccess', () {
      expect(LeaderboardTelemetryEvents.submitSuccess,
          equals('leaderboard_submit_success'));
    });
    test('submitThrottled', () {
      expect(LeaderboardTelemetryEvents.submitThrottled,
          equals('leaderboard_submit_throttled'));
    });
    test('validationFailed', () {
      expect(LeaderboardTelemetryEvents.validationFailed,
          equals('leaderboard_validation_failed'));
    });
    test('submitClamped', () {
      expect(LeaderboardTelemetryEvents.submitClamped,
          equals('leaderboard_submit_clamped'));
    });
    test('optOutToggled', () {
      expect(LeaderboardTelemetryEvents.optOutToggled,
          equals('leaderboard_opt_out_toggled'));
    });
    test('writesDisabled', () {
      expect(LeaderboardTelemetryEvents.writesDisabled,
          equals('leaderboard_writes_disabled'));
    });

    test('all list contains exactly the declared constants', () {
      expect(LeaderboardTelemetryEvents.all, hasLength(7));
      expect(
        LeaderboardTelemetryEvents.all,
        containsAll([
          LeaderboardTelemetryEvents.viewOpen,
          LeaderboardTelemetryEvents.submitSuccess,
          LeaderboardTelemetryEvents.submitThrottled,
          LeaderboardTelemetryEvents.validationFailed,
          LeaderboardTelemetryEvents.submitClamped,
          LeaderboardTelemetryEvents.optOutToggled,
          LeaderboardTelemetryEvents.writesDisabled,
        ]),
      );
    });
  });
}
