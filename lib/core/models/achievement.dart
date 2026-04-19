/// Achievement data model — pure Dart, no Flutter imports.
library;

enum AchievementCategory { progress, skill, math, physics, exploration }

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final int threshold; // numeric target (e.g., 10 levels completed)
  final int coinReward;
  final String iconName; // Material icon name reference

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.threshold,
    required this.coinReward,
    this.iconName = 'emoji_events',
  });
}
