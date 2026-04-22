import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

import '../core/engine/progression_engine.dart';
import '../core/engine/streak_engine.dart';

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
  // Schema version 4: engagement fields (Hive fields 17–22).
  int streakFreezeCount; // streak freeze items owned
  List<int> streakMilestones; // milestone thresholds already achieved
  Map<String, int> achievementProgress; // partial progress per achievement id
  int dailyRewardDay; // current day in 7-day reward cycle (0 = not started)
  DateTime? lastDailyRewardClaim; // last calendar day a daily reward was claimed
  List<DateTime> playHistory; // dates played (capped at 365) for streak calendar
  // Schema version 5: onboarding tracking (Hive field 23).
  bool onboardingComplete; // whether the user has seen the onboarding flow
  // Schema version 5: free-games allowance (Hive fields 24–26).
  int freeGamesRemaining; // games left today (resets daily to freeGamesLimit)
  DateTime? lastAllowanceReset; // last day the allowance was reset
  int shareBonusGames; // extra games earned from today's share (0 or 40)
  // Schema version 6: per-level XP, best time, best difficulty, daily XP (Hive fields 27–31).
  int dailyXP; // XP earned today (resets on new calendar day)
  DateTime? dailyXPDate; // the calendar day dailyXP was last updated
  Map<String, int> levelXP; // best XP earned per level (keyed by levelId)
  Map<String, int> levelBestTime; // best completion time in seconds per level
  Map<String, String> levelBestDifficulty; // best difficulty tier name per level
  // Schema version 7: theme mode override (Hive field 32).
  // null = follow system; 0 = ThemeMode.system; 1 = light; 2 = dark.
  int? themeModeOverride;

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
    this.streakFreezeCount = 0,
    this.streakMilestones = const [],
    this.achievementProgress = const {},
    this.dailyRewardDay = 0,
    this.lastDailyRewardClaim,
    this.playHistory = const [],
    this.onboardingComplete = false,
    this.freeGamesRemaining = 25,
    this.lastAllowanceReset,
    this.shareBonusGames = 0,
    this.dailyXP = 0,
    this.dailyXPDate,
    this.levelXP = const {},
    this.levelBestTime = const {},
    this.levelBestDifficulty = const {},
    this.themeModeOverride,
  });

  factory PlayerProgress.fresh({required String playerId}) {
    return PlayerProgress(playerId: playerId);
  }

  /// Appends [stars] (0–5) to [adaptiveHistory], keeping the 20 most recent
  /// entries, and marks the schema version as 2 (0–5 scale adaptive data).
  void recordLevelResult(int stars) {
    assert(stars >= 0 && stars <= 5);
    final updated = List<int>.from(adaptiveHistory)..add(stars);
    adaptiveHistory =
        updated.length > 20 ? updated.sublist(updated.length - 20) : updated;
    adaptiveVersion = 2;
  }

  /// Records a login, updating the streak and granting any new milestone
  /// rewards (coins and streak freezes). Returns the list of newly achieved
  /// milestone thresholds so the UI can show a reward toast.
  List<int> recordLogin({DateTime? now}) {
    now ??= DateTime.now();
    if (lastLoginDate == null) {
      streakCount = 1;
      bestStreak = 1;
    } else {
      final result = StreakEngine.checkStreak(
        lastLoginDate: lastLoginDate,
        now: now,
        streakFreezeCount: streakFreezeCount,
      );
      switch (result) {
        case StreakResult.continued:
          streakCount += 1;
          if (streakCount > bestStreak) bestStreak = streakCount;
        case StreakResult.frozen:
          // Streak preserved — consume one freeze
          useStreakFreeze();
          streakCount += 1;
          if (streakCount > bestStreak) bestStreak = streakCount;
        case StreakResult.broken:
          streakCount = 1;
      }
    }
    lastLoginDate = now;

    // ── Check and grant milestones ────────────────────────────────────
    final newMilestones = StreakEngine.checkMilestones(
      currentStreak: streakCount,
      alreadyAchieved: streakMilestones,
    );
    for (final m in newMilestones) {
      coins += StreakEngine.computeMilestoneReward(m);
      streakMilestones = List<int>.from(streakMilestones)..add(m);
    }
    // Every 7 days earns a free freeze
    if (StreakEngine.earnsFreezeForStreak(streakCount)) {
      streakFreezeCount += 1;
    }
    return newMilestones;
  }

  /// The next streak milestone not yet reached, or null if all are achieved.
  int? get nextMilestone {
    final achieved = Set<int>.from(streakMilestones);
    for (final m in StreakEngine.milestones) {
      if (!achieved.contains(m)) return m;
    }
    return null;
  }

  /// Coin reward for [nextMilestone], or 0.
  int get nextMilestoneReward {
    final nm = nextMilestone;
    return nm != null ? StreakEngine.computeMilestoneReward(nm) : 0;
  }

  static String _sortedMapPayload(Map<String, int> m) {
    final keys = m.keys.toList()..sort();
    return keys.map((k) => '$k:${m[k]}').join(',');
  }

  static String _sortedStringMapPayload(Map<String, String> m) {
    final keys = m.keys.toList()..sort();
    return keys.map((k) => '$k:${m[k]}').join(',');
  }

  String calculateHash(String secretKey) {
    final parts = <String>[
      playerId,
      '$totalXP',
      '$coins',
      '$streakCount',
      '$bestStreak',
      _sortedMapPayload(levelStars),
      '$hearts',
      '$diamonds',
      adaptiveHistory.join(','),
      '${difficultyMode.index}',
      seenTutorialWorlds.join(','),
      '$streakFreezeCount',
      '$dailyRewardDay',
      streakMilestones.join(','),
      unlockedAchievements.join(','),
      _sortedMapPayload(achievementProgress),
      lastDailyRewardClaim?.toUtc().toIso8601String() ?? '',
      playHistory.map((d) => d.toUtc().toIso8601String()).join(','),
      '$dailyXP',
      dailyXPDate?.toUtc().toIso8601String() ?? '',
      _sortedMapPayload(levelXP),
      _sortedMapPayload(levelBestTime),
      _sortedStringMapPayload(levelBestDifficulty),
    ];
    final payload = parts.join('|');

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

  /// Marks the onboarding flow as complete.
  void completeOnboarding() {
    onboardingComplete = true;
  }

  // ─── Free-games allowance helpers ────────────────────────────────────────

  static const int dailyFreeGamesLimit = 25;
  static const int shareBonusAmount = 40;

  /// Ensures the daily allowance has been reset if a new calendar day has
  /// started. Call this at game start to keep the counter accurate.
  void checkAllowanceReset(DateTime now) {
    if (lastAllowanceReset == null ||
        lastAllowanceReset!.year != now.year ||
        lastAllowanceReset!.month != now.month ||
        lastAllowanceReset!.day != now.day) {
      freeGamesRemaining = dailyFreeGamesLimit;
      shareBonusGames = 0;
      lastAllowanceReset = now;
    }
  }

  /// Returns the total games available (base + share bonus).
  int get totalGamesAvailable => freeGamesRemaining + shareBonusGames;

  /// Consumes one game from the allowance.
  /// Returns false if no games remain.
  bool consumeFreeGame() {
    if (freeGamesRemaining > 0) {
      freeGamesRemaining--;
      return true;
    }
    if (shareBonusGames > 0) {
      shareBonusGames--;
      return true;
    }
    return false;
  }

  /// Grants the share bonus (40 games) for today.
  /// Returns false if already granted today.
  bool grantShareBonus(DateTime now) {
    checkAllowanceReset(now);
    if (shareBonusGames > 0) return false;
    shareBonusGames = shareBonusAmount;
    return true;
  }

  /// Grants +1 heart (capped at 5) as a reward for sharing the app.
  /// Limited to once per calendar day (comparing year/month/day of [now]).
  /// Returns true when a heart was actually granted.
  ///
  /// Note: on iOS, `ShareResultStatus.success` only means the user selected
  /// a share target in the share sheet — it does not guarantee the message
  /// was actually delivered to the recipient. This is a known platform
  /// limitation.
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

  // ─── Coin mutation helpers ────────────────────────────────────────────────

  /// Adds [amount] coins to the balance. [amount] must be non-negative.
  void addCoins(int amount) {
    assert(amount >= 0, 'addCoins: amount must be non-negative');
    coins += amount;
  }

  /// Spends [amount] coins from the balance.
  /// Returns false (no-op) when insufficient balance.
  /// [amount] must be positive.
  bool spendCoins(int amount) {
    assert(amount > 0, 'spendCoins: amount must be positive');
    if (coins < amount) return false;
    coins -= amount;
    return true;
  }

  // ─── Streak freeze helpers ────────────────────────────────────────────────

  /// Adds 1 streak freeze item to inventory.
  void addStreakFreeze() {
    streakFreezeCount++;
  }

  /// Consumes 1 streak freeze. Returns false (no-op) when none available.
  bool useStreakFreeze() {
    if (streakFreezeCount <= 0) return false;
    streakFreezeCount--;
    return true;
  }

  // ─── Play history helpers ─────────────────────────────────────────────────

  /// Records [date] in play history (one entry per calendar day, max 365).
  void recordPlayDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final isDuplicate = playHistory.any((d) =>
        d.year == dateOnly.year &&
        d.month == dateOnly.month &&
        d.day == dateOnly.day);
    if (isDuplicate) return;
    final updated = List<DateTime>.from(playHistory)..add(dateOnly);
    playHistory = updated.length > 365
        ? updated.sublist(updated.length - 365)
        : updated;
  }

  // ─── Schema v6 helpers ───────────────────────────────────────────────────

  /// Records [xp] earned for [levelId], keeping the best (highest) value.
  void recordLevelXP(String levelId, int xp) {
    final best = levelXP[levelId] ?? 0;
    if (xp > best) {
      levelXP = Map<String, int>.from(levelXP)..[levelId] = xp;
    }
  }

  /// Records [seconds] completion time for [levelId], keeping the best (lowest) value.
  void recordLevelTime(String levelId, int seconds) {
    final best = levelBestTime[levelId];
    if (best == null || seconds < best) {
      levelBestTime = Map<String, int>.from(levelBestTime)..[levelId] = seconds;
    }
  }

  /// Records [tierName] as the best difficulty achieved for [levelId].
  /// "Best" is ordered: challenge > hard > medium > easy.
  void recordLevelDifficulty(String levelId, String tierName) {
    const order = ['easy', 'medium', 'hard', 'challenge'];
    assert(order.contains(tierName), 'recordLevelDifficulty: unknown tier "$tierName"');
    final current = levelBestDifficulty[levelId];
    final currentRank = current != null ? order.indexOf(current) : -1;
    final newRank = order.indexOf(tierName);
    if (newRank > currentRank) {
      levelBestDifficulty =
          Map<String, String>.from(levelBestDifficulty)..[levelId] = tierName;
    }
  }

  /// Adds [xp] to [dailyXP], resetting the counter if [today] is a new calendar day.
  void addDailyXP(int xp, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final storedDate = dailyXPDate;
    if (storedDate == null ||
        storedDate.year != todayDate.year ||
        storedDate.month != todayDate.month ||
        storedDate.day != todayDate.day) {
      dailyXP = xp;
    } else {
      dailyXP = dailyXP + xp;
    }
    dailyXPDate = todayDate;
  }

  // ─── Daily reward helpers ─────────────────────────────────────────────────

  /// Records claiming daily reward for [day] at [now].
  void claimDailyReward(int day, DateTime now) {
    assert(day >= 1 && day <= 7, 'claimDailyReward: day must be 1–7');
    dailyRewardDay = day;
    lastDailyRewardClaim = now;
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

/// Tiered currency progression: Silver → Gold → Diamond.
///
/// Tiers are purely cosmetic status indicators based on lifetime coin earnings.
enum CurrencyTier {
  silver('Silver', 0),
  gold('Gold', 1000),
  diamond('Diamond', 5000);

  const CurrencyTier(this.displayName, this.minCoins);

  final String displayName;
  final int minCoins;

  /// Returns the highest tier that [totalCoins] qualifies for.
  static CurrencyTier tierForCoins(int totalCoins) {
    if (totalCoins >= CurrencyTier.diamond.minCoins) return CurrencyTier.diamond;
    if (totalCoins >= CurrencyTier.gold.minCoins) return CurrencyTier.gold;
    return CurrencyTier.silver;
  }
}
