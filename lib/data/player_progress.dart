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
  List<int> adaptiveHistory; // Star ratings from recent levels (0–5 each)
  int adaptiveVersion; // 0 = no adaptive data, 1 = old 1–3 scale, 2 = 0–5 scale
  // Engagement loop fields (schema version 2).
  // Hive fields 12–15; missing in old saves → defaults applied in adapter.
  int hearts; // 0–5; refuels over time or via actions
  int diamonds; // premium currency; earned via run bonuses
  DateTime? heartRefuelAt; // when the next timed heart will be granted
  List<String> seenTutorialWorlds; // world IDs where tutorial was dismissed
  // Schema version 3: share refuel (Hive field 16).
  DateTime? lastShareDate; // last calendar day on which a share-refuel was granted

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
    this.hearts = 5,
    this.diamonds = 0,
    this.heartRefuelAt,
    this.seenTutorialWorlds = const [],
    this.lastShareDate,
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

  // ─── Engagement-loop mutation helpers ─────────────────────────────────────

  /// Deducts 1 heart; floors at 0.
  void deductHeart() {
    if (hearts > 0) hearts--;
  }

  /// Sets hearts to 5 and deducts 1 diamond.
  /// Returns false (no-op) when no diamonds are available.
  bool refuelHeartsWithDiamond() {
    if (diamonds < 1) return false;
    diamonds--;
    hearts = 5;
    return true;
  }

  /// Adds [count] diamonds (defaults to 1).
  void addDiamond([int count = 1]) {
    diamonds += count;
  }

  /// Checks whether the timed heart-refuel window has elapsed.
  /// If yes, grants +1 heart (capped at 5) and reschedules or clears
  /// [heartRefuelAt] depending on whether more hearts are still needed.
  /// Returns true when a heart was actually granted.
  bool checkAndRefuelHeart(DateTime now) {
    if (hearts >= 5) {
      heartRefuelAt = null;
      return false;
    }
    if (!ProgressionEngine.shouldRefuelByTime(heartRefuelAt, now)) return false;
    hearts++;
    heartRefuelAt =
        hearts < 5 ? ProgressionEngine.computeNextRefuelTime(now) : null;
    return true;
  }

  /// Grants +1 heart (capped at 5) as a reward for completing a lower-ranked
  /// level.
  void refuelHeartLowerLevel() {
    if (hearts < 5) hearts++;
  }

  /// Records [worldId] as seen in the tutorial. Idempotent.
  void markTutorialSeen(String worldId) {
    if (!seenTutorialWorlds.contains(worldId)) {
      seenTutorialWorlds = List<String>.from(seenTutorialWorlds)..add(worldId);
    }
  }

  /// Grants +1 heart (capped at 5) as a reward for sharing the app.
  /// Limited to once per calendar day (comparing year/month/day of [now]).
  /// Returns true when a heart was actually granted.
  bool shareAndRefuel(DateTime now) {
    if (hearts >= 5) return false;
    if (lastShareDate != null &&
        lastShareDate!.year == now.year &&
        lastShareDate!.month == now.month &&
        lastShareDate!.day == now.day) {
      return false;
    }
    hearts++;
    lastShareDate = now;
    return true;
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

    // Adaptive history migration: scale 1–3 values to 0–5 scale.
    final rawHistory = fields[10] != null
        ? (fields[10] as List).cast<int>()
        : const <int>[];
    final rawVersion = fields[11] as int? ?? 0;
    final migratedHistory = rawVersion == 1
        ? ProgressionEngine.migrateAdaptiveHistory(rawHistory)
        : rawHistory;
    final migratedVersion = rawVersion == 1 ? 2 : rawVersion;

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
      // Adaptive fields (schema v1–2); absent in legacy saves → safe defaults.
      difficultyMode: fields[9] != null
          ? DifficultyMode.values[fields[9] as int]
          : DifficultyMode.standard,
      adaptiveHistory: migratedHistory,
      adaptiveVersion: migratedVersion,
      // Engagement loop fields (schema v2); absent in legacy saves → defaults.
      hearts: fields[12] as int? ?? 5,
      diamonds: fields[13] as int? ?? 0,
      heartRefuelAt: fields[14] as DateTime?,
      seenTutorialWorlds: fields[15] != null
          ? (fields[15] as List).cast<String>()
          : const [],
      lastShareDate: fields[16] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProgress obj) {
    writer
      ..writeByte(17) // 17 fields total (9 original + 3 adaptive + 4 engagement-loop + 1 share)
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
      ..write(obj.adaptiveVersion)
      ..writeByte(12)
      ..write(obj.hearts)
      ..writeByte(13)
      ..write(obj.diamonds)
      ..writeByte(14)
      ..write(obj.heartRefuelAt)
      ..writeByte(15)
      ..write(obj.seenTutorialWorlds)
      ..writeByte(16)
      ..write(obj.lastShareDate);
  }
}
