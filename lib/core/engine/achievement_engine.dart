/// Pure-Dart achievement engine — no Flutter imports.
///
/// Defines the achievement catalog, evaluates unlock conditions, and
library;

/// computes progress percentages.

import '../models/achievement.dart';

class AchievementEngine {
  AchievementEngine._(); // static-only

  /// The full achievement catalog.
  static const catalog = <Achievement>[
    // ── Progress ──
    Achievement(
      id: 'first_steps',
      title: 'First Steps',
      description: 'Complete your first level',
      category: AchievementCategory.progress,
      threshold: 1,
      coinReward: 10,
      iconName: 'directions_walk',
    ),
    Achievement(
      id: 'level_master_50',
      title: 'Level Master',
      description: 'Complete 50 levels',
      category: AchievementCategory.progress,
      threshold: 50,
      coinReward: 200,
      iconName: 'military_tech',
    ),
    Achievement(
      id: 'level_master_100',
      title: 'Century Player',
      description: 'Complete 100 levels',
      category: AchievementCategory.progress,
      threshold: 100,
      coinReward: 500,
      iconName: 'emoji_events',
    ),
    // ── Stars ──
    Achievement(
      id: 'star_collector_50',
      title: 'Star Collector',
      description: 'Earn 50 stars',
      category: AchievementCategory.skill,
      threshold: 50,
      coinReward: 100,
      iconName: 'star',
    ),
    Achievement(
      id: 'star_collector_200',
      title: 'Star Hoarder',
      description: 'Earn 200 stars',
      category: AchievementCategory.skill,
      threshold: 200,
      coinReward: 400,
      iconName: 'stars',
    ),
    // ── XP ──
    Achievement(
      id: 'xp_1000',
      title: 'Knowledge Seeker',
      description: 'Earn 1 000 XP',
      category: AchievementCategory.exploration,
      threshold: 1000,
      coinReward: 100,
      iconName: 'school',
    ),
    Achievement(
      id: 'xp_10000',
      title: 'Scholar',
      description: 'Earn 10 000 XP',
      category: AchievementCategory.exploration,
      threshold: 10000,
      coinReward: 500,
      iconName: 'auto_stories',
    ),
    // ── Streak ──
    Achievement(
      id: 'streak_week',
      title: 'Week Warrior',
      description: 'Maintain a 7-day streak',
      category: AchievementCategory.exploration,
      threshold: 7,
      coinReward: 50,
      iconName: 'local_fire_department',
    ),
    Achievement(
      id: 'streak_month',
      title: 'Monthly Dedication',
      description: 'Maintain a 30-day streak',
      category: AchievementCategory.exploration,
      threshold: 30,
      coinReward: 300,
      iconName: 'whatshot',
    ),
  ];

  static final _byId = {for (final a in catalog) a.id: a};

  /// Returns newly unlocked achievements given the player's current stats.
  static List<Achievement> evaluateAll({
    required int totalLevelsCompleted,
    required int totalStars,
    required int totalXP,
    required int currentStreak,
    required Map<String, int> achievementProgress,
    required List<String> alreadyUnlocked,
  }) {
    final unlocked = Set<String>.from(alreadyUnlocked);
    return catalog.where((a) {
      if (unlocked.contains(a.id)) return false;
      return _currentValue(
            a,
            totalLevelsCompleted: totalLevelsCompleted,
            totalStars: totalStars,
            totalXP: totalXP,
            currentStreak: currentStreak,
            achievementProgress: achievementProgress,
          ) >=
          a.threshold;
    }).toList();
  }

  /// Fractional progress (0.0 – 1.0) for a single achievement.
  static double progressFor({
    required String achievementId,
    required int totalLevelsCompleted,
    required int totalStars,
    required int totalXP,
    required int currentStreak,
    required Map<String, int> achievementProgress,
  }) {
    final a = _byId[achievementId];
    if (a == null) return 0.0;
    final value = _currentValue(
      a,
      totalLevelsCompleted: totalLevelsCompleted,
      totalStars: totalStars,
      totalXP: totalXP,
      currentStreak: currentStreak,
      achievementProgress: achievementProgress,
    );
    return (value / a.threshold).clamp(0.0, 1.0);
  }

  /// Maps an achievement to the player metric that drives it.
  static int _currentValue(
    Achievement a, {
    required int totalLevelsCompleted,
    required int totalStars,
    required int totalXP,
    required int currentStreak,
    required Map<String, int> achievementProgress,
  }) {
    switch (a.id) {
      case 'first_steps':
      case 'level_master_50':
      case 'level_master_100':
        return totalLevelsCompleted;
      case 'star_collector_50':
      case 'star_collector_200':
        return totalStars;
      case 'xp_1000':
      case 'xp_10000':
        return totalXP;
      case 'streak_week':
      case 'streak_month':
        return currentStreak;
      default:
        return achievementProgress[a.id] ?? 0;
    }
  }
}
