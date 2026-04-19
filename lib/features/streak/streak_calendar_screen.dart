import 'package:flutter/material.dart';

import '../../theme/design_system.dart';
import 'streak_calendar_widget.dart';

class StreakCalendarScreen extends StatelessWidget {
  final int streakCount;
  final int bestStreak;
  final List<DateTime> playHistory;
  final int streakFreezeCount;
  final int? nextMilestone;
  final int nextMilestoneReward;

  const StreakCalendarScreen({
    super.key,
    required this.streakCount,
    required this.bestStreak,
    required this.playHistory,
    this.streakFreezeCount = 0,
    this.nextMilestone,
    this.nextMilestoneReward = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streak Calendar')),
      body: Padding(
        padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
        child: StreakCalendarWidget(
          streakCount: streakCount,
          bestStreak: bestStreak,
          playHistory: playHistory,
          streakFreezeCount: streakFreezeCount,
          nextMilestone: nextMilestone,
          nextMilestoneReward: nextMilestoneReward,
        ),
      ),
    );
  }
}
