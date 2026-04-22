import 'package:flutter/material.dart';

import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_text.dart';

// ─── Leaderboard screen — Kinetic Obsidian ────────────────────────────────────

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _filterIndex = 0;

  static const _filters = ['Global', 'Friends', 'Local'];

  static const _rows = [
    _RankData(rank: 1, name: 'Mira K.', score: 24820, avatarIndex: 1),
    _RankData(rank: 2, name: 'Diego R.', score: 22110, avatarIndex: 2),
    _RankData(rank: 3, name: 'Aiko T.', score: 19500, avatarIndex: 3),
    _RankData(rank: 4, name: 'Pilot_042', score: 12480, avatarIndex: 4, isYou: true),
    _RankData(rank: 5, name: 'Priya S.', score: 11230, avatarIndex: 5),
    _RankData(rank: 6, name: 'Jordan L.', score: 10870, avatarIndex: 6),
    _RankData(rank: 7, name: 'Sam O.', score: 9420, avatarIndex: 7),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceMd,
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceLg + 80,
      ),
      children: [
        // Header
        GlassCard(
          borderRadius: KineticObsidian.radiusXl,
          padding: const EdgeInsets.all(20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(KineticObsidian.radiusXl),
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.0,
                      colors: [
                        KineticObsidian.protonPurple.withValues(alpha: 0.15),
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
                    'WEEKLY · GLOBAL',
                    style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                      fontSize: 11, fontWeight: FontWeight.w400,
                      letterSpacing: 0.88,
                      color: KineticObsidian.electricCyan,
                    ),
                  ),
                  const SizedBox(height: 4),
                  KineticText(
                    'Leaderboard',
                    style: TextStyle(fontFamily: KineticObsidian.fontDisplay, fontFamilyFallback: KineticObsidian.fontFallback, 
                      fontSize: 28, fontWeight: FontWeight.w500,
                      letterSpacing: 1.12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Filter tabs
        Row(
          children: [
            for (var i = 0; i < _filters.length; i++) ...[
              Expanded(child: _FilterTab(
                label: _filters[i],
                isActive: _filterIndex == i,
                onTap: () => setState(() => _filterIndex = i),
              )),
              if (i < _filters.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
        const SizedBox(height: 16),
        // Rank list
        GlassCard(
          borderRadius: KineticObsidian.radiusXl,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              for (var i = 0; i < _rows.length; i++) ...[
                _RankRow(data: _rows[i]),
                if (i < _rows.length - 1)
                  const Divider(height: 1, color: Color(0x0AFFFFFF)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Filter tab ────────────────────────────────────────────────────────────────

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? KineticObsidian.kineticGradient : null,
          color: isActive ? null : const Color(0x801D2026),
          border: isActive
              ? null
              : Border.all(color: KineticObsidian.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(KineticObsidian.radiusLg),
          boxShadow: isActive ? KineticObsidian.shadowNeonSoft : null,
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
              fontSize: 11, fontWeight: FontWeight.w600,
              letterSpacing: 0.88,
              color: isActive
                  ? const Color(0xFF00363A)
                  : KineticObsidian.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Rank row ──────────────────────────────────────────────────────────────────

class _RankData {
  final int rank;
  final String name;
  final int score;
  final int avatarIndex;
  final bool isYou;

  const _RankData({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarIndex,
    this.isYou = false,
  });
}

class _RankRow extends StatelessWidget {
  final _RankData data;
  const _RankRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final medalGradient = data.rank == 1
        ? const LinearGradient(colors: [Color(0xFF00F0FF), Color(0xFF7DF4FF)])
        : data.rank == 2
            ? const LinearGradient(colors: [Color(0xFFD1BCFF), Color(0xFFE9DDFF)])
            : data.rank == 3
                ? const LinearGradient(colors: [Color(0xFFFFB1C3), Color(0xFFFFCCD6)])
                : null;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: data.isYou ? 14 : 4,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: data.isYou
            ? KineticObsidian.electricCyan.withValues(alpha: 0.08)
            : Colors.transparent,
        border: Border.all(
          color: data.isYou
              ? KineticObsidian.electricCyan.withValues(alpha: 0.30)
              : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(KineticObsidian.radiusLg),
        boxShadow: data.isYou ? KineticObsidian.shadowNeonSoft : null,
      ),
      child: Row(
        children: [
          // Rank pill
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: medalGradient,
              color: medalGradient == null
                  ? KineticObsidian.surfaceContainerHigh
                  : null,
            ),
            child: Center(
              child: Text(
                '${data.rank}',
                style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                  fontSize: 13, fontWeight: FontWeight.w700,
                  letterSpacing: 0.78,
                  color: medalGradient != null
                      ? const Color(0xFF00363A)
                      : KineticObsidian.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.isYou
                    ? KineticObsidian.electricCyan
                    : KineticObsidian.outlineVariant,
                width: 1,
              ),
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/avatars/avatar_${data.avatarIndex}.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + XP
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.name,
                      style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                        fontSize: 13, fontWeight: FontWeight.w500,
                        letterSpacing: 0.52,
                        color: KineticObsidian.onSurface,
                      ),
                    ),
                    if (data.isYou) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· YOU',
                        style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                          fontSize: 12, fontWeight: FontWeight.w500,
                          letterSpacing: 0.48,
                          color: KineticObsidian.electricCyan,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatScore(data.score)} XP',
                  style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                    fontSize: 11, fontWeight: FontWeight.w300,
                    letterSpacing: 0.44,
                    color: KineticObsidian.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Trophy icon
          Icon(
            Icons.military_tech,
            size: 20,
            color: data.rank <= 3
                ? KineticObsidian.electricCyan
                : KineticObsidian.outline,
          ),
        ],
      ),
    );
  }

  String _formatScore(int score) {
    if (score >= 1000) {
      final thousands = score ~/ 1000;
      final remainder = score % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return '$score';
  }
}
