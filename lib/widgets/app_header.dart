import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../theme/design_tokens.dart';

/// Sticky header showing avatar in gradient ring, gradient "miToosa" brand
/// mark, and a free-games pill.
class AppHeader extends StatelessWidget {
  final int freeGamesAvailable;
  final String avatarAsset;
  final String roleLabel;
  final VoidCallback? onProfileTap;
  final VoidCallback? onFreeGamesTap;

  const AppHeader({
    super.key,
    required this.freeGamesAvailable,
    this.avatarAsset = 'assets/images/avatars/avatar_4.png',
    this.roleLabel = 'Pilot · Lv 1',
    this.onProfileTap,
    this.onFreeGamesTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = APTheme.of(context);
    final headerGradient = theme.isDark
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xD90A0D17),
              Color(0x8C0A0D17),
              Colors.transparent,
            ],
            stops: [0.0, 0.7, 1.0],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AethericPulseLight.lightSurface.withValues(alpha: 0.92),
              AethericPulseLight.lightSurface.withValues(alpha: 0.55),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          decoration: BoxDecoration(gradient: headerGradient),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                button: onProfileTap != null,
                label: 'Open profile menu',
                child: GestureDetector(
                  onTap: onProfileTap,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        padding: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AP.gradPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: AP.blueLight.withValues(alpha: 0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Container(
                            color: theme.isDark
                                ? AP.surface
                                : AethericPulseLight.lightSurface,
                            child: Image.asset(
                              avatarAsset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.person,
                                color: theme.fgMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (rect) =>
                                AP.gradPrimary.createShader(rect),
                            child: const Text(
                              'miToosa',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            roleLabel.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: theme.fgMuted,
                              letterSpacing: 1.62,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Semantics(
                button: onFreeGamesTap != null,
                label: '$freeGamesAvailable free games remaining',
                child: GestureDetector(
                  onTap: onFreeGamesTap,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                    decoration: BoxDecoration(
                      color: theme.isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(AP.radiusPill),
                      border: Border.all(
                        color: theme.brandBlue.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sports_esports_outlined,
                          size: 16,
                          color: theme.brandBlue,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatNumber(freeGamesAvailable),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.fg,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                            letterSpacing: -0.13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'free games',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: theme.fgMeta,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    final s = n.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

