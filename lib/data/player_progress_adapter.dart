import 'package:hive/hive.dart';

import '../core/engine/progression_engine.dart';
import 'player_progress.dart';

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
      // Schema v4 engagement fields; absent in legacy saves → defaults.
      streakFreezeCount: fields[17] as int? ?? 0,
      streakMilestones: fields[18] != null
          ? (fields[18] as List).cast<int>()
          : const [],
      achievementProgress: fields[19] != null
          ? (fields[19] as Map).cast<String, int>()
          : const {},
      dailyRewardDay: fields[20] as int? ?? 0,
      lastDailyRewardClaim: fields[21] as DateTime?,
      playHistory: fields[22] != null
          ? (fields[22] as List).cast<DateTime>()
          : const [],
      onboardingComplete: fields[23] as bool? ?? false,
      freeGamesRemaining: fields[24] as int? ?? 25,
      lastAllowanceReset: fields[25] as DateTime?,
      shareBonusGames: fields[26] as int? ?? 0,
      // Schema v6: per-level XP, best time, best difficulty, daily XP.
      dailyXP: fields[27] as int? ?? 0,
      dailyXPDate: fields[28] as DateTime?,
      levelXP: fields[29] != null
          ? (fields[29] as Map).cast<String, int>()
          : const {},
      levelBestTime: fields[30] != null
          ? (fields[30] as Map).cast<String, int>()
          : const {},
      levelBestDifficulty: fields[31] != null
          ? (fields[31] as Map).cast<String, String>()
          : const {},
      // Schema v7: theme mode override; null in legacy saves → follow system.
      themeModeOverride: fields[32] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerProgress obj) {
    writer
      ..writeByte(33) // 33 fields total (schema v7: themeModeOverride)
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
      ..write(obj.lastShareDate)
      ..writeByte(17)
      ..write(obj.streakFreezeCount)
      ..writeByte(18)
      ..write(obj.streakMilestones)
      ..writeByte(19)
      ..write(obj.achievementProgress)
      ..writeByte(20)
      ..write(obj.dailyRewardDay)
      ..writeByte(21)
      ..write(obj.lastDailyRewardClaim)
      ..writeByte(22)
      ..write(obj.playHistory)
      ..writeByte(23)
      ..write(obj.onboardingComplete)
      ..writeByte(24)
      ..write(obj.freeGamesRemaining)
      ..writeByte(25)
      ..write(obj.lastAllowanceReset)
      ..writeByte(26)
      ..write(obj.shareBonusGames)
      ..writeByte(27)
      ..write(obj.dailyXP)
      ..writeByte(28)
      ..write(obj.dailyXPDate)
      ..writeByte(29)
      ..write(obj.levelXP)
      ..writeByte(30)
      ..write(obj.levelBestTime)
      ..writeByte(31)
      ..write(obj.levelBestDifficulty)
      ..writeByte(32)
      ..write(obj.themeModeOverride);
  }
}
