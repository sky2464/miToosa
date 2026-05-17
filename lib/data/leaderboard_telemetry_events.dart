/// BL-04 — Stable telemetry event names for the leaderboard feature.
///
/// These constants are referenced today only by the pre-gate
/// foundation tests; the runtime emission wiring lands in Wave-3 of
/// the BL-04 build (`telemetryRepositoryProvider.record(...)`) once
/// the playtest gate clears and BL-03 is ✅ Done.
///
/// Pinning the names now serves three goals:
///   1. Cross-platform contract: the Flutter client and the Cloud
///      Function will both emit (or accept) these strings — keep them
///      in lockstep by referencing this file.
///   2. Analytics dashboard pre-build: GA4 + the in-house Hive
///      telemetry repository can be configured with the event taxonomy
///      before the implementation lands, avoiding a rush at gate
///      release.
///   3. Test stability: tests for the future repository can assert
///      against these constants instead of magic strings, so renaming
///      an event is a single-file change.
///
/// Naming convention: snake_case, lowercase ASCII, no whitespace,
/// prefix `leaderboard_` for namespacing. The format test in
/// `test/data/leaderboard_telemetry_events_test.dart` enforces this.
library;

/// Static namespace holding all BL-04 telemetry event names.
abstract final class LeaderboardTelemetryEvents {
  LeaderboardTelemetryEvents._();

  /// Fired when the leaderboard screen is opened. Properties (added by
  /// the emitter): `{ scope: 'global'|'friends'|'local' }`. Used to
  /// measure feature engagement and to validate the social-motivation
  /// gate signal post-launch.
  static const String viewOpen = 'leaderboard_view_open';

  /// Fired when a client write to `leaderboard_entries/{playerId}`
  /// succeeds (AC-001). Properties: `{ score, week }`.
  static const String submitSuccess = 'leaderboard_submit_success';

  /// Fired when the client preflight or the Firestore Security Rule
  /// throttles a write (AC-008). The write is dropped — no doc
  /// mutation. Properties: `{ secondsSinceLast }`.
  static const String submitThrottled = 'leaderboard_submit_throttled';

  /// Fired when the client preflight or the Cloud Function rejects a
  /// write because of validation failure (negative score, exceeds
  /// hard ceiling, malformed inputs). Properties:
  /// `{ field, reason }`.
  static const String validationFailed = 'leaderboard_validation_failed';

  /// Fired server-side (by the Cloud Function) when a write is
  /// accepted but clamped to `serverMaxXp` because the requested score
  /// exceeded the audit-log total (AC-004). Properties:
  /// `{ requestedScore, clampedScore }`. The client receives this via
  /// the next snapshot update; analytics ingestion is server-direct.
  static const String submitClamped = 'leaderboard_submit_clamped';

  /// Fired when the player toggles the local opt-out preference
  /// (AC-012). Properties: `{ optedOut: bool }`. The opt-out lives in
  /// the `leaderboard_prefs` Hive box, NOT in `PlayerProgress`.
  static const String optOutToggled = 'leaderboard_opt_out_toggled';

  /// Fired when the `leaderboard_writes_enabled` Remote Config flag
  /// flips to `false` and the client falls back to cached / read-only
  /// mode (AC-009). Properties: `{ source: 'kill_switch' }`.
  static const String writesDisabled = 'leaderboard_writes_disabled';

  /// All event names defined by this module. Used by the format test
  /// and by future tooling that needs to register the full taxonomy
  /// with GA4 or a downstream analytics pipeline.
  static const List<String> all = [
    viewOpen,
    submitSuccess,
    submitThrottled,
    validationFailed,
    submitClamped,
    optOutToggled,
    writesDisabled,
  ];
}
