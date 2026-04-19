/// Unit tests for the level-gate logic that gates progression in
/// [TrackDetailScreen].
///
/// The gate rule is: a level at [index] is playable when:
///   - index == 0, OR
///   - the previous level (index-1) has been completed AND its recorded XP is
///     either absent (legacy save) OR >= [kProgressionGateXP].
///
/// These tests exercise the logic directly via [PlayerProgress] and
/// [kProgressionGateXP], mirroring what `_hasMetGate` / `_isPlayable` do.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/engine/progression_engine.dart';
import 'package:mitoosa/data/player_progress.dart';

// ── Helpers that mirror the private widget methods ─────────────────────────

const _trackId = 'track1';

bool _hasMetGate(int index, PlayerProgress progress) {
  final key = '${_trackId}_$index';
  if (!progress.levelStars.containsKey(key)) return false;
  final xp = progress.levelXP[key];
  return xp == null || xp >= kProgressionGateXP;
}

bool _isPlayable(int index, PlayerProgress progress) {
  if (index == 0) return true;
  return _hasMetGate(index - 1, progress);
}

// ── Fixtures ───────────────────────────────────────────────────────────────

PlayerProgress _fresh() => PlayerProgress.fresh(playerId: 'p1');

PlayerProgress _withLevel(int index, {required int stars, int? xp}) {
  final p = _fresh();
  final key = '${_trackId}_$index';
  p.levelStars = Map<String, int>.from(p.levelStars)..[key] = stars;
  if (xp != null) {
    p.recordLevelXP(key, xp);
  }
  return p;
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('Gate logic — _isPlayable', () {
    test('level 0 is always playable regardless of progress', () {
      expect(_isPlayable(0, _fresh()), true);
    });

    test('level 1 is NOT playable when level 0 has never been completed', () {
      expect(_isPlayable(1, _fresh()), false);
    });

    test('level 1 IS playable when level 0 completed with XP >= threshold', () {
      final p = _withLevel(0, stars: 3, xp: kProgressionGateXP);
      expect(_isPlayable(1, p), true);
    });

    test('level 1 IS playable when level 0 XP is exactly the threshold (boundary)', () {
      final p = _withLevel(0, stars: 5, xp: kProgressionGateXP);
      expect(_isPlayable(1, p), true);
    });

    test('level 1 NOT playable when level 0 XP is one below threshold', () {
      final p = _withLevel(0, stars: 5, xp: kProgressionGateXP - 1);
      expect(_isPlayable(1, p), false);
    });

    test('level 1 IS playable for legacy saves (null XP, stars present)', () {
      // Legacy: level was completed before v6 XP tracking — xp entry absent.
      final p = _withLevel(0, stars: 3, xp: null);
      expect(_isPlayable(1, p), true);
    });

    test('level 2 requires level 1 gate to be met', () {
      // Level 1 completed with enough XP
      final p = _withLevel(1, stars: 3, xp: kProgressionGateXP);
      expect(_isPlayable(2, p), true);
    });

    test('level 2 NOT playable when only level 0 has been completed', () {
      final p = _withLevel(0, stars: 3, xp: kProgressionGateXP);
      expect(_isPlayable(2, p), false);
    });
  });

  group('Gate logic — _hasMetGate', () {
    test('returns false when level not in levelStars (never completed)', () {
      expect(_hasMetGate(0, _fresh()), false);
    });

    test('returns true when XP is null (legacy save — backward-compatible)', () {
      final p = _withLevel(0, stars: 2, xp: null);
      expect(_hasMetGate(0, p), true);
    });

    test('returns true when XP is above threshold', () {
      final p = _withLevel(0, stars: 5, xp: kProgressionGateXP + 3);
      expect(_hasMetGate(0, p), true);
    });

    test('returns false when XP is below threshold', () {
      final p = _withLevel(0, stars: 5, xp: kProgressionGateXP - 1);
      expect(_hasMetGate(0, p), false);
    });

    test('returns false when XP is below threshold (1)', () {
      // recordLevelXP only stores xp when xp > 0 (the default floor),
      // so use xp=1 which is > 0 but < kProgressionGateXP.
      final p = _withLevel(0, stars: 5, xp: 1);
      expect(_hasMetGate(0, p), false);
    });
  });
}
