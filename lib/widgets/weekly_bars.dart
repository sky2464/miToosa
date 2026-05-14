import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// 7-day XP bar chart. Today's column gets the bright primary gradient + glow;
/// other days use a soft blue→purple gradient; zero days show a flat track.
class WeeklyBars extends StatelessWidget {
  /// XP earned each day Monday-Sunday (7 values).
  final List<int> dailyXp;

  /// Today's index (0=Mon, 6=Sun). Defaults to 6 (Sunday).
  final int todayIndex;

  /// Day initial labels, 7 entries.
  final List<String> dayLabels;

  const WeeklyBars({
    super.key,
    required this.dailyXp,
    this.todayIndex = 6,
    this.dayLabels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
  });

  @override
  Widget build(BuildContext context) {
    assert(dailyXp.length == 7);
    final maxXp = dailyXp.fold<int>(0, (m, v) => v > m ? v : m).clamp(1, 9999);

    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final v = dailyXp[i];
          final h = (v / maxXp) * 100;
          final today = i == todayIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: i == 0 || i == 6 ? 0 : 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: AP.durHero,
                        curve: AP.easeOut,
                        height: ((h / 100) * 50).clamp(4, 50),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                            bottomLeft: Radius.circular(2),
                            bottomRight: Radius.circular(2),
                          ),
                          gradient: v == 0
                              ? null
                              : today
                                  ? AP.gradPrimary
                                  : LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AP.blueLight.withValues(alpha: 0.7),
                                        AP.purple.withValues(alpha: 0.4),
                                      ],
                                    ),
                          color: v == 0
                              ? Colors.white.withValues(alpha: 0.06)
                              : null,
                          boxShadow: today
                              ? [
                                  BoxShadow(
                                    color: AP.blueLight.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayLabels[i],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: today ? FontWeight.w700 : FontWeight.w500,
                      color: today
                          ? const Color(0xFFBFDBFE)
                          : AP.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
