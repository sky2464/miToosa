import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_background.dart';
import '../../widgets/kinetic_chip.dart';
import '../../widgets/kinetic_progress_bar.dart';
import '../../widgets/kinetic_text.dart' hide KineticProgressBar;

// ─── Progress screen — Aetheric Pulse ────────────────────────────────────────

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    return KineticBackground(
      child: progressAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AethericPulseDark.brandBlue)),
        error: (e, _) => Center(
            child: Text('Error', style: Theme.of(context).textTheme.bodyMedium)),
        data: (progress) => _ProgressBody(progress: progress),
      ),
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
    final totalStars = progress.levelStars.values.fold(0, (a, b) => a + b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceXl + 80,
      ),
      children: [
        // XP Hero
        _XpHero(xp: xp, levelPct: levelPct, level: level),
        const SizedBox(height: 16),
        // Stats chips row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            KineticChip(
              label: '${progress.streakCount} day streak',
              leading: const Icon(Icons.local_fire_department, size: 12,
                  color: AethericPulseDark.accentOrange),
            ),
            KineticChip(
              label: '$xp XP',
              color: AethericPulseDark.brandBlue,
            ),
            KineticChip(
              label: '$totalStars stars',
              leading: const Icon(Icons.military_tech, size: 12,
                  color: AethericPulseDark.accentCyan),
            ),
            KineticChip(
              label: '${progress.hearts} energy',
              leading: const Icon(Icons.bolt, size: 12,
                  color: AethericPulseDark.brandPurple),
              color: AethericPulseDark.brandPurple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Cognitive skills
        _SkillsCard(progress: progress),
        const SizedBox(height: 16),
        // Achievements / badges
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
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(AethericPulseDark.spaceLg),
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
                    AethericPulseDark.brandPurple.withValues(alpha: 0.25),
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
                style: AethericPulseDark.label(color: AethericPulseDark.onSurfaceMuted),
              ),
              const SizedBox(height: 6),
              KineticText(
                _formatXp(xp),
                style: AethericPulseDark.display(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $level · Next',
                    style: AethericPulseDark.headlineMd(),
                  ),
                  Text(
                    '${levelPct.toStringAsFixed(0)}%',
                    style: AethericPulseDark.label(color: AethericPulseDark.brandBlue),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              KineticProgressBar(value: levelPct / 100.0, height: 4),
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
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(AethericPulseDark.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  size: 22, color: AethericPulseDark.accentCyan),
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
              style: AethericPulseDark.label(color: AethericPulseDark.onSurfaceMuted),
            ),
            Text(
              value,
              style: AethericPulseDark.label(color: AethericPulseDark.brandBlue),
            ),
          ],
        ),
        const SizedBox(height: 6),
        KineticProgressBar(value: pct / 100.0, height: 3),
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
      (
        img: 'assets/images/badges/memory_marvel.png',
        title: 'Memory Marvel',
        sub: 'Perfect score on a memory level',
        id: 'memory_marvel',
      ),
      (
        img: 'assets/images/badges/logic_legend.png',
        title: 'Logic Legend',
        sub: 'Complete all logic challenges',
        id: 'logic_legend',
      ),
      (
        img: 'assets/images/badges/ultimate_brain.png',
        title: 'Ultimate Brain',
        sub: 'Reach the top of every track',
        id: 'ultimate_brain',
      ),
    ];

    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(AethericPulseDark.spaceLg),
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
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
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
                : const ColorFilter.mode(Colors.grey, BlendMode.saturation),
            child: Image.asset(img, width: 48, height: 48, fit: BoxFit.contain),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AethericPulseDark.label(color: AethericPulseDark.onSurface),
                ),
                const SizedBox(height: 2),
                Text(sub,
                    style: AethericPulseDark.label(
                        color: AethericPulseDark.onSurfaceMuted)),
              ],
            ),
          ),
          if (unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AethericPulseDark.brandBlue.withValues(alpha: 0.12),
                border: Border.all(
                    color: AethericPulseDark.brandBlue.withValues(alpha: 0.30),
                    width: 1),
                borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
              ),
              child: Text(
                'UNLOCKED',
                style: AethericPulseDark.label(color: AethericPulseDark.brandBlue),
              ),
            )
          else
            const Icon(Icons.lock_outline, size: 18,
                color: AethericPulseDark.onSurfaceMuted),
        ],
      ),
    );
  }
}
