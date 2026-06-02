/// BL-10 — Hive persistence integration tests for PlayerProgress.
///
/// Exercises the full save → close → reopen → load round-trip using a real
/// Hive box backed by a temp directory. Verifies:
///  - All schema-v6 fields survive a box close/reopen cycle.
///  - Multiple players coexist in the same box without bleed-over.
///  - Adaptive history rolling-window mutations persist correctly.
///  - levelStars map preserves insertion semantics.
///  - Streak milestone / freeze fields round-trip.
///  - Daily XP map serializes/deserializes correctly.
///
/// These tests complement the existing unit tests in `player_progress_test.dart`
/// (which test the model in isolation) by proving the persistence boundary
/// behaves correctly under real-world simulated app restarts.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mitoosa/data/player_progress.dart';

void main() {
  late Directory tempDir;
  const boxName = 'player_progress_integration_box';

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('mitoosa_pp_int_');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(PlayerProgressAdapter().typeId)) {
      Hive.registerAdapter(PlayerProgressAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk(boxName);
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  tearDown(() async {
    // Clear the box between tests to keep each test independent.
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box<PlayerProgress>(boxName);
      await box.clear();
      await box.close();
    }
  });

  test('save → close → reopen → load preserves all primary fields', () async {
    final original = PlayerProgress.fresh(playerId: 'integration-player-A')
      ..totalXP = 1234
      ..coins = 99
      ..streakCount = 7
      ..bestStreak = 21
      ..hearts = 4
      ..diamonds = 3
      ..freeGamesRemaining = 12
      ..streakFreezeCount = 2
      ..streakMilestones = const [3, 7]
      ..levelStars = const {'logic_0': 5, 'logic_1': 3, 'memory_0': 4}
      ..unlockedAchievements = ['first_clear', 'streak_3']
      ..adaptiveHistory = const [3, 4, 5, 4, 3]
      ..lastLoginDate = DateTime.utc(2026, 5, 15, 8);

    // Round 1: save and close
    var box = await Hive.openBox<PlayerProgress>(boxName);
    await box.put(original.playerId, original);
    await box.close();

    // Round 2: reopen and load
    box = await Hive.openBox<PlayerProgress>(boxName);
    final loaded = box.get(original.playerId);

    expect(loaded, isNotNull, reason: 'Player record must survive box reopen');
    expect(loaded!.playerId, equals(original.playerId));
    expect(loaded.totalXP, equals(1234));
    expect(loaded.coins, equals(99));
    expect(loaded.streakCount, equals(7));
    expect(loaded.bestStreak, equals(21));
    expect(loaded.hearts, equals(4));
    expect(loaded.diamonds, equals(3));
    expect(loaded.freeGamesRemaining, equals(12));
    expect(loaded.streakFreezeCount, equals(2));
    expect(loaded.streakMilestones, equals(const [3, 7]));
    expect(
      loaded.levelStars,
      equals(const {'logic_0': 5, 'logic_1': 3, 'memory_0': 4}),
    );
    expect(loaded.unlockedAchievements, equals(['first_clear', 'streak_3']));
    expect(loaded.adaptiveHistory, equals(const [3, 4, 5, 4, 3]));
    expect(loaded.lastLoginDate, equals(DateTime.utc(2026, 5, 15, 8)));
  });

  test('multiple player records coexist without cross-contamination', () async {
    final alice = PlayerProgress.fresh(playerId: 'alice')
      ..totalXP = 100
      ..streakCount = 1;
    final bob = PlayerProgress.fresh(playerId: 'bob')
      ..totalXP = 500
      ..streakCount = 9;

    var box = await Hive.openBox<PlayerProgress>(boxName);
    await box.put('alice', alice);
    await box.put('bob', bob);
    await box.close();

    box = await Hive.openBox<PlayerProgress>(boxName);
    final loadedAlice = box.get('alice');
    final loadedBob = box.get('bob');

    expect(loadedAlice?.totalXP, equals(100));
    expect(loadedAlice?.streakCount, equals(1));
    expect(loadedBob?.totalXP, equals(500));
    expect(loadedBob?.streakCount, equals(9));
    expect(
      box.keys.length,
      equals(2),
      reason: 'Both players should be present in the reopened box',
    );
  });

  test('adaptive history mutations persist after close/reopen', () async {
    final p = PlayerProgress.fresh(playerId: 'adaptive-player');
    // Push values into the rolling window
    for (final v in [3, 4, 5, 3, 4]) {
      p.adaptiveHistory = [...p.adaptiveHistory, v];
    }

    var box = await Hive.openBox<PlayerProgress>(boxName);
    await box.put(p.playerId, p);
    await box.close();

    box = await Hive.openBox<PlayerProgress>(boxName);
    final loaded = box.get(p.playerId);
    expect(loaded?.adaptiveHistory, equals(const [3, 4, 5, 3, 4]));
  });

  test('daily XP counter round-trips correctly', () async {
    final p = PlayerProgress.fresh(playerId: 'xp-player')
      ..addDailyXP(50)
      ..addDailyXP(75);

    expect(p.dailyXP, equals(125));
    expect(p.dailyXPDate, isNotNull);

    var box = await Hive.openBox<PlayerProgress>(boxName);
    await box.put(p.playerId, p);
    await box.close();

    box = await Hive.openBox<PlayerProgress>(boxName);
    final loaded = box.get(p.playerId);
    expect(
      loaded?.dailyXP,
      equals(125),
      reason: 'Daily XP total must survive persistence',
    );
    expect(
      loaded?.dailyXPDate,
      isNotNull,
      reason: 'Daily XP date marker must survive persistence',
    );
  });

  test('seenTutorialWorlds list persists across reopen', () async {
    final p = PlayerProgress.fresh(playerId: 'tutorial-player')
      ..markTutorialSeen('logic')
      ..markTutorialSeen('memory');

    var box = await Hive.openBox<PlayerProgress>(boxName);
    await box.put(p.playerId, p);
    await box.close();

    box = await Hive.openBox<PlayerProgress>(boxName);
    final loaded = box.get(p.playerId);
    expect(loaded?.seenTutorialWorlds, containsAll(['logic', 'memory']));
    expect(loaded?.seenTutorialWorlds.length, equals(2));
  });

  test('delete removes the record from disk and reopen returns null', () async {
    final p = PlayerProgress.fresh(playerId: 'delete-player')..totalXP = 42;

    var box = await Hive.openBox<PlayerProgress>(boxName);
    await box.put('delete-player', p);
    await box.delete('delete-player');
    await box.close();

    box = await Hive.openBox<PlayerProgress>(boxName);
    expect(
      box.get('delete-player'),
      isNull,
      reason: 'Deleted records must not reappear after reopen',
    );
  });

  test('empty box returns null for any key', () async {
    final box = await Hive.openBox<PlayerProgress>(boxName);
    expect(box.get('nonexistent'), isNull);
    expect(box.isEmpty, isTrue);
  });

  test('overwriting a player record persists the latest value', () async {
    var box = await Hive.openBox<PlayerProgress>(boxName);

    final v1 = PlayerProgress.fresh(playerId: 'overwrite')..totalXP = 100;
    await box.put('overwrite', v1);

    final v2 = PlayerProgress.fresh(playerId: 'overwrite')..totalXP = 999;
    await box.put('overwrite', v2);
    await box.close();

    box = await Hive.openBox<PlayerProgress>(boxName);
    expect(
      box.get('overwrite')?.totalXP,
      equals(999),
      reason: 'Last write must win after persistence',
    );
  });
}
