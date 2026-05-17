/// BL-04 — Tiny leaderboard preferences Hive box (pre-gate foundation).
///
/// Per spec §1.3 _Out of Scope_:
/// > Modifying `PlayerProgress` schema — v1 adds a leaderboard
/// > `OptOut` preference via a *new* Hive box (`leaderboard_prefs`),
/// > NOT a `PlayerProgress` schema bump, to avoid touching the v7
/// > adapter.
///
/// This module ships just the box plumbing today (pre-gate):
///  - Box name constant.
///  - Opt-out getter/setter (AC-012).
///  - Open/close helpers.
///
/// No Firestore wiring, no Riverpod provider — those land in Wave 3
/// of the BL-04 build once the playtest gate clears. By isolating the
/// persistence in its own box we keep `PlayerProgress` (v6 schema +
/// `PlayerProgressAdapter`) untouched and migration-free.
///
/// Storage shape: a single key (`optedOut`) holding a `bool`. Future
/// preferences (e.g. preferred scope, display-name override slot when
/// custom names ship) extend the same box without a schema bump.
library;

import 'package:hive/hive.dart';

/// Hive box name. Stable across releases. The box uses dynamic
/// typing (`Box<dynamic>`) because the values are primitives (bool
/// today; future fields may be int / String) — no custom adapter
/// needed.
const String kLeaderboardPrefsBoxName = 'leaderboard_prefs';

/// Storage key for the per-user opt-out preference (AC-012).
/// When `true`, the future repository will skip leaderboard writes
/// AND elide the player from displayed rankings.
const String kLeaderboardOptOutKey = 'optedOut';

/// Thin accessor around the `leaderboard_prefs` Hive box. Constructed
/// with an already-open [Box]; tests use a temp-directory box, the
/// future repository will use the box opened by
/// `HivePersistenceProvider`.
///
/// Why a wrapper instead of raw `box.get`? Three reasons:
///   1. Type-safety at the call site — the box itself is `dynamic`.
///   2. A single place to default-on-absent (returns `false` —
///      participation is opt-out, AC-012).
///   3. A migration seam: when v2 grows additional keys, callers do
///      not need to learn the box layout.
class LeaderboardPrefs {
  final Box<dynamic> _box;

  LeaderboardPrefs(this._box);

  /// `true` when the player has opted out of leaderboard
  /// participation. Defaults to `false` (participating) when the key
  /// has never been written.
  bool get optedOut {
    final raw = _box.get(kLeaderboardOptOutKey, defaultValue: false);
    if (raw is bool) return raw;
    // Corrupt value: treat as not-opted-out (fail-open for
    // participation, fail-closed would silently de-list players).
    return false;
  }

  /// Persists [value]. The future opt-out toggle in Settings flows
  /// through this setter. Emits no telemetry — the caller layers that
  /// on (via `LeaderboardTelemetryEvents.optOutToggled`).
  Future<void> setOptedOut(bool value) async {
    await _box.put(kLeaderboardOptOutKey, value);
  }

  /// Clears all stored leaderboard preferences. Used by the
  /// "Reset progress" flow if/when wired.
  Future<void> clear() async {
    await _box.clear();
  }
}

/// Opens the `leaderboard_prefs` Hive box. Idempotent — returns the
/// already-open box if it has been opened earlier in this process.
///
/// The production wiring will call this from
/// `HivePersistenceProvider.ensureBoxesOpen()` once BL-04 enters
/// Active Cycle; tests open the box directly against a temp dir.
Future<Box<dynamic>> openLeaderboardPrefsBox() async {
  if (Hive.isBoxOpen(kLeaderboardPrefsBoxName)) {
    return Hive.box<dynamic>(kLeaderboardPrefsBoxName);
  }
  return Hive.openBox<dynamic>(kLeaderboardPrefsBoxName);
}
