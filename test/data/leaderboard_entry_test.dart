/// BL-04 — Unit tests for LeaderboardEntry (pre-gate foundation).
///
/// Covers serialization round-trip, validation invariants, ISO-week
/// derivation across year-boundary edge cases, and copyWith semantics.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/leaderboard_entry.dart';

void main() {
  group('LeaderboardEntry — JSON round-trip', () {
    test('toJson/fromJson preserves all fields including hashedId', () {
      final ts = DateTime.utc(2026, 5, 16, 12, 34, 56);
      final original = LeaderboardEntry(
        playerId: 'uid_abc123',
        displayName: 'Pilot_0042',
        score: 8500,
        week: '2026-W20',
        updatedAt: ts,
        hashedId: 'a' * 64, // 64-char hex (lowercase a is hex-valid)
      );

      final json = original.toJson();
      final restored = LeaderboardEntry.fromJson(json);

      expect(restored, equals(original));
      expect(restored.hashCode, equals(original.hashCode));
    });

    test('toJson omits hashedId when null', () {
      final entry = LeaderboardEntry(
        playerId: 'uid_x',
        displayName: 'Pilot_0001',
        score: 0,
        week: '2026-W01',
        updatedAt: DateTime.utc(2026, 1, 5),
      );
      final json = entry.toJson();
      expect(json.containsKey('hashedId'), isFalse);
    });

    test('fromJson throws FormatException on missing playerId', () {
      expect(
        () => LeaderboardEntry.fromJson({
          'displayName': 'Pilot_0001',
          'score': 10,
          'week': '2026-W20',
          'updatedAt': 0,
        }),
        throwsFormatException,
      );
    });

    test('fromJson throws FormatException on wrong score type', () {
      expect(
        () => LeaderboardEntry.fromJson({
          'playerId': 'uid_x',
          'displayName': 'Pilot_0001',
          'score': '10', // string, not int
          'week': '2026-W20',
          'updatedAt': 0,
        }),
        throwsFormatException,
      );
    });

    test('fromJson throws FormatException on wrong hashedId type', () {
      expect(
        () => LeaderboardEntry.fromJson({
          'playerId': 'uid_x',
          'displayName': 'Pilot_0001',
          'score': 10,
          'week': '2026-W20',
          'updatedAt': 0,
          'hashedId': 12345, // not a string
        }),
        throwsFormatException,
      );
    });

    test('fromJson converts updatedAt millis to UTC DateTime', () {
      final entry = LeaderboardEntry.fromJson({
        'playerId': 'uid_x',
        'displayName': 'Pilot_0001',
        'score': 10,
        'week': '2026-W20',
        'updatedAt': 1747396800000, // 2025-05-16 12:00:00 UTC
      });
      expect(entry.updatedAt.isUtc, isTrue);
      expect(
        entry.updatedAt,
        equals(DateTime.fromMillisecondsSinceEpoch(1747396800000, isUtc: true)),
      );
    });
  });

  group('LeaderboardEntry.copyWith', () {
    final base = LeaderboardEntry(
      playerId: 'uid_a',
      displayName: 'Pilot_0001',
      score: 100,
      week: '2026-W20',
      updatedAt: DateTime.utc(2026, 5, 16),
    );

    test('returns identical entry when no overrides given', () {
      expect(base.copyWith(), equals(base));
    });

    test('overrides only named fields', () {
      final updated = base.copyWith(score: 999, hashedId: '0' * 64);
      expect(updated.score, equals(999));
      expect(updated.hashedId, equals('0' * 64));
      expect(updated.playerId, equals(base.playerId));
      expect(updated.displayName, equals(base.displayName));
      expect(updated.week, equals(base.week));
      expect(updated.updatedAt, equals(base.updatedAt));
    });

    test('does not mutate the original', () {
      // ignore: unused_local_variable
      final _ = base.copyWith(score: 0);
      expect(base.score, equals(100));
    });
  });

  group('LeaderboardEntry.validate — accepted cases', () {
    LeaderboardEntry mk({
      String playerId = 'uid_abc',
      String displayName = 'Pilot_0001',
      int score = 100,
      String week = '2026-W20',
      String? hashedId,
    }) {
      return LeaderboardEntry(
        playerId: playerId,
        displayName: displayName,
        score: score,
        week: week,
        updatedAt: DateTime.utc(2026, 5, 16),
        hashedId: hashedId,
      );
    }

    test('valid Pilot_NNNN entry passes', () {
      expect(LeaderboardEntry.validate(mk()), isNull);
      expect(LeaderboardEntry.isValid(mk()), isTrue);
    });

    test('alphanumeric custom name within 16 chars passes', () {
      expect(
        LeaderboardEntry.validate(mk(displayName: 'Player_Awesome16')),
        isNull,
      );
    });

    test('score at hard ceiling passes', () {
      expect(
        LeaderboardEntry.validate(mk(score: kMaxLeaderboardScore)),
        isNull,
      );
    });

    test('score == 0 passes', () {
      expect(LeaderboardEntry.validate(mk(score: 0)), isNull);
    });

    test('valid hashedId (64 lowercase hex) passes', () {
      expect(
        LeaderboardEntry.validate(mk(hashedId: '0123456789abcdef' * 4)),
        isNull,
      );
    });

    test('ISO week 53 passes for long years (e.g. 2026)', () {
      // 2026 starts on Thursday → has 53 ISO weeks.
      expect(LeaderboardEntry.validate(mk(week: '2026-W53')), isNull);
    });
  });

  group('LeaderboardEntry.validate — rejection paths', () {
    LeaderboardEntry mk({
      String playerId = 'uid_abc',
      String displayName = 'Pilot_0001',
      int score = 100,
      String week = '2026-W20',
      String? hashedId,
    }) {
      return LeaderboardEntry(
        playerId: playerId,
        displayName: displayName,
        score: score,
        week: week,
        updatedAt: DateTime.utc(2026, 5, 16),
        hashedId: hashedId,
      );
    }

    test('empty playerId rejected', () {
      final err = LeaderboardEntry.validate(mk(playerId: ''));
      expect(err, isNotNull);
      expect(err!.field, equals('playerId'));
    });

    test('overlong playerId rejected', () {
      final err = LeaderboardEntry.validate(mk(playerId: 'x' * 65));
      expect(err?.field, equals('playerId'));
    });

    test('displayName with invalid characters rejected', () {
      final err = LeaderboardEntry.validate(mk(displayName: 'Bad Name'));
      expect(err?.field, equals('displayName'));
    });

    test('displayName over 16 chars rejected', () {
      final err = LeaderboardEntry.validate(mk(displayName: 'A' * 17));
      expect(err?.field, equals('displayName'));
    });

    test('empty displayName rejected', () {
      final err = LeaderboardEntry.validate(mk(displayName: ''));
      expect(err?.field, equals('displayName'));
    });

    test('negative score rejected', () {
      final err = LeaderboardEntry.validate(mk(score: -1));
      expect(err?.field, equals('score'));
    });

    test('score above hard ceiling rejected', () {
      final err = LeaderboardEntry.validate(
        mk(score: kMaxLeaderboardScore + 1),
      );
      expect(err?.field, equals('score'));
    });

    test('malformed week (no W prefix) rejected', () {
      final err = LeaderboardEntry.validate(mk(week: '2026-20'));
      expect(err?.field, equals('week'));
    });

    test('malformed week (week 00) rejected', () {
      final err = LeaderboardEntry.validate(mk(week: '2026-W00'));
      expect(err?.field, equals('week'));
    });

    test('malformed week (week 54) rejected', () {
      final err = LeaderboardEntry.validate(mk(week: '2026-W54'));
      expect(err?.field, equals('week'));
    });

    test('hashedId with uppercase hex rejected (must be lowercase)', () {
      final err = LeaderboardEntry.validate(mk(hashedId: 'AAAA${'0' * 60}'));
      expect(err?.field, equals('hashedId'));
    });

    test('hashedId of wrong length rejected', () {
      final err = LeaderboardEntry.validate(mk(hashedId: '0' * 63));
      expect(err?.field, equals('hashedId'));
    });
  });

  group('LeaderboardEntry.isoWeekOf — ISO 8601 conformance', () {
    test('mid-year date returns correct week', () {
      // 2026-05-16 is Saturday of ISO week 2026-W20.
      expect(
        LeaderboardEntry.isoWeekOf(DateTime.utc(2026, 5, 16)),
        equals('2026-W20'),
      );
    });

    test('first day of year that falls in previous year ISO-week', () {
      // 2027-01-01 is Friday → ISO week 2026-W53.
      expect(
        LeaderboardEntry.isoWeekOf(DateTime.utc(2027, 1, 1)),
        equals('2026-W53'),
      );
    });

    test('first day of year that falls in same year ISO-week', () {
      // 2026-01-01 is Thursday → ISO week 2026-W01.
      expect(
        LeaderboardEntry.isoWeekOf(DateTime.utc(2026, 1, 1)),
        equals('2026-W01'),
      );
    });

    test('last day of year that falls in next year ISO-week', () {
      // 2024-12-30 is Monday → ISO week 2025-W01.
      expect(
        LeaderboardEntry.isoWeekOf(DateTime.utc(2024, 12, 30)),
        equals('2025-W01'),
      );
    });

    test('Sunday boundary belongs to current ISO week', () {
      // 2026-05-17 is Sunday of ISO week 2026-W20.
      expect(
        LeaderboardEntry.isoWeekOf(DateTime.utc(2026, 5, 17)),
        equals('2026-W20'),
      );
    });

    test('Monday boundary belongs to next ISO week', () {
      // 2026-05-18 is Monday of ISO week 2026-W21.
      expect(
        LeaderboardEntry.isoWeekOf(DateTime.utc(2026, 5, 18)),
        equals('2026-W21'),
      );
    });

    test('produces a week string that passes validate()', () {
      // Sample several instants across a year and confirm each
      // generated key passes the validator.
      final samples = [
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 6, 30),
        DateTime.utc(2026, 12, 31),
        DateTime.utc(2027, 1, 1),
      ];
      for (final inst in samples) {
        final week = LeaderboardEntry.isoWeekOf(inst);
        expect(
          kIsoWeekPattern.hasMatch(week),
          isTrue,
          reason: 'week $week for instant $inst failed regex',
        );
      }
    });

    test('converts naive (non-UTC) input by treating as local→UTC', () {
      // Pass a non-UTC DateTime; isoWeekOf should normalize.
      final naive = DateTime(2026, 5, 16, 12);
      final week = LeaderboardEntry.isoWeekOf(naive);
      // Don't pin the exact value across TZs; just confirm format.
      expect(kIsoWeekPattern.hasMatch(week), isTrue);
    });
  });

  group('LeaderboardEntry equality + toString', () {
    test('equals compares all fields including hashedId', () {
      final ts = DateTime.utc(2026, 5, 16);
      final a = LeaderboardEntry(
        playerId: 'u',
        displayName: 'Pilot_0001',
        score: 1,
        week: '2026-W20',
        updatedAt: ts,
      );
      final b = a.copyWith(hashedId: '0' * 64);
      expect(a == b, isFalse);
    });

    test('toString contains key fields for log diagnostics', () {
      final entry = LeaderboardEntry(
        playerId: 'uid_z',
        displayName: 'Pilot_0007',
        score: 42,
        week: '2026-W20',
        updatedAt: DateTime.utc(2026, 5, 16),
      );
      final s = entry.toString();
      expect(s, contains('uid_z'));
      expect(s, contains('Pilot_0007'));
      expect(s, contains('42'));
      expect(s, contains('2026-W20'));
    });
  });
}
