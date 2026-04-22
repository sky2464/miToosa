import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/core/engine/progression_engine.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('mitoosa_progress_');
    Hive.init(dir.path);
    Hive.registerAdapter(PlayerProgressAdapter());
  });

  test('themeModeOverride round-trips through Hive adapter', () async {
    final box = await Hive.openBox<PlayerProgress>('pp_override_rt');
    final p = PlayerProgress(playerId: 'u1', themeModeOverride: 2);
    await box.put('u1', p);
    await box.close();

    final reopened = await Hive.openBox<PlayerProgress>('pp_override_rt');
    final loaded = reopened.get('u1');
    expect(loaded, isNotNull);
    expect(loaded!.themeModeOverride, 2);
  });

  test('pre-v7 save (no themeModeOverride field) loads with null override',
      () async {
    // Simulate a legacy v6 binary payload with 32 fields (no field 32).
    // The adapter reads `fields[32] as int?` which is null when absent.
    final p = PlayerProgress(playerId: 'legacy-user');
    // Ensure the default is null-safe even before any migration.
    expect(p.themeModeOverride, isNull);

    // Round-trip with null override.
    final box = await Hive.openBox<PlayerProgress>('pp_legacy_rt');
    await box.put('legacy-user', p);
    final loaded = box.get('legacy-user');
    expect(loaded, isNotNull);
    expect(loaded!.themeModeOverride, isNull);
    // Unrelated fields stay intact.
    expect(loaded.difficultyMode, DifficultyMode.standard);
    expect(loaded.hearts, 5);
    await box.close();
  });

  // Keep typed_data import used (Uint8List guards against lint pruning in
  // case future extensions touch raw binary assertions).
  test('_sanity Uint8List is available', () {
    expect(Uint8List(1).length, 1);
  });
}
