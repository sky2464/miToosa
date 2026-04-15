import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

import '../core/engine/progression_engine.dart';

class PlayerProgress {
  String playerId;
  int totalXP;
  int coins;
  int streakCount;
  int bestStreak;
  Map<String, int> levelStars; // Keyed by levelId
  List<String> unlockedAchievements;
  DateTime? lastLoginDate;
  String? integrityHash;
  // Adaptive difficulty fields (schema version 1).
  // Hive fields 9–11; missing in old saves → defaults applied in adapter.
  DifficultyMode difficultyMode;
  List<int> adaptiveHistory; // Star ratings from recent levels (1–3 each)
  int adaptiveVersion; // 0 = no adaptive data, 1+ = schema with adaptive data

  PlayerProgress({
    required this.playerId,
    this.totalXP = 0,
    this.coins = 0,
    this.streakCount = 0,
    this.bestStreak = 0,
    this.levelStars = const {},
    this.unlockedAchievements = const [],
    this.lastLoginDate,
    this.integrityHash,
    this.difficultyMode = DifficultyMode.standard,
    this.adaptiveHistory = const [],
    this.adaptiveVersion = 0,
  });

  factory PlayerProgress.fresh({required String playerId}) {
    return PlayerProgress(playerId: playerId);
  }

  /// Appends [stars] (1–3) to [adaptiveHistory], keeping the 20 most recent
  /// entries, and marks the schema version as 1 (adaptive data present).
  void recordLevelResult(int stars) {
    final updated = List<int>.from(adaptiveHistory)..add(stars);
    adaptiveHistory =
        updated.length > 20 ? updated.sublist(updated.length - 20) : updated;
    adaptiveVersion = 1;
  }

  void recordLogin() {
    final now = DateTime.now();
    if (lastLoginDate == null) {
      streakCount = 1;
      bestStreak = 1;
    } else {
      final difference = now.difference(lastLoginDate!).inDays;
      if (difference == 1) {
        streakCount += 1;
        if (streakCount > bestStreak) bestStreak = streakCount;
      } else if (difference > 1) {
        streakCount = 1; // Reset streak
      }
    }
    lastLoginDate = now;
  }

  String calculateHash(String secretKey) {
    final sortedStarsKeys = levelStars.keys.toList()..sort();
    final starsPayload = sortedStarsKeys.map((k) => "$k:${levelStars[k]}").join(",");
    final payload = "$playerId|$totalXP|$coins|$streakCount|$bestStreak|$starsPayload";
    
    final key = utf8.encode(secretKey);
    final bytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return digest.toString();
  }

  bool isValid(String secretKey) {
    if (integrityHash == null) return true; // Migrating or new
    return integrityHash == calculateHash(secretKey);
  }
}

class PlayerProgressAdapter extends TypeAdapter<PlayerProgress> {
  @override
  final int typeId = 2; // Bumped version for new fields

  @override
  PlayerProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerProgress(
      playerId: fields[0] as String,
      totalXP: fields[1] as int,
      coins: fields[2] as int,
      streakCount: fields[3] as int,
      bestStreak: fields[4] as int,
      levelStars: (fields[5] as Map).cast<String, int>(),
      unlockedAchievements: (fields[6] as List).cast<String>(),
      lastLoginDate: fields[7] as DateTime?,
      integrityHash: fields[8] as String?,
      // Adaptive fields (schema v1); absent in legacy saves → safe defaults.
      difficultyMode: fields[9] != null
          ? DifficultyMode.values[fields[9] as int]
          : DifficultyMode.standard,
      adaptiveHistory: fields[10] != null
          ? (fields[10] as List).cast<int>()
          : const [],
      adaptiveVersion: fields[11] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProgress obj) {
    writer
      ..writeByte(12) // 12 fields total (9 original + 3 adaptive)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.totalXP)
      ..writeByte(2)
      ..write(obj.coins)
      ..writeByte(3)
      ..write(obj.streakCount)
      ..writeByte(4)
      ..write(obj.bestStreak)
      ..writeByte(5)
      ..write(obj.levelStars)
      ..writeByte(6)
      ..write(obj.unlockedAchievements)
      ..writeByte(7)
      ..write(obj.lastLoginDate)
      ..writeByte(8)
      ..write(obj.integrityHash)
      ..writeByte(9)
      ..write(obj.difficultyMode.index)
      ..writeByte(10)
      ..write(obj.adaptiveHistory)
      ..writeByte(11)
      ..write(obj.adaptiveVersion);
  }
}
