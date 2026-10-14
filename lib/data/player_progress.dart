import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../core/engine/achievement_engine.dart';
import '../core/engine/progression_engine.dart';
import '../core/engine/streak_engine.dart';

export 'player_progress_adapter.dart';

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
  DateTime?
  lastShareDate; // last calendar day on which a share-refuel was granted
  // Schema version 4: engagement fields (Hive fields 17–22).
  int streakFreezeCount; // streak freeze items owned
  List<int> streakMilestones; // milestone thresholds already achieved
  Map<String, int> achievementProgress; // partial progress per achievement id
  int dailyRewardDay; // current day in 7-day reward cycle (0 = not started)
  DateTime?
  lastDailyRewardClaim; // last calendar day a daily reward was claimed
  List<DateTime>
  playHistory; // dates played (capped at 365) for streak calendar
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
  Map<String, String>
  levelBestDifficulty; // best difficulty tier name per level
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
    adaptiveHistory = updated.length > 20
        ? updated.sublist(updated.length - 20)
        : updated;
    adaptiveVersion = 2;
  }

  /// Applies one completed puzzle to this record in a single step: star,
  /// XP, bests, daily XP, coins, adaptive history, lower-level heart refuel
  /// and achievement unlocks. Returns the ids of achievements newly unlocked
  /// by this result. Callers must persist the same object afterwards.
  List<String> commitLevelResult({
    required String levelId,
    required int levelIndex,
    required int stars,
    required bool hintUsed,
    required int timeSeconds,
    String? difficultyName,
  }) {
    final previousStars = levelStars[levelId] ?? 0;
    final isFirstClear = previousStars == 0 && stars > 0;
    if (stars > previousStars) {
      levelStars = Map<String, int>.from(levelStars)..[levelId] = stars;
    }

    final gainedXP = ProgressionEngine.computeXP(stars, hintUsed: hintUsed);
    totalXP += gainedXP;
    recordLevelXP(levelId, gainedXP);
    recordLevelTime(levelId, timeSeconds);
    if (difficultyName != null) recordLevelDifficulty(levelId, difficultyName);
    addDailyXP(gainedXP);
    recordLevelResult(stars);
    addCoins(
      ProgressionEngine.computeCoinReward(
        stars: stars,
        isFirstClear: isFirstClear,
      ),
    );

    final completedCount = levelStars.values.where((s) => s > 0).length;
    if (ProgressionEngine.isLowerLevel(levelIndex, completedCount)) {
      refuelHeartLowerLevel();
    }

    final newlyUnlocked = AchievementEngine.evaluateAll(
      totalLevelsCompleted: completedCount,
      totalStars: levelStars.values.fold(0, (sum, s) => sum + s),
      totalXP: totalXP,
      currentStreak: streakCount,
      achievementProgress: achievementProgress,
      alreadyUnlocked: unlockedAchievements,
    );
    for (final achievement in newlyUnlocked) {
      addCoins(achievement.coinReward);
    }
    unlockedAchievements = [
      ...unlockedAchievements,
      for (final achievement in newlyUnlocked) achievement.id,
    ];
    return [for (final achievement in newlyUnlocked) achievement.id];
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
    heartRefuelAt = hearts < 5
        ? ProgressionEngine.computeNextRefuelTime(now)
        : null;
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
    if (lastShareDate != null &&
        lastShareDate!.year == now.year &&
        lastShareDate!.month == now.month &&
        lastShareDate!.day == now.day) {
      return false;
    }
    shareBonusGames = shareBonusAmount;
    lastShareDate = DateTime(now.year, now.month, now.day);
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
    final isDuplicate = playHistory.any(
      (d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day,
    );
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
    assert(
      order.contains(tierName),
      'recordLevelDifficulty: unknown tier "$tierName"',
    );
    final current = levelBestDifficulty[levelId];
    final currentRank = current != null ? order.indexOf(current) : -1;
    final newRank = order.indexOf(tierName);
    if (newRank > currentRank) {
      levelBestDifficulty = Map<String, String>.from(levelBestDifficulty)
        ..[levelId] = tierName;
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
    if (totalCoins >= CurrencyTier.diamond.minCoins) {
      return CurrencyTier.diamond;
    }
    if (totalCoins >= CurrencyTier.gold.minCoins) return CurrencyTier.gold;
    return CurrencyTier.silver;
  }
}
