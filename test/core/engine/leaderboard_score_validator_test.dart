/// BL-04 — Unit tests for validateLeaderboardScore (pre-gate foundation).
///
/// Pure-function tests. No I/O, no clock injection — every clock value
/// is passed in explicitly so the same suite is portable to the future
/// TypeScript Cloud Function port (AC-004 mirror).
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/leaderboard_score_validator.dart';
import 'package:mitoosa/data/leaderboard_entry.dart';

void main() {
  final now = DateTime.utc(2026, 5, 16, 12);

  group('validateLeaderboardScore — happy path', () {
    test('accepts clean write when no prior doc exists', () {
      final r = validateLeaderboardScore(
        requestedScore: 500,
        serverMaxXp: 1000,
        now: now,
        lastWriteAt: null,
      );
      expect(r.didReject, isFalse);
      expect(r.didThrottle, isFalse);
      expect(r.didClamp, isFalse);
      expect(r.effectiveScore, equals(500));
      expect(r.shouldWrite, isTrue);
      expect(r.reason, isEmpty);
    });

    test('accepts write exactly at serverMaxXp (no clamp)', () {
      final r = validateLeaderboardScore(
        requestedScore: 1000,
        serverMaxXp: 1000,
        now: now,
      );
      expect(r.didClamp, isFalse);
      expect(r.effectiveScore, equals(1000));
    });

    test('accepts write after throttle window elapses', () {
      final r = validateLeaderboardScore(
        requestedScore: 100,
        serverMaxXp: 1000,
        now: now,
        lastWriteAt:
            now.subtract(const Duration(seconds: kMinWriteIntervalSeconds)),
      );
      expect(r.didThrottle, isFalse);
      expect(r.shouldWrite, isTrue);
    });

    test('accepts score == 0', () {
      final r = validateLeaderboardScore(
        requestedScore: 0,
        serverMaxXp: 1000,
        now: now,
      );
      expect(r.didReject, isFalse);
      expect(r.effectiveScore, equals(0));
    });
  });

  group('validateLeaderboardScore — clamping (AC-004)', () {
    test('clamps to serverMaxXp when requested exceeds it', () {
      final r = validateLeaderboardScore(
        requestedScore: 5000,
        serverMaxXp: 1234,
        now: now,
      );
      expect(r.didClamp, isTrue);
      expect(r.didReject, isFalse);
      expect(r.didThrottle, isFalse);
      expect(r.effectiveScore, equals(1234));
      expect(r.shouldWrite, isTrue);
      expect(r.reason, contains('clamped'));
    });

    test('clamp branch fires even when score is just 1 over', () {
      final r = validateLeaderboardScore(
        requestedScore: 101,
        serverMaxXp: 100,
        now: now,
      );
      expect(r.didClamp, isTrue);
      expect(r.effectiveScore, equals(100));
    });

    test('clamps with serverMaxXp of zero (player has 0 audited XP)', () {
      final r = validateLeaderboardScore(
        requestedScore: 10,
        serverMaxXp: 0,
        now: now,
      );
      expect(r.didClamp, isTrue);
      expect(r.effectiveScore, equals(0));
    });
  });

  group('validateLeaderboardScore — throttling (AC-008)', () {
    test('throttles when interval < kMinWriteIntervalSeconds', () {
      final r = validateLeaderboardScore(
        requestedScore: 100,
        serverMaxXp: 1000,
        now: now,
        lastWriteAt: now.subtract(const Duration(seconds: 2)),
      );
      expect(r.didThrottle, isTrue);
      expect(r.shouldWrite, isFalse);
      expect(r.reason, contains('throttled'));
    });

    test('throttle boundary: exactly kMinWriteIntervalSeconds - 1 throttles',
        () {
      final r = validateLeaderboardScore(
        requestedScore: 100,
        serverMaxXp: 1000,
        now: now,
        lastWriteAt: now.subtract(
            const Duration(seconds: kMinWriteIntervalSeconds - 1)),
      );
      expect(r.didThrottle, isTrue);
    });

    test('throttle boundary: exactly kMinWriteIntervalSeconds passes', () {
      final r = validateLeaderboardScore(
        requestedScore: 100,
        serverMaxXp: 1000,
        now: now,
        lastWriteAt:
            now.subtract(const Duration(seconds: kMinWriteIntervalSeconds)),
      );
      expect(r.didThrottle, isFalse);
    });

    test('clock skew: lastWriteAt in the future does NOT throttle', () {
      final r = validateLeaderboardScore(
        requestedScore: 100,
        serverMaxXp: 1000,
        now: now,
        lastWriteAt: now.add(const Duration(seconds: 60)),
      );
      expect(r.didThrottle, isFalse,
          reason:
              'forward clock skew should defer to server, not throttle locally');
    });

    test('throttle short-circuits before clamp check', () {
      // requestedScore exceeds serverMaxXp BUT also fails throttle.
      // Outcome should be throttle (drop), not clamp (write).
      final r = validateLeaderboardScore(
        requestedScore: 9999,
        serverMaxXp: 100,
        now: now,
        lastWriteAt: now.subtract(const Duration(seconds: 1)),
      );
      expect(r.didThrottle, isTrue);
      expect(r.didClamp, isFalse);
      expect(r.shouldWrite, isFalse);
    });
  });

  group('validateLeaderboardScore — hard rejects', () {
    test('rejects negative requestedScore', () {
      final r = validateLeaderboardScore(
        requestedScore: -1,
        serverMaxXp: 1000,
        now: now,
      );
      expect(r.didReject, isTrue);
      expect(r.shouldWrite, isFalse);
      expect(r.reason, contains('negative'));
    });

    test('rejects negative serverMaxXp (audit-log corruption)', () {
      final r = validateLeaderboardScore(
        requestedScore: 100,
        serverMaxXp: -5,
        now: now,
      );
      expect(r.didReject, isTrue);
      expect(r.reason, contains('audit-log corruption'));
    });

    test('rejects requestedScore above hard ceiling', () {
      final r = validateLeaderboardScore(
        requestedScore: kMaxLeaderboardScore + 1,
        serverMaxXp: kMaxLeaderboardScore * 10,
        now: now,
      );
      expect(r.didReject, isTrue);
      expect(r.reason, contains('hard ceiling'));
    });

    test('rejects exactly hard ceiling + 1', () {
      final r = validateLeaderboardScore(
        requestedScore: kMaxLeaderboardScore + 1,
        serverMaxXp: 999999,
        now: now,
      );
      expect(r.didReject, isTrue);
    });

    test('accepts exactly hard ceiling (boundary)', () {
      final r = validateLeaderboardScore(
        requestedScore: kMaxLeaderboardScore,
        serverMaxXp: kMaxLeaderboardScore,
        now: now,
      );
      expect(r.didReject, isFalse);
      expect(r.effectiveScore, equals(kMaxLeaderboardScore));
    });

    test('reject takes precedence over throttle and clamp', () {
      final r = validateLeaderboardScore(
        requestedScore: -1, // hard reject reason
        serverMaxXp: 100,
        now: now,
        lastWriteAt: now.subtract(const Duration(seconds: 1)), // would throttle
      );
      expect(r.didReject, isTrue);
      expect(r.didThrottle, isFalse);
      expect(r.didClamp, isFalse);
    });
  });

  group('validateLeaderboardScore — outcome flag exclusivity', () {
    test('shouldWrite is false on throttle', () {
      final r = validateLeaderboardScore(
        requestedScore: 10,
        serverMaxXp: 100,
        now: now,
        lastWriteAt: now.subtract(const Duration(seconds: 1)),
      );
      expect(r.shouldWrite, isFalse);
    });

    test('shouldWrite is false on reject', () {
      final r = validateLeaderboardScore(
        requestedScore: -1,
        serverMaxXp: 100,
        now: now,
      );
      expect(r.shouldWrite, isFalse);
    });

    test('shouldWrite is true on clamp', () {
      final r = validateLeaderboardScore(
        requestedScore: 200,
        serverMaxXp: 100,
        now: now,
      );
      expect(r.shouldWrite, isTrue);
    });

    test('toString contains all fields for debug', () {
      final r = validateLeaderboardScore(
        requestedScore: 50,
        serverMaxXp: 100,
        now: now,
      );
      final s = r.toString();
      expect(s, contains('effectiveScore'));
      expect(s, contains('didClamp'));
      expect(s, contains('didThrottle'));
      expect(s, contains('didReject'));
    });
  });
}
