import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'platform_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/engine/daily_reward_engine.dart';
import 'persistence_provider.dart';
import 'player_progress.dart';
import 'leaderboard_prefs.dart';

class HivePersistenceProvider implements IPersistenceProvider {
  static const String _boxName = 'player_progress_box';
  static const String _recoveryBoxName = 'player_progress_recovery_box';
  static const String _encryptionKeyName = 'hive_encryption_key_v1';
  static const String _integrityKeyName = 'hive_integrity_key_v1';

  HivePersistenceProvider({SecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? PlatformSecureStorage();

  final SecureStorage _secureStorage;
  Future<void> _writeQueue = Future.value();

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    final adapter = PlayerProgressAdapter();
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }

    // Migration strategy:
    // - If an encryption key already exists in secure storage, open the
    //   encrypted box directly.
    // - If no encryption key exists, attempt to open a plaintext box. If
    //   a plaintext box exists (contains data), migrate its contents into
    //   a newly created encrypted box and remove the plaintext files.
    final hasKey = await _secureStorage.containsKey(key: _encryptionKeyName);

    if (!hasKey) {
      // No encryption key recorded: there may be an existing plaintext box.
      Box<PlayerProgress>? plaintextBox;
      Map<String, PlayerProgress> entries = {};
      try {
        plaintextBox = await Hive.openBox<PlayerProgress>(_boxName);
        if (plaintextBox.isNotEmpty) {
          entries = plaintextBox.toMap().cast<String, PlayerProgress>();
          developer.log(
            'Found ${entries.length} plaintext PlayerProgress records to migrate.',
            name: 'security.hive_persistence',
          );
        }
      } catch (e, st) {
        developer.log(
          'Failed to open plaintext Hive box: $e',
          level: 900,
          name: 'security.hive_persistence',
          error: e,
          stackTrace: st,
        );
      }

      if (plaintextBox != null && plaintextBox.isOpen) {
        await plaintextBox.close();
      }

      // Create and persist an encryption key, then delete the plaintext box files
      final encryptionKey = await _getOrCreateEncryptionKey();

      try {
        // Remove any existing plaintext files to avoid conflicts when opening
        // the encrypted box with the same name.
        await Hive.deleteBoxFromDisk(_boxName);
      } catch (e, st) {
        developer.log(
          'Failed to delete plaintext Hive box files: $e',
          level: 900,
          name: 'security.hive_persistence',
          error: e,
          stackTrace: st,
        );
      }

      // Open the (now encrypted) box and write migrated entries.
      final encBox = await Hive.openBox<PlayerProgress>(
        _boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      if (entries.isNotEmpty) {
        await encBox.putAll(entries);
        developer.log(
          'Migrated ${entries.length} PlayerProgress records into encrypted box.',
          name: 'security.hive_persistence',
        );
      }

      await _openRecoveryBox(encryptionKey);
      return;
    }

    // Encryption key exists — open encrypted box normally.
    final encryptionKey = await _getOrCreateEncryptionKey();
    await Hive.openBox<PlayerProgress>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    await _openRecoveryBox(encryptionKey);
  }

  /// Opens the quarantine box used to hold progress records that failed
  /// an integrity check, so they can be recovered explicitly instead of
  /// being deleted outright (BL-40).
  Future<void> _openRecoveryBox(Uint8List encryptionKey) async {
    if (Hive.isBoxOpen(_recoveryBoxName)) return;
    await Hive.openBox<PlayerProgress>(
      _recoveryBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<Uint8List> _getOrCreateEncryptionKey() async {
    final encoded = await _secureStorage.read(key: _encryptionKeyName);
    if (encoded != null) return base64Url.decode(encoded);
    final key = Hive.generateSecureKey();
    final value = base64UrlEncode(key);
    await _secureStorage.write(key: _encryptionKeyName, value: value);
    return base64Url.decode(value);
  }

  Future<String> _getOrCreateIntegrityKey() async {
    final existing = await _secureStorage.read(key: _integrityKeyName);
    if (existing != null) return existing;
    final key = const Uuid().v4();
    await _secureStorage.write(key: _integrityKeyName, value: key);
    return key;
  }

  @override
  Future<PlayerProgress> loadProgress(String playerId) async {
    final box = Hive.box<PlayerProgress>(_boxName);
    final progressRaw = box.get(playerId);
    final integrityKey = await _getOrCreateIntegrityKey();
    if (progressRaw == null) {
      return PlayerProgress.fresh(playerId: playerId);
    }

    if (!progressRaw.isValid(integrityKey)) {
      // Integrity check failed. Treat as corrupted and fail-secure: do not
      // re-sign or merge it back into live use. But never silently discard
      // it either — quarantine it so the player can be offered an
      // explicit recovery choice (BL-40), then serve fresh progress so the
      // app can continue.
      if (progressRaw.integrityHash != null) {
        developer.log(
          'PlayerProgress integrity check failed for $playerId. '
          'Quarantining for recovery and serving fresh progress.',
          level: 1000,
          name: 'security.hive_persistence',
        );
        await Hive.box<PlayerProgress>(
          _recoveryBoxName,
        ).put(playerId, progressRaw);
        await box.delete(playerId);
        return PlayerProgress.fresh(playerId: playerId);
      }
    }

    return progressRaw;
  }

  @override
  Future<PlayerProgress?> checkForRecoverableProgress(String playerId) async {
    return Hive.box<PlayerProgress>(_recoveryBoxName).get(playerId);
  }

  @override
  Future<PlayerProgress> restoreRecoverableProgress(String playerId) async {
    final recoveryBox = Hive.box<PlayerProgress>(_recoveryBoxName);
    final quarantined = recoveryBox.get(playerId);
    if (quarantined == null) {
      throw StateError('No recoverable progress for $playerId');
    }
    // Re-sign so it's trusted again before it re-enters live use, then
    // clear the quarantine slot.
    await saveProgress(quarantined);
    await recoveryBox.delete(playerId);
    return quarantined;
  }

  @override
  Future<void> discardRecoverableProgress(String playerId) async {
    await Hive.box<PlayerProgress>(_recoveryBoxName).delete(playerId);
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    final integrityKey = await _getOrCreateIntegrityKey();
    progress.integrityHash = progress.calculateHash(integrityKey);

    final box = Hive.box<PlayerProgress>(_boxName);
    await box.put(progress.playerId, progress);
  }

  @override
  Future<T> updateProgress<T>(
    String playerId,
    T Function(PlayerProgress progress) mutate,
  ) {
    final result = _writeQueue.then((_) async {
      final progress = await loadProgress(playerId);
      final value = mutate(progress);
      await saveProgress(progress);
      return value;
    });
    _writeQueue = result.then<void>((_) {}, onError: (_) {});
    return result;
  }

  @override
  Future<void> deductHeart(String playerId) =>
      updateProgress(playerId, (p) => p.deductHeart());

  @override
  Future<bool> refuelHeartsWithDiamond(String playerId) =>
      updateProgress(playerId, (p) => p.refuelHeartsWithDiamond());

  @override
  Future<void> addDiamond(String playerId, [int count = 1]) =>
      updateProgress(playerId, (p) => p.addDiamond(count));

  @override
  Future<bool> checkAndRefuelHeart(String playerId, DateTime now) =>
      updateProgress(playerId, (p) => p.checkAndRefuelHeart(now));

  @override
  Future<void> markTutorialSeen(String playerId, String worldId) =>
      updateProgress(playerId, (p) => p.markTutorialSeen(worldId));

  @override
  Future<bool> shareAndRefuel(String playerId, DateTime now) =>
      updateProgress(playerId, (p) => p.shareAndRefuel(now));

  @override
  Future<void> completeOnboarding(String playerId) =>
      updateProgress(playerId, (p) => p.completeOnboarding());

  @override
  Future<bool> consumeFreeGame(String playerId, DateTime now) =>
      updateProgress(playerId, (p) {
        p.checkAllowanceReset(now);
        return p.consumeFreeGame();
      });

  @override
  Future<bool> grantShareBonus(String playerId, DateTime now) =>
      updateProgress(playerId, (p) => p.grantShareBonus(now));

  @override
  Future<bool> claimDailyReward(String playerId, DateTime now) async {
    final progress = await loadProgress(playerId);
    if (!DailyRewardEngine.canClaim(
      lastClaim: progress.lastDailyRewardClaim,
      now: now,
    )) {
      return false;
    }
    final day = progress.dailyRewardDay <= 0
        ? 1
        : DailyRewardEngine.nextDay(progress.dailyRewardDay);
    final coins = DailyRewardEngine.rewardForDay(day).coins;
    progress.addCoins(coins);
    progress.claimDailyReward(day, now);
    await saveProgress(progress);
    return true;
  }

  @override
  Future<void> resetGameProgress(String playerId) async {
    final fresh = PlayerProgress.fresh(playerId: playerId);
    await saveProgress(fresh);
    // An explicit reset should not leave a stale recovery prompt behind.
    await discardRecoverableProgress(playerId);

    if (Hive.isBoxOpen(kLeaderboardPrefsBoxName)) {
      await LeaderboardPrefs(
        Hive.box<dynamic>(kLeaderboardPrefsBoxName),
      ).clear();
    }
  }
}
