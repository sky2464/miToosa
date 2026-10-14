/// BL-40 — Durable saves and recovery tests for HivePersistenceProvider.
///
/// Exercises the real quarantine/recovery flow (not a fake persistence
/// subclass) against a real Hive instance backed by a temp directory, with
/// an in-memory [SecureStorage] fake standing in for the platform keychain
/// and a mocked path_provider channel standing in for the native plugin
/// `Hive.initFlutter()` would otherwise call.
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mitoosa/data/hive_persistence_provider.dart';
import 'package:mitoosa/data/platform_secure_storage.dart';
import 'package:mitoosa/data/player_progress.dart';

/// Box names must match HivePersistenceProvider's private constants.
const _boxName = 'player_progress_box';
const _recoveryBoxName = 'player_progress_recovery_box';

class _FakeSecureStorage implements SecureStorage {
  final Map<String, String> store;
  _FakeSecureStorage([Map<String, String>? initial])
    : store = initial ?? <String, String>{};

  @override
  Future<bool> containsKey({required String key}) async =>
      store.containsKey(key);

  @override
  Future<String?> read({required String key}) async => store[key];

  @override
  Future<void> write({required String key, required String value}) async {
    store[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    store.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mitoosa_persist_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tempDir.path,
        );
  });

  tearDown(() async {
    for (final name in [_boxName, _recoveryBoxName]) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<PlayerProgress>(name).close();
      }
    }
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('HivePersistenceProvider — durable saves and recovery (BL-40)', () {
    test('fresh player with no saved record loads cleanly', () async {
      final provider = HivePersistenceProvider(
        secureStorage: _FakeSecureStorage(),
      );
      await provider.init();

      final progress = await provider.loadProgress('new-player');
      expect(progress.playerId, 'new-player');
      expect(progress.totalXP, 0);
      expect(await provider.checkForRecoverableProgress('new-player'), isNull);
    });

    test(
      'a correctly-signed record round-trips without being quarantined',
      () async {
        final provider = HivePersistenceProvider(
          secureStorage: _FakeSecureStorage(),
        );
        await provider.init();

        var progress = await provider.loadProgress('alice');
        progress.totalXP = 500;
        await provider.saveProgress(progress);

        final reloaded = await provider.loadProgress('alice');
        expect(reloaded.totalXP, 500);
        expect(await provider.checkForRecoverableProgress('alice'), isNull);
      },
    );

    test('a corrupted record is quarantined, not deleted outright', () async {
      final provider = HivePersistenceProvider(
        secureStorage: _FakeSecureStorage(),
      );
      await provider.init();

      var progress = await provider.loadProgress('bob');
      progress.totalXP = 777;
      await provider.saveProgress(progress);

      // Tamper with the record after it was signed, bypassing
      // saveProgress so the integrity hash no longer matches.
      final box = Hive.box<PlayerProgress>(_boxName);
      final stored = box.get('bob')!;
      stored.totalXP = 999999;
      await box.put('bob', stored);

      final afterCorruption = await provider.loadProgress('bob');
      expect(
        afterCorruption.totalXP,
        0,
        reason: 'A corrupted record must not be served back to the app as-is',
      );

      final quarantined = await provider.checkForRecoverableProgress('bob');
      expect(
        quarantined,
        isNotNull,
        reason:
            'The corrupted record must be preserved for recovery, '
            'never silently discarded',
      );
      expect(quarantined!.totalXP, 999999);

      // And it must actually be gone from the live box — this is a
      // quarantine, not a copy left behind to double-award on restore.
      expect(box.get('bob'), isNull);
    });

    test(
      'restoreRecoverableProgress restores quarantined data and re-signs it',
      () async {
        final provider = HivePersistenceProvider(
          secureStorage: _FakeSecureStorage(),
        );
        await provider.init();

        var progress = await provider.loadProgress('carol');
        progress.totalXP = 42;
        progress.coins = 10;
        await provider.saveProgress(progress);

        final box = Hive.box<PlayerProgress>(_boxName);
        final stored = box.get('carol')!;
        stored.totalXP = 42000;
        await box.put('carol', stored);
        await provider.loadProgress('carol'); // triggers quarantine

        final restored = await provider.restoreRecoverableProgress('carol');
        expect(restored.totalXP, 42000);
        expect(restored.coins, 10);

        // The quarantine slot must be cleared …
        expect(await provider.checkForRecoverableProgress('carol'), isNull);
        // … and the restored record must now load cleanly, re-signed, not
        // re-quarantined on the very next read.
        final reloaded = await provider.loadProgress('carol');
        expect(reloaded.totalXP, 42000);
        expect(
          await provider.checkForRecoverableProgress('carol'),
          isNull,
          reason: 'A freshly restored record must pass its own integrity check',
        );
      },
    );

    test(
      'discardRecoverableProgress clears the slot without restoring',
      () async {
        final provider = HivePersistenceProvider(
          secureStorage: _FakeSecureStorage(),
        );
        await provider.init();

        var progress = await provider.loadProgress('dave');
        progress.totalXP = 15;
        await provider.saveProgress(progress);

        final box = Hive.box<PlayerProgress>(_boxName);
        final stored = box.get('dave')!;
        stored.totalXP = 15000;
        await box.put('dave', stored);
        await provider.loadProgress('dave'); // triggers quarantine

        await provider.discardRecoverableProgress('dave');
        expect(await provider.checkForRecoverableProgress('dave'), isNull);

        final reloaded = await provider.loadProgress('dave');
        expect(
          reloaded.totalXP,
          0,
          reason: 'Discarding must not resurrect the corrupted value',
        );
      },
    );

    test(
      'restoreRecoverableProgress throws when nothing is pending recovery',
      () async {
        final provider = HivePersistenceProvider(
          secureStorage: _FakeSecureStorage(),
        );
        await provider.init();

        expect(
          () => provider.restoreRecoverableProgress('nobody'),
          throwsStateError,
        );
      },
    );

    test('resetGameProgress clears any pending recovery too', () async {
      final provider = HivePersistenceProvider(
        secureStorage: _FakeSecureStorage(),
      );
      await provider.init();

      var progress = await provider.loadProgress('erin');
      progress.totalXP = 8;
      await provider.saveProgress(progress);

      final box = Hive.box<PlayerProgress>(_boxName);
      final stored = box.get('erin')!;
      stored.totalXP = 8888;
      await box.put('erin', stored);
      await provider.loadProgress('erin'); // triggers quarantine
      expect(await provider.checkForRecoverableProgress('erin'), isNotNull);

      await provider.resetGameProgress('erin');
      expect(
        await provider.checkForRecoverableProgress('erin'),
        isNull,
        reason: 'An explicit reset should not leave a stale recovery prompt',
      );
    });

    test(
      'missing/rotated integrity key quarantines instead of crashing',
      () async {
        final sharedStore = <String, String>{};

        final provider1 = HivePersistenceProvider(
          secureStorage: _FakeSecureStorage(sharedStore),
        );
        await provider1.init();
        var progress = await provider1.loadProgress('finn');
        progress.totalXP = 60;
        await provider1.saveProgress(progress);

        // Simulate the platform keychain being wiped/reset: the integrity
        // key is gone, so a fresh one will be generated on next access —
        // old records signed under the previous key must no longer
        // validate, but must be quarantined, never crash or merge.
        sharedStore.remove('hive_integrity_key_v1');

        final afterKeyLoss = await provider1.loadProgress('finn');
        expect(afterKeyLoss.totalXP, 0);
        expect(
          await provider1.checkForRecoverableProgress('finn'),
          isNotNull,
          reason:
              'A record that fails validation under a rotated integrity '
              'key must be quarantined, not deleted outright',
        );
      },
    );
  });
}
