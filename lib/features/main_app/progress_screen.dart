import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/achievement_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/progress_ring.dart';
import '../../widgets/skill_radar.dart';
import '../../widgets/stat_pill.dart';
import '../../widgets/weekly_bars.dart';

/// Progress screen — XP hero, cognitive radar, weekly activity, achievements.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    return progressAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AethericPulseDark.brandBlue),
      ),
      error: (e, _) => Center(
        child: Text(
          'Error loading progress',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (progress) => _ProgressBody(progress: progress),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final PlayerProgress progress;
  const _ProgressBody({required this.progress});

  // Derive 6 skill scores from adaptive history + level stars.
  // These are approximations — the engine doesn't expose per-skill scores yet.
  List<SkillScore> _deriveSkills() {
    final history = progress.adaptiveHistory;
    final base = history.isEmpty
        ? 50
        : (history.reduce((a, b) => a + b) / history.length * 20).clamp(0, 100);
    final totalStars = progress.levelStars.values.fold<int>(0, (a, b) => a + b);
    final starScore = (totalStars * 1.0).clamp(0, 100).toInt();
    final blended = ((base + starScore) / 2).toInt();
    return [
      SkillScore(
        name: 'Pattern Recognition',
        value: blended.toDouble(),
        color: AP.blueLight,
      ),
      SkillScore(
        name: 'Working Memory',
        value: (blended + 8).clamp(0, 100).toDouble(),
        color: AP.cyan,
      ),
      SkillScore(
        name: 'Logical Reasoning',
        value: (blended + 16).clamp(0, 100).toDouble(),
        color: AP.purple,
      ),
      SkillScore(
        name: 'Reaction Speed',
        value: (blended + 24).clamp(0, 100).toDouble(),
        color: AP.orange,
      ),
      SkillScore(
        name: 'Spatial Sense',
        value: (blended - 8).clamp(0, 100).toDouble(),
        color: AP.emerald,
      ),
      SkillScore(
        name: 'Focus',
        value: (blended + 11).clamp(0, 100).toDouble(),
        color: AP.pink,
      ),
    ];
  }

  List<int> _deriveWeeklyXp() {
    final today = DateTime.now();
    // play history is a list of DateTime — count plays per day, multiply by avg 4 XP
    final byDay = List<int>.filled(7, 0);
    for (final d in progress.playHistory) {
      final diff = today.difference(DateTime(d.year, d.month, d.day)).inDays;
      if (diff >= 0 && diff < 7) {
        byDay[6 - diff] += 4; // rough XP estimate per play
      }
    }
    // Override today with real dailyXP if available
    if (progress.dailyXPDate != null &&
        DateTime(
              progress.dailyXPDate!.year,
              progress.dailyXPDate!.month,
              progress.dailyXPDate!.day,
            ) ==
            DateTime(today.year, today.month, today.day)) {
      byDay[6] = progress.dailyXP;
    }
    return byDay;
  }

  List<AchievementData> _buildAchievements() {
    final unlocked = progress.unlockedAchievements.toSet();
    final prog = progress.achievementProgress;
    final defs = [
      ('novice_mind', 'Novice mind', 'Complete your first puzzle', 1),
      ('focus_master', 'Focus master', '15 perfect runs', 15),
      ('memory_marvel', 'Memory marvel', 'Beat Memory Lab level 25', 25),
      ('logic_legend', 'Logic legend', '30 logic puzzles, no hints', 30),
      ('daily_spark', 'Daily spark', '7-day streak', 7),
      ('ultimate_brain', 'Ultimate brain', 'All tracks at level 20+', 23),
    ];
    return defs.map((d) {
      final (id, name, sub, total) = d;
      return AchievementData(
        id: id,
        name: name,
        subtitle: sub,
        unlocked: unlocked.contains(id),
        progress: prog[id] ?? 0,
        total: total,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final xp = progress.totalXP;
    final level = (xp ~/ 1000) + 1;
    final levelXp = xp % 1000;
    final levelPct = levelXp / 10.0; // 0–100
    final totalStars = progress.levelStars.values.fold<int>(0, (a, b) => a + b);
    final skills = _deriveSkills();
    final weekly = _deriveWeeklyXp();
    final achievements = _buildAchievements();
    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
      children: [
        // ── XP Hero ───────────────────────────────────────────────────────
        GlassCard(
          borderRadius: 28,
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              ProgressRing(
                percent: levelPct,
                size: 132,
                strokeWidth: 10,
                centerChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (r) => AP.gradPrimary.createShader(r),
                      child: Text(
                        '$xp',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFeatures: [FontFeature.tabularFigures()],
                          height: 1.0,
                          letterSpacing: -0.84,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('TOTAL XP', style: AP.eyebrow()),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('PILOT RANK', style: AP.eyebrow()),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Lv ',
                          style: AP.headlineMd().copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        ShaderMask(
                          shaderCallback: (r) => AP.gradPrimary.createShader(r),
                          child: Text(
                            '$level',
                            style: AP.headlineMd().copyWith(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${1000 - levelXp} XP to level ${level + 1}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AP.fgMeta,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: (levelPct / 100).clamp(0.0, 1.0),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AP.gradPrimary,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: AP.blueLight.withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // BL-08 Economy Messaging Clarity:
                        // explicit units + Semantics labels so players
                        // understand what each stat means without tapping.
                        Semantics(
                          label:
                              'Daily streak: ${progress.streakCount} day${progress.streakCount == 1 ? '' : 's'}',
                          child: StatPill(
                            icon: const Icon(Icons.local_fire_department),
                            label: '${progress.streakCount} day',
                            tint: StatPillTint.orange,
                          ),
                        ),
                        Semantics(
                          label: 'Total stars earned: $totalStars',
                          child: StatPill(
                            icon: const Icon(Icons.star),
                            label: '$totalStars ★',
                            tint: StatPillTint.purple,
                          ),
                        ),
                        Semantics(
                          label:
                              '${progress.freeGamesRemaining} of 25 daily sessions remaining. Resets at midnight.',
                          child: StatPill(
                            icon: const Icon(Icons.bolt),
                            label: '${progress.freeGamesRemaining}/25',
                            tint: StatPillTint.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Cognitive radar ───────────────────────────────────────────────
        GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Cognitive map',
                      overflow: TextOverflow.ellipsis,
                      style: AP.headlineMd().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('7-DAY DELTA', style: AP.eyebrow()),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SkillRadar(skills: skills),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: skills.map((s) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(color: s.color, blurRadius: 6),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.name,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5,
                                    color: AP.fgSecondary,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Text(
                                '${s.value.toInt()}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: s.color,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Weekly bars ───────────────────────────────────────────────────
        GlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This week',
                    style: AP.headlineMd().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${weekly.fold<int>(0, (a, b) => a + b)}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AP.amber,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        ' XP earned',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AP.fgMeta,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              WeeklyBars(dailyXp: weekly),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Milestones / achievements ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Milestones',
              style: AP.headlineMd().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$unlockedCount of ${achievements.length} unlocked',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AP.fgMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.78,
          ),
          itemCount: achievements.length,
          itemBuilder: (_, i) => AchievementCard(a: achievements[i]),
        ),
      ],
    );
  }
}
