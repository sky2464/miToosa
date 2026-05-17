/// BL-04 — Pure score-validation logic (pre-gate foundation).
///
/// This module mirrors the server-side clamp/throttle/ceiling logic the
/// Cloud Function `onLeaderboardWrite` will enforce when BL-03 lands
/// and BL-04 enters Active Cycle. Keeping it pure-Dart serves two
/// goals:
///   1. The same algorithm can be unit-tested today against
///      well-defined edge cases (clock skew, overflow, negative
///      audit-log totals).
///   2. When the Cloud Function is written in TypeScript, this Dart
///      file is a direct algorithmic reference — no protocol drift
///      between client preflight and server enforcement.
///
/// Why mirrored client-side at all? Two reasons:
///   - **Preflight UX:** the client can show a "score-too-high"
///     diagnostic in dev builds before round-tripping to Firestore.
///   - **Offline queue:** when Firestore offline persistence flushes
///     queued writes (AC-010), the client knows which writes the
///     server will clamp and can update local UI optimistically.
///
/// Authority remains server-side — this module is advisory on the
/// client. The Cloud Function is the source of truth (AC-004).
library;

import '../../data/leaderboard_entry.dart';

/// Outcome of a score-submission validation pass. Independent of
/// Firebase types so the same struct can be used in tests, in the
/// repository, and (mentally) in the future TypeScript port.
class LeaderboardScoreValidation {
  /// The score that should actually be persisted. Equals the requested
  /// score when accepted, the clamped maximum when clamped, or
  /// `originalScore` (unchanged) when rejected (caller must decide
  /// whether to drop the write).
  final int effectiveScore;

  /// True when the requested score exceeded `serverMaxXp` and was
  /// reduced. The Cloud Function will emit a `leaderboard_clamp`
  /// telemetry event (AC-004) on this branch.
  final bool didClamp;

  /// True when the throttle interval was violated (writes faster than
  /// `kMinWriteIntervalSeconds` apart per playerId, AC-008). The
  /// repository should drop the write entirely in this case.
  final bool didThrottle;

  /// True when validation failed for a non-recoverable reason
  /// (negative score, exceeds hard ceiling, bad inputs). The repository
  /// should drop the write and surface the [reason] to telemetry.
  final bool didReject;

  /// Human-readable diagnostic; empty when accepted clean. Stable
  /// strings so tests can pin to specific reasons.
  final String reason;

  const LeaderboardScoreValidation({
    required this.effectiveScore,
    required this.didClamp,
    required this.didThrottle,
    required this.didReject,
    required this.reason,
  });

  /// True when the write should proceed (whether or not it was
  /// clamped). False on throttle or reject — those are drop-the-write
  /// outcomes.
  bool get shouldWrite => !didThrottle && !didReject;

  @override
  String toString() =>
      'LeaderboardScoreValidation(effectiveScore: $effectiveScore, '
      'didClamp: $didClamp, didThrottle: $didThrottle, '
      'didReject: $didReject, reason: "$reason")';
}

/// Minimum interval between writes for the same playerId, in seconds.
/// Mirrors the Firestore Security Rule
/// `request.time > resource.data.updatedAt + duration.value(5, 's')`
/// from spec §2.3. The Cloud Function uses the same constant; pinning
/// it here makes test-driven changes coordinated across layers.
const int kMinWriteIntervalSeconds = 5;

/// Validates a candidate leaderboard write against the same rules the
/// server will apply. Pure function — no I/O, no clock dependency
/// beyond the explicit `now` and `lastWriteAt` parameters.
///
/// Inputs:
///   - [requestedScore]: the score the client wants to submit.
///   - [serverMaxXp]: the highest score the audit log can prove this
///     player has legitimately earned this week. Cloud Function reads
///     this from `xp_audit_log/{playerId}/events/*`; client passes
///     the player's local `totalXP` as a best-effort lower bound.
///   - [now]: the moment of the attempted write (UTC).
///   - [lastWriteAt]: the `updatedAt` of the player's existing
///     leaderboard doc, or `null` if no prior write exists.
///
/// Outputs: a [LeaderboardScoreValidation] describing the outcome.
///
/// Decision tree:
///   1. Reject if [requestedScore] < 0.
///   2. Reject if [serverMaxXp] < 0 (corrupt audit log).
///   3. Reject if [requestedScore] > `kMaxLeaderboardScore` (hard
///      ceiling — even the audit log cannot authorize beyond this).
///   4. Throttle if [lastWriteAt] is within `kMinWriteIntervalSeconds`
///      of [now]. Drop the write.
///   5. Clamp if [requestedScore] > [serverMaxXp]. Use [serverMaxXp]
///      as effective score.
///   6. Otherwise accept clean.
///
/// Note on clock skew: the Cloud Function uses `request.time`
/// (server-side) for the throttle check; the client uses local time.
/// We tolerate up to 2× the interval of skew by allowing the throttle
/// check to consider `lastWriteAt > now` (clock running backwards) as
/// "not throttled" rather than negative-duration math.
LeaderboardScoreValidation validateLeaderboardScore({
  required int requestedScore,
  required int serverMaxXp,
  required DateTime now,
  DateTime? lastWriteAt,
}) {
  if (requestedScore < 0) {
    return LeaderboardScoreValidation(
      effectiveScore: requestedScore,
      didClamp: false,
      didThrottle: false,
      didReject: true,
      reason: 'requestedScore $requestedScore is negative',
    );
  }
  if (serverMaxXp < 0) {
    return LeaderboardScoreValidation(
      effectiveScore: requestedScore,
      didClamp: false,
      didThrottle: false,
      didReject: true,
      reason: 'serverMaxXp $serverMaxXp is negative (audit-log corruption)',
    );
  }
  if (requestedScore > kMaxLeaderboardScore) {
    return LeaderboardScoreValidation(
      effectiveScore: requestedScore,
      didClamp: false,
      didThrottle: false,
      didReject: true,
      reason:
          'requestedScore $requestedScore exceeds hard ceiling $kMaxLeaderboardScore',
    );
  }
  if (lastWriteAt != null) {
    final nowUtc = now.toUtc();
    final lastUtc = lastWriteAt.toUtc();
    // Only consider forward-going clock differences for throttling.
    // If lastWriteAt > now (clock skew), do not throttle — let the
    // server be the arbiter.
    if (!lastUtc.isAfter(nowUtc)) {
      final elapsed = nowUtc.difference(lastUtc).inSeconds;
      if (elapsed < kMinWriteIntervalSeconds) {
        return LeaderboardScoreValidation(
          effectiveScore: requestedScore,
          didClamp: false,
          didThrottle: true,
          didReject: false,
          reason:
              'throttled: $elapsed s since last write < $kMinWriteIntervalSeconds s min',
        );
      }
    }
  }
  if (requestedScore > serverMaxXp) {
    return LeaderboardScoreValidation(
      effectiveScore: serverMaxXp,
      didClamp: true,
      didThrottle: false,
      didReject: false,
      reason:
          'clamped: requestedScore $requestedScore > serverMaxXp $serverMaxXp',
    );
  }
  return LeaderboardScoreValidation(
    effectiveScore: requestedScore,
    didClamp: false,
    didThrottle: false,
    didReject: false,
    reason: '',
  );
}
