import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class AchievementData {
  final String id;
  final String name;
  final String subtitle;
  final bool unlocked;
  final int progress;
  final int total;

  const AchievementData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.unlocked,
    this.progress = 0,
    this.total = 1,
  });

  String get badgePath => AP.badge(id);
}

/// Achievement card — full-color badge if unlocked, greyscale + lock overlay
/// + progress bar if locked.
class AchievementCard extends StatelessWidget {
  final AchievementData a;

  const AchievementCard({super.key, required this.a});

  @override
  Widget build(BuildContext context) {
    final pct = a.unlocked
        ? 1.0
        : (a.total > 0 ? (a.progress / a.total).clamp(0.0, 1.0) : 0.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: a.unlocked
            ? AP.blueLight.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: a.unlocked
              ? AP.blueLight.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
        boxShadow: a.unlocked
            ? [
                BoxShadow(
                  color: AP.blueLight.withValues(alpha: 0.18),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                Center(
                  child: ColorFiltered(
                    colorFilter: a.unlocked
                        ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply)
                        : const ColorFilter.matrix(<double>[
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 0.5, 0,
                          ]),
                    child: Image.asset(
                      a.badgePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.emoji_events, color: AP.fgMuted, size: 40),
                    ),
                  ),
                ),
                if (!a.unlocked)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AP.surface.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(Icons.lock, color: AP.fgMuted, size: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            a.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: a.unlocked ? AP.fg : AP.fgSecondary,
              letterSpacing: -0.11,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 24,
            child: Text(
              a.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9.5,
                color: AP.fgMuted,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          if (a.unlocked)
            const Text(
              'UNLOCKED',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF93C5FD),
                letterSpacing: 1.08,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AP.gradPrimary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${a.progress}/${a.total}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AP.fgMeta,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
