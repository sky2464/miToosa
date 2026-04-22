import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_text.dart';

// ─── Progress screen — Kinetic Obsidian ───────────────────────────────────────

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    return progressAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: KineticObsidian.electricCyan)),
      error: (e, _) => Center(
          child: Text('Error', style: Theme.of(context).textTheme.bodyMedium)),
      data: (progress) => _ProgressBody(progress: progress),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final PlayerProgress progress;
  const _ProgressBody({required this.progress});

  @override
  Widget build(BuildContext context) {
    final xp = progress.totalXP;
    final levelXp = xp % 1000;
    final levelPct = levelXp / 10.0;
    final level = (xp ~/ 1000) + 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceMd,
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceLg + 80,
      ),
      children: [
        // XP Hero
        _XpHero(xp: xp, levelPct: levelPct, level: level),
        const SizedBox(height: 16),
        // 2×2 stat grid
        Row(
          children: [
            Expanded(
                child: _StatTile(
              icon: Icons.local_fire_department,
              value: '${progress.streakCount}',
              label: 'Day Streak',
              iconColor: const Color(0xFFFFB4AB),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _StatTile(
              icon: Icons.military_tech,
              value: '${progress.levelStars.values.fold(0, (a, b) => a + b)}',
              label: 'Stars',
              iconColor: KineticObsidian.electricCyan,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _StatTile(
              icon: Icons.diamond_outlined,
              value: '${progress.diamonds}',
              label: 'Credits',
              iconColor: KineticObsidian.primaryFixed,
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _StatTile(
              icon: Icons.bolt,
              value: '${progress.hearts}',
              label: 'Energy',
              iconColor: KineticObsidian.secondaryFixedDim,
            )),
          ],
        ),
        const SizedBox(height: 16),
        // Cognitive skills
        _SkillsCard(progress: progress),
        const SizedBox(height: 16),
        // Achievements
        _AchievementsCard(progress: progress),
      ],
    );
  }
}

// ─── XP Hero ──────────────────────────────────────────────────────────────────

class _XpHero extends StatelessWidget {
  final int xp;
  final double levelPct;
  final int level;

  const _XpHero({required this.xp, required this.levelPct, required this.level});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: KineticObsidian.radiusXl,
      padding: const EdgeInsets.all(KineticObsidian.spaceMd),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Purple bloom top-right
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    KineticObsidian.protonPurple.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL XP',
                style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.48,
                  color: KineticObsidian.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              KineticText(
                _formatXp(xp),
                style: TextStyle(fontFamily: KineticObsidian.fontDisplay, fontFamilyFallback: KineticObsidian.fontFallback, 
                  fontSize: 44,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  letterSpacing: 2.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $level · Next',
                    style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.48,
                      color: KineticObsidian.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${levelPct.toStringAsFixed(0)}%',
                    style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.48,
                      color: KineticObsidian.electricCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              KineticProgressBar(percent: levelPct, height: 4),
            ],
          ),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1).replaceAll('.0', '')},${(xp % 1000).toString().padLeft(3, '0')}';
    }
    return '$xp';
  }
}

// ─── Stat tile ────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: KineticObsidian.radiusXl,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: KineticObsidian.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KineticObsidian.radiusLg),
              border: Border.all(color: KineticObsidian.outlineVariant, width: 1),
              boxShadow: const [
                BoxShadow(color: Color(0x80000000), blurRadius: 8),
              ],
            ),
            child: Center(child: Icon(icon, size: 22, color: iconColor)),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontFamily: KineticObsidian.fontDisplay, fontFamilyFallback: KineticObsidian.fontFallback, 
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.0,
              letterSpacing: 0.88,
              color: KineticObsidian.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
              color: KineticObsidian.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cognitive skills card ────────────────────────────────────────────────────

class _SkillsCard extends StatelessWidget {
  final PlayerProgress progress;
  const _SkillsCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final history = progress.adaptiveHistory;
    final patternPct = _pctFromHistory(history, 0);
    final memoryPct = _pctFromHistory(history, 1);
    final logicPct = _pctFromHistory(history, 2);
    final speedPct = _pctFromHistory(history, 3);

    return GlassCard(
      borderRadius: KineticObsidian.radiusXl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  size: 22, color: KineticObsidian.electricCyan),
              const SizedBox(width: 8),
              Text('Cognitive Skills',
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          _SkillBar(name: 'Pattern Recognition', pct: patternPct,
              value: patternPct.toStringAsFixed(0)),
          const SizedBox(height: 14),
          _SkillBar(name: 'Working Memory', pct: memoryPct,
              value: memoryPct.toStringAsFixed(0)),
          const SizedBox(height: 14),
          _SkillBar(name: 'Logical Reasoning', pct: logicPct,
              value: logicPct.toStringAsFixed(0)),
          const SizedBox(height: 14),
          _SkillBar(name: 'Reaction Speed', pct: speedPct,
              value: speedPct.toStringAsFixed(0)),
        ],
      ),
    );
  }

  double _pctFromHistory(List<int> history, int offset) {
    if (history.isEmpty) return 60 + (offset * 8).toDouble();
    final relevant = history.skip(offset).toList();
    if (relevant.isEmpty) return 60 + (offset * 8).toDouble();
    final avg = relevant.reduce((a, b) => a + b) / relevant.length;
    return (avg / 5 * 100).clamp(0, 100).toDouble();
  }
}

class _SkillBar extends StatelessWidget {
  final String name;
  final double pct;
  final String value;

  const _SkillBar({required this.name, required this.pct, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name.toUpperCase(),
              style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                fontSize: 11, fontWeight: FontWeight.w400,
                letterSpacing: 0.66,
                color: KineticObsidian.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                fontSize: 11, fontWeight: FontWeight.w400,
                letterSpacing: 0.44,
                color: KineticObsidian.electricCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        KineticProgressBar(percent: pct, height: 3),
      ],
    );
  }
}

// ─── Achievements card ────────────────────────────────────────────────────────

class _AchievementsCard extends StatelessWidget {
  final PlayerProgress progress;
  const _AchievementsCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.unlockedAchievements;

    final badges = [
      (
        img: 'assets/images/badges/novice_mind.png',
        title: 'Novice Mind',
        sub: 'Complete your first puzzle',
        id: 'novice_mind',
      ),
      (
        img: 'assets/images/badges/daily_spark.png',
        title: 'Daily Spark',
        sub: 'Play 7 days in a row',
        id: 'daily_spark',
      ),
      (
        img: 'assets/images/badges/focus_master.png',
        title: 'Focus Master',
        sub: 'Earn 25 stars',
        id: 'focus_master',
      ),
    ];

    return GlassCard(
      borderRadius: KineticObsidian.radiusXl,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Achievements',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          for (var i = 0; i < badges.length; i++) ...[
            _AchievementRow(
              img: badges[i].img,
              title: badges[i].title,
              sub: badges[i].sub,
              unlocked: unlocked.contains(badges[i].id),
            ),
            if (i < badges.length - 1)
              const Divider(height: 1, color: Color(0x0DFFFFFF)),
          ],
        ],
      ),
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final String img;
  final String title;
  final String sub;
  final bool unlocked;

  const _AchievementRow({
    required this.img,
    required this.title,
    required this.sub,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          ColorFiltered(
            colorFilter: unlocked
                ? const ColorFilter.mode(Colors.transparent, BlendMode.saturation)
                : const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0,      0,      0,      0.35, 0,
                  ]),
            child: Image.asset(img, width: 48, height: 48, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                    fontSize: 13, fontWeight: FontWeight.w500,
                    letterSpacing: 0.78,
                    color: KineticObsidian.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(sub, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x1F00F0FF),
                border: Border.all(color: const Color(0x4D00F0FF), width: 1),
                borderRadius: BorderRadius.circular(KineticObsidian.radiusFull),
              ),
              child: Text(
                'UNLOCKED',
                style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                  fontSize: 10, fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  color: KineticObsidian.electricCyan,
                ),
              ),
            )
          else
            Icon(Icons.lock_outline, size: 18, color: KineticObsidian.outline),
        ],
      ),
    );
  }
}
