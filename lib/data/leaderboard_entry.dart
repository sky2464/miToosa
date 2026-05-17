/// BL-04 — Immutable leaderboard entry wire model (pre-gate foundation).
///
/// Pure-Dart model with no Firebase dependencies. Mirrors the planned
/// Firestore document shape declared in `docs/archived/spec-BL-04.md`
/// §2.1 (`leaderboard_entries/{playerId}` doc:
/// `{ displayName, score, week, updatedAt, hashedId }`).
///
/// Why pure Dart now (pre-gate):
///  - BL-04 cannot be fully built until BL-03 (Firebase project + App Check)
///    lands and the S1-04 playtest D1≥40% / social-motivation gate clears.
///  - Shipping the model + validator + telemetry constants now de-risks the
///    wire format; once Firebase is wired, `fromJson` becomes the body of
///    `fromFirestore(DocumentSnapshot)` with a trivial adapter.
///  - Tests can pin the contract independent of any Firebase emulator.
///
/// Invariants enforced by [LeaderboardEntry.validate]:
///  - `score` is in `[0, kMaxLeaderboardScore]`.
///  - `displayName` matches the server-minted shape `Pilot_NNNN` OR a
///    permissive alphanumeric+underscore form up to 16 chars (Spec AC-007
///    locks v1 to `Pilot_NNNN`; the broader rule keeps room for the future
///    custom-name story without re-bumping the validator).
///  - `week` is an ISO-week bucket key in `YYYY-Www` format
///    (e.g. `2026-W20`).
///  - `playerId` is non-empty and ≤ 64 chars (Firebase Auth UIDs are 28).
///  - `hashedId`, when present, is a 64-char lowercase hex string
///    (SHA-256 hex digest).
library;

/// Server-enforced maximum legal score. Set to 10× the highest XP a
/// player can plausibly earn in a single ISO week at current economy
/// (Sprint-2 ceiling = ~12,000 XP/week). Acts as a sanity bound; the
/// real per-player ceiling is derived from the `xp_audit_log` by the
/// Cloud Function (AC-004). Above this we hard-reject; below it the
/// Function clamps.
const int kMaxLeaderboardScore = 120000;

/// Regex matching the v1 server-minted display name: `Pilot_NNNN`
/// (4-digit zero-padded counter, AC-007).
final RegExp kPilotDisplayNamePattern = RegExp(r'^Pilot_\d{4}$');

/// Forward-compatible display-name pattern: alphanumeric + underscore,
/// 1–16 chars. v1 disallows user-chosen names but the validator accepts
/// this superset so a future custom-name story does not need a
/// validator-schema migration. The Pilot pattern is a strict subset.
final RegExp kPermissiveDisplayNamePattern = RegExp(r'^[A-Za-z0-9_]{1,16}$');

/// Regex matching the ISO-week bucket key `YYYY-Www`
/// (year 1900–2999, week 01–53). Week 53 is permitted because the ISO
/// 8601 long-year cycle (e.g. 2026 itself is a long year with 53 weeks).
final RegExp kIsoWeekPattern = RegExp(r'^(19|20|21|22|23|24|25|26|27|28|29)\d{2}-W(0[1-9]|[1-4]\d|5[0-3])$');

/// Regex for a SHA-256 hex digest (64 lowercase hex chars).
final RegExp kSha256HexPattern = RegExp(r'^[0-9a-f]{64}$');

/// Result of [LeaderboardEntry.validate]. Holds the offending field
/// name and a human-readable reason so callers (client preflight and
/// server-side Cloud Function alike) can branch on a stable error key.
class LeaderboardValidationError {
  final String field;
  final String message;

  const LeaderboardValidationError(this.field, this.message);

  @override
  String toString() => 'LeaderboardValidationError($field: $message)';
}

/// Immutable leaderboard entry. One row in `leaderboard_entries/{playerId}`.
class LeaderboardEntry {
  /// Stable per-player ID — equals the Firebase Auth UID server-side.
  /// Never displayed to other clients; see [hashedId] for the public
  /// projection. Empty / null `playerId` is rejected by [validate].
  final String playerId;

  /// Auto-generated pseudonym (`Pilot_NNNN`). v1 disallows custom names.
  final String displayName;

  /// Player's current weekly XP. Server clamps to the audit-log total
  /// (AC-004); the client only computes a candidate value.
  final int score;

  /// ISO-week bucket key (e.g. `2026-W20`). Computed by
  /// [LeaderboardEntry.isoWeekOf]; never client-provided as free text.
  final String week;

  /// Server timestamp of the last write. Stored as UTC milliseconds
  /// since epoch in the wire model; the repository layer converts to
  /// Firestore `serverTimestamp()` on submit.
  final DateTime updatedAt;

  /// Public projection of `playerId` exposed to other clients.
  /// SHA-256 of `uid + project_pepper`, lowercase hex.
  /// Null on local-constructed entries pre-mint.
  final String? hashedId;

  const LeaderboardEntry({
    required this.playerId,
    required this.displayName,
    required this.score,
    required this.week,
    required this.updatedAt,
    this.hashedId,
  });

  /// Serializes to a JSON-shaped map. `updatedAt` is encoded as
  /// `int` milliseconds since epoch UTC for stable cross-platform
  /// round-tripping (Firestore Timestamps serialize to `int` here;
  /// the repository converts at the boundary).
  Map<String, Object?> toJson() {
    return {
      'playerId': playerId,
      'displayName': displayName,
      'score': score,
      'week': week,
      'updatedAt': updatedAt.toUtc().millisecondsSinceEpoch,
      if (hashedId != null) 'hashedId': hashedId,
    };
  }

  /// Inverse of [toJson]. Throws [FormatException] on missing required
  /// fields or wrong types — never silently coerces. The repository
  /// layer wraps this for `DocumentSnapshot.data()`.
  factory LeaderboardEntry.fromJson(Map<dynamic, dynamic> json) {
    final playerId = json['playerId'];
    final displayName = json['displayName'];
    final score = json['score'];
    final week = json['week'];
    final updatedAt = json['updatedAt'];
    final hashedId = json['hashedId'];

    if (playerId is! String) {
      throw const FormatException('LeaderboardEntry.playerId must be a string');
    }
    if (displayName is! String) {
      throw const FormatException(
          'LeaderboardEntry.displayName must be a string');
    }
    if (score is! int) {
      throw const FormatException('LeaderboardEntry.score must be an int');
    }
    if (week is! String) {
      throw const FormatException('LeaderboardEntry.week must be a string');
    }
    if (updatedAt is! int) {
      throw const FormatException(
          'LeaderboardEntry.updatedAt must be an int (millis since epoch)');
    }
    if (hashedId != null && hashedId is! String) {
      throw const FormatException(
          'LeaderboardEntry.hashedId must be a string when present');
    }

    return LeaderboardEntry(
      playerId: playerId,
      displayName: displayName,
      score: score,
      week: week,
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
      hashedId: hashedId as String?,
    );
  }

  /// Returns a copy with the named fields replaced. Standard immutable
  /// pattern used throughout the miToosa engine layer.
  LeaderboardEntry copyWith({
    String? playerId,
    String? displayName,
    int? score,
    String? week,
    DateTime? updatedAt,
    String? hashedId,
  }) {
    return LeaderboardEntry(
      playerId: playerId ?? this.playerId,
      displayName: displayName ?? this.displayName,
      score: score ?? this.score,
      week: week ?? this.week,
      updatedAt: updatedAt ?? this.updatedAt,
      hashedId: hashedId ?? this.hashedId,
    );
  }

  /// Validates the entry against the same invariants the Cloud Function
  /// and Firestore Security Rules will enforce server-side. Returns
  /// `null` when valid, or the first [LeaderboardValidationError]
  /// encountered. Order of checks is stable so test assertions can pin
  /// to a specific failure.
  ///
  /// Validation is deliberately **not** in the constructor: the wire
  /// model accepts whatever JSON Firestore returns (so a server-side
  /// bug does not crash the client at deserialize time). Callers
  /// validate explicitly before submitting or before trusting a
  /// received entry.
  static LeaderboardValidationError? validate(LeaderboardEntry e) {
    if (e.playerId.isEmpty) {
      return const LeaderboardValidationError(
          'playerId', 'must be non-empty');
    }
    if (e.playerId.length > 64) {
      return const LeaderboardValidationError(
          'playerId', 'must be ≤ 64 chars (Firebase UIDs are 28)');
    }
    if (!kPermissiveDisplayNamePattern.hasMatch(e.displayName)) {
      return const LeaderboardValidationError(
          'displayName',
          'must match [A-Za-z0-9_]{1,16}; v1 mints Pilot_NNNN');
    }
    if (e.score < 0) {
      return const LeaderboardValidationError(
          'score', 'must be ≥ 0');
    }
    if (e.score > kMaxLeaderboardScore) {
      return const LeaderboardValidationError(
          'score', 'exceeds hard ceiling of $kMaxLeaderboardScore');
    }
    if (!kIsoWeekPattern.hasMatch(e.week)) {
      return const LeaderboardValidationError(
          'week', 'must match ISO-week pattern YYYY-Www (e.g. 2026-W20)');
    }
    if (e.hashedId != null && !kSha256HexPattern.hasMatch(e.hashedId!)) {
      return const LeaderboardValidationError(
          'hashedId', 'must be a 64-char lowercase hex SHA-256 digest');
    }
    return null;
  }

  /// Returns `true` if [validate] passes. Convenience for tests and
  /// guard clauses where the specific error is not needed.
  static bool isValid(LeaderboardEntry e) => validate(e) == null;

  /// Computes the ISO-8601 week bucket key for the given UTC instant.
  ///
  /// Returns `YYYY-Www` where `YYYY` is the **ISO week-numbering year**
  /// (which can differ from the Gregorian year at year boundaries —
  /// e.g. 2027-01-01 is a Friday, so it falls in ISO week 2026-W53)
  /// and `Www` is the zero-padded ISO week number 01..53.
  ///
  /// Reference: ISO 8601 §3.2.2. Implementation follows the standard
  /// algorithm:
  ///   weekNum = (ordinalDay - weekday + 10) / 7
  /// where weekday is Monday=1..Sunday=7.
  static String isoWeekOf(DateTime instant) {
    final utc = instant.toUtc();
    // Day-of-year (1..366).
    final ordinal = utc
            .difference(DateTime.utc(utc.year, 1, 1))
            .inDays +
        1;
    // weekday: Mon=1..Sun=7 (DateTime.weekday already returns this).
    final weekday = utc.weekday;
    var weekNum = ((ordinal - weekday + 10) ~/ 7);
    var year = utc.year;
    if (weekNum < 1) {
      // Belongs to the last week of the previous year.
      year -= 1;
      weekNum = _lastIsoWeekOfYear(year);
    } else if (weekNum > _lastIsoWeekOfYear(year)) {
      // Belongs to week 1 of the next year.
      year += 1;
      weekNum = 1;
    }
    final yyyy = year.toString().padLeft(4, '0');
    final ww = weekNum.toString().padLeft(2, '0');
    return '$yyyy-W$ww';
  }

  /// Number of ISO weeks in a given year: 53 if the year is a "long"
  /// year (Jan 1 is Thursday, or Dec 31 is Thursday, equivalently the
  /// year starts on Thursday OR is a leap year that starts on Wed),
  /// otherwise 52.
  static int _lastIsoWeekOfYear(int year) {
    final jan1 = DateTime.utc(year, 1, 1).weekday;
    final dec31 = DateTime.utc(year, 12, 31).weekday;
    if (jan1 == DateTime.thursday || dec31 == DateTime.thursday) {
      return 53;
    }
    return 52;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeaderboardEntry &&
        other.playerId == playerId &&
        other.displayName == displayName &&
        other.score == score &&
        other.week == week &&
        other.updatedAt.toUtc() == updatedAt.toUtc() &&
        other.hashedId == hashedId;
  }

  @override
  int get hashCode => Object.hash(
        playerId,
        displayName,
        score,
        week,
        updatedAt.toUtc(),
        hashedId,
      );

  @override
  String toString() =>
      'LeaderboardEntry(playerId: $playerId, displayName: $displayName, '
      'score: $score, week: $week, updatedAt: ${updatedAt.toUtc()}, '
      'hashedId: ${hashedId ?? '<unset>'})';
}
