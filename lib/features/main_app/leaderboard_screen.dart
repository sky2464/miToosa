import 'package:flutter/material.dart';

import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_background.dart';
import '../../widgets/kinetic_text.dart';

// ─── Leaderboard screen — Aetheric Pulse ─────────────────────────────────────

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
    return KineticBackground(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AethericPulseDark.spaceLg,
          AethericPulseDark.spaceMd,
          AethericPulseDark.spaceLg,
          AethericPulseDark.spaceXl + 80,
        ),
        children: [
          // Header
          GlassCard(
            borderRadius: AethericPulseDark.radiusCard,
            padding: const EdgeInsets.all(20),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AethericPulseDark.radiusCard),
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.0,
                        colors: [
                          AethericPulseDark.brandPurple.withValues(alpha: 0.15),
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
                      style: AethericPulseDark.label(
                        color: AethericPulseDark.brandBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    KineticText(
                      'Leaderboard',
                      style: AethericPulseDark.headlineLg(),
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
          // Rank list — each row in its own GlassCard; top-3 get blueGlow
          for (var i = 0; i < _rows.length; i++) ...[
            GlassCard(
              neonGlow: _rows[i].rank <= 3,
              borderRadius: AethericPulseDark.radiusWell,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: _RankRow(data: _rows[i]),
            ),
            if (i < _rows.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
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
          gradient: isActive ? AethericPulseDark.gradPrimary : null,
          color: isActive ? null : AethericPulseDark.glassFill,
          border: isActive
              ? null
              : Border.all(color: AethericPulseDark.glassBorder, width: 1),
          borderRadius: BorderRadius.circular(AethericPulseDark.radiusChip),
          boxShadow: isActive ? AethericPulseDark.blueGlow : null,
        ),
        child: Center(
          child: Text(
            label.toUpperCase(),
            style: AethericPulseDark.label(
              color: isActive ? AethericPulseDark.onSurface : AethericPulseDark.onSurfaceMuted,
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
    final medalGradient = switch (data.rank) {
      1 => AethericPulseDark.gradPrimary,
      2 => const LinearGradient(colors: [Color(0xFFD1BCFF), Color(0xFFE9DDFF)]),
      3 => const LinearGradient(colors: [Color(0xFFFFB1C3), Color(0xFFFFCCD6)]),
      _ => null,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: data.isYou ? 14 : 4,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: data.isYou
            ? AethericPulseDark.brandBlue.withValues(alpha: 0.08)
            : Colors.transparent,
        border: Border.all(
          color: data.isYou
              ? AethericPulseDark.brandBlue.withValues(alpha: 0.30)
              : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AethericPulseDark.radiusWell),
        boxShadow: data.isYou ? AethericPulseDark.blueGlow : null,
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
              color: medalGradient == null ? AethericPulseDark.glassFill : null,
            ),
            child: Center(
              child: Text(
                '${data.rank}',
                style: TextStyle(
                  fontFamily: AethericPulseDark.fontBody,
                  fontFamilyFallback: AethericPulseDark.fontFallback,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  color: medalGradient != null
                      ? AethericPulseDark.surface
                      : AethericPulseDark.onSurfaceMuted,
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
                    ? AethericPulseDark.brandBlue
                    : AethericPulseDark.glassBorder,
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
                      style: AethericPulseDark.bodyMd(
                        color: AethericPulseDark.onSurface,
                      ),
                    ),
                    if (data.isYou) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· YOU',
                        style: AethericPulseDark.label(
                          color: AethericPulseDark.brandBlue,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatScore(data.score)} XP',
                  style: AethericPulseDark.label(
                    color: AethericPulseDark.brandBlue,
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
                ? AethericPulseDark.brandBlue
                : AethericPulseDark.onSurfaceMuted,
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
