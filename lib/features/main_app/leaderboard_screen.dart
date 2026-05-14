import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/player_progress_provider.dart';
import '../../theme/design_tokens.dart';

/// Leaderboard screen — podium (top 3) + segmented control + ranked rows.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _scope = 'global';

  static const _demo = [
    _Person(rank: 1, name: 'Mira K.', xp: 24820, avatar: 1, frame: 'gold'),
    _Person(rank: 2, name: 'Diego R.', xp: 22110, avatar: 2, frame: 'silver'),
    _Person(rank: 3, name: 'Aiko T.', xp: 19500, avatar: 3, frame: 'bronze'),
    _Person(rank: 5, name: 'Priya S.', xp: 11230, avatar: 5),
    _Person(rank: 6, name: 'Jordan L.', xp: 10870, avatar: 6),
    _Person(rank: 7, name: 'Kenji M.', xp: 9420, avatar: 7),
    _Person(rank: 8, name: 'Sasha B.', xp: 8120, avatar: 8),
  ];

  @override
  Widget build(BuildContext context) {
    final playerXP = ref.watch(playerProgressProvider).maybeWhen(
          data: (p) => p.totalXP,
          orElse: () => 0,
        );
    final you = _Person(rank: 4, name: 'Pilot_042', xp: playerXP, avatar: 4, isYou: true);
    final all = [..._demo.where((p) => p.rank < 4), you, ..._demo.where((p) => p.rank >= 4)];
    final podium = all.where((p) => p.rank <= 3).toList()..sort((a, b) => a.rank - b.rank);
    final xpToTop3 = (_demo.firstWhere((p) => p.rank == 3).xp - playerXP).clamp(0, 999999);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
      children: [
        // Header
        Text('WEEKLY · RESETS SUN 23:59',
            style: AP.eyebrow(color: AP.purple)),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (r) => const LinearGradient(
            colors: [Color(0xFF60A5FA), Color(0xFFC084FC), Color(0xFFEC4899)],
          ).createShader(r),
          child: Text(
            'Leaderboard',
            style: AP.display(color: Colors.white).copyWith(fontSize: 32, height: 1.0),
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AP.fgMeta,
            ),
            children: [
              const TextSpan(text: 'You’re ranked '),
              const TextSpan(
                text: '#4',
                style: TextStyle(color: AP.fg, fontWeight: FontWeight.w700),
              ),
              TextSpan(text: ' · $xpToTop3 XP to top 3'),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Segmented control
        _SegmentedControl(
          value: _scope,
          options: const ['global', 'friends', 'local'],
          onChanged: (v) => setState(() => _scope = v),
        ),
        const SizedBox(height: 14),

        // Podium
        SizedBox(height: 170, child: _Podium(people: podium)),
        const SizedBox(height: 14),

        // You row pinned
        _LeaderRow(person: you),
        const SizedBox(height: 8),

        // Rest
        for (final p in all.where((p) => !p.isYou && p.rank > 3)) ...[
          _LeaderRow(person: p),
          const SizedBox(height: 8),
        ],

        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Leaderboard preview · live in v1.3',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: AP.fgMuted,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _Person {
  final int rank;
  final String name;
  final int xp;
  final int avatar;
  final String? frame;
  final bool isYou;
  const _Person({
    required this.rank,
    required this.name,
    required this.xp,
    required this.avatar,
    this.frame,
    this.isYou = false,
  });
}

class _SegmentedControl extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SegmentedControl({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AP.radiusPill),
        border: Border.all(color: AP.glassBorder, width: 1),
      ),
      child: Row(
        children: options.map((o) {
          final active = value == o;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(o),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: active ? AP.gradPrimary : null,
                  borderRadius: BorderRadius.circular(AP.radiusPill),
                  boxShadow: active
                      ? [BoxShadow(color: AP.blue.withValues(alpha: 0.4), blurRadius: 14)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    o.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.72,
                      color: active ? Colors.white : AP.fgMeta,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Podium extends StatelessWidget {
  final List<_Person> people; // [1st, 2nd, 3rd] sorted by rank
  const _Podium({required this.people});

  @override
  Widget build(BuildContext context) {
    if (people.length < 3) return const SizedBox.shrink();
    // Display order: 2nd · 1st · 3rd
    final order = [people[1], people[0], people[2]];
    final heights = [70.0, 100.0, 56.0];
    final fills = [
      Colors.white.withValues(alpha: 0.13),
      AP.amber.withValues(alpha: 0.28),
      AP.orange.withValues(alpha: 0.25),
    ];
    final borders = [
      Colors.white.withValues(alpha: 0.5),
      AP.amber.withValues(alpha: 0.7),
      AP.orange.withValues(alpha: 0.55),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(3, (i) {
        final p = order[i];
        final isFirst = p.rank == 1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isFirst)
                  const Icon(Icons.workspace_premium,
                      color: AP.amber, size: 22),
                if (isFirst) const SizedBox(height: 2),
                Container(
                  width: isFirst ? 64 : 52,
                  height: isFirst ? 64 : 52,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AP.surface,
                    border: Border.all(color: borders[i], width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AP.avatar(p.avatar),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, color: AP.fgMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AP.fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${p.xp} XP',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: AP.fgMeta,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  height: heights[i],
                  decoration: BoxDecoration(
                    color: fills[i],
                    border: Border.all(
                      color: borders[i].withValues(alpha: 0.35),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(color: fills[i], blurRadius: 18),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${p.rank}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.48,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  final _Person person;
  const _LeaderRow({required this.person});

  @override
  Widget build(BuildContext context) {
    final isYou = person.isYou;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: isYou
            ? AP.blueLight.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isYou
              ? AP.blueLight.withValues(alpha: 0.45)
              : AP.glassBorder,
          width: 1,
        ),
        boxShadow: isYou
            ? [BoxShadow(color: AP.blueLight.withValues(alpha: 0.25), blurRadius: 18)]
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${person.rank}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isYou ? const Color(0xFFBFDBFE) : AP.fgMeta,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AP.surface,
              border: Border.all(
                color: isYou
                    ? AP.blueLight.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                AP.avatar(person.avatar),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.person, color: AP.fgMuted, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      person.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AP.fg,
                      ),
                    ),
                    if (isYou) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AP.blueLight.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFBFDBFE),
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${person.xp} XP',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AP.fgMeta,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
