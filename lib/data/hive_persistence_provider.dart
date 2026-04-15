import 'dart:convert';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'platform_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'persistence_provider.dart';
import 'player_progress.dart';

class HivePersistenceProvider implements IPersistenceProvider {
  static const String _boxName = 'player_progress_box';
  static const String _encryptionKeyName = 'hive_encryption_key_v1';
  static const String _integrityKeyName = 'hive_integrity_key_v1';
  final _secureStorage = PlatformSecureStorage();

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PlayerProgressAdapter());

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
        developer.log('Failed to open plaintext Hive box: $e',
            level: 900, name: 'security.hive_persistence', error: e, stackTrace: st);
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
        developer.log('Failed to delete plaintext Hive box files: $e',
            level: 900, name: 'security.hive_persistence', error: e, stackTrace: st);
      }

      // Open the (now encrypted) box and write migrated entries.
      final encBox = await Hive.openBox<PlayerProgress>(
        _boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      if (entries.isNotEmpty) {
        await encBox.putAll(entries);
        developer.log('Migrated ${entries.length} PlayerProgress records into encrypted box.',
            name: 'security.hive_persistence');
      }

      return;
    }

    // Encryption key exists — open encrypted box normally.
    final encryptionKey = await _getOrCreateEncryptionKey();
    await Hive.openBox<PlayerProgress>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<Uint8List> _getOrCreateEncryptionKey() async {
    final containsKey = await _secureStorage.containsKey(key: _encryptionKeyName);
    if (!containsKey) {
      final key = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _encryptionKeyName,
        value: base64UrlEncode(key),
      );
    }
    final encodedKey = await _secureStorage.read(key: _encryptionKeyName);
    return base64Url.decode(encodedKey!);
  }

  Future<String> _getOrCreateIntegrityKey() async {
    final containsKey = await _secureStorage.containsKey(key: _integrityKeyName);
    if (!containsKey) {
      final key = const Uuid().v4();
      await _secureStorage.write(key: _integrityKeyName, value: key);
    }
    return (await _secureStorage.read(key: _integrityKeyName))!;
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
      // Integrity check failed. Treat as corrupted and fail-secure: do not re-sign or merge.
      if (progressRaw.integrityHash != null) {
        developer.log(
          'PlayerProgress integrity check failed for $playerId. Deleting corrupted record.',
          level: 1000,
          name: 'security.hive_persistence',
        );
        await box.delete(playerId);
        return PlayerProgress.fresh(playerId: playerId);
      }
    }

    return progressRaw;
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    final integrityKey = await _getOrCreateIntegrityKey();
    progress.integrityHash = progress.calculateHash(integrityKey);

    final box = Hive.box<PlayerProgress>(_boxName);
    await box.put(progress.playerId, progress);
  }

  @override
  Future<void> updateLevelStar(String playerId, String levelId, int stars) async {
    final progress = await loadProgress(playerId);
    
    final currentStars = progress.levelStars[levelId] ?? 0;
    if (stars > currentStars) {
      final updatedStars = Map<String, int>.from(progress.levelStars);
      updatedStars[levelId] = stars;
      progress.levelStars = updatedStars;
      await saveProgress(progress);
    }
  }
}
