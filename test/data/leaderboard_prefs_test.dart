/// BL-04 — Hive integration test for `leaderboard_prefs` box.
///
/// Mirrors the temp-dir pattern from
/// `test/data/player_progress_hive_integration_test.dart`.
/// Verifies the opt-out preference (AC-012) survives a close/reopen
/// cycle and that the box starts with a safe default.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mitoosa/data/leaderboard_prefs.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('mitoosa_lb_prefs_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(kLeaderboardPrefsBoxName);
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  tearDown(() async {
    if (Hive.isBoxOpen(kLeaderboardPrefsBoxName)) {
      final box = Hive.box<dynamic>(kLeaderboardPrefsBoxName);
      await box.clear();
      await box.close();
    }
  });

  group('LeaderboardPrefs', () {
    test('default value is false (player participates by default)', () async {
      final box = await openLeaderboardPrefsBox();
      final prefs = LeaderboardPrefs(box);
      expect(prefs.optedOut, isFalse);
    });

    test('setOptedOut(true) → getter returns true', () async {
      final box = await openLeaderboardPrefsBox();
      final prefs = LeaderboardPrefs(box);
      await prefs.setOptedOut(true);
      expect(prefs.optedOut, isTrue);
    });

    test('opt-out preference persists across close/reopen', () async {
      // Round 1: write and close.
      var box = await openLeaderboardPrefsBox();
      var prefs = LeaderboardPrefs(box);
      await prefs.setOptedOut(true);
      await box.close();

      // Round 2: reopen and read.
      box = await openLeaderboardPrefsBox();
      prefs = LeaderboardPrefs(box);
      expect(prefs.optedOut, isTrue,
          reason: 'Opt-out preference must survive a box reopen');
    });

    test('setOptedOut(false) overrides a prior true', () async {
      final box = await openLeaderboardPrefsBox();
      final prefs = LeaderboardPrefs(box);
      await prefs.setOptedOut(true);
      await prefs.setOptedOut(false);
      expect(prefs.optedOut, isFalse);
    });

    test('clear() resets the box to default state', () async {
      final box = await openLeaderboardPrefsBox();
      final prefs = LeaderboardPrefs(box);
      await prefs.setOptedOut(true);
      await prefs.clear();
      expect(prefs.optedOut, isFalse);
      expect(box.isEmpty, isTrue);
    });

    test('corrupt non-bool value falls back to false (fail-open)', () async {
      // Simulate a downgrade/corruption path: someone wrote a String
      // under the opt-out key. The getter must not crash and must
      // default to participating (not silently de-list the player).
      final box = await openLeaderboardPrefsBox();
      await box.put(kLeaderboardOptOutKey, 'not-a-bool');
      final prefs = LeaderboardPrefs(box);
      expect(prefs.optedOut, isFalse);
    });

    test('openLeaderboardPrefsBox is idempotent', () async {
      final first = await openLeaderboardPrefsBox();
      final second = await openLeaderboardPrefsBox();
      // Same underlying box — write through first, read through second.
      await LeaderboardPrefs(first).setOptedOut(true);
      expect(LeaderboardPrefs(second).optedOut, isTrue);
      expect(identical(first, second), isTrue,
          reason: 'second call must return the same box instance');
    });

    test('multiple LeaderboardPrefs instances see the same box state',
        () async {
      final box = await openLeaderboardPrefsBox();
      final a = LeaderboardPrefs(box);
      final b = LeaderboardPrefs(box);
      await a.setOptedOut(true);
      expect(b.optedOut, isTrue);
      await b.setOptedOut(false);
      expect(a.optedOut, isFalse);
    });
  });
}
