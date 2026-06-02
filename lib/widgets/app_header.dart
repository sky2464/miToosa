import 'dart:ui';
import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Sticky header showing avatar in gradient ring, gradient "miToosa" brand
/// mark, and a credits pill with a diamond glyph.
class AppHeader extends StatelessWidget {
  final int credits;
  final String avatarAsset;
  final String roleLabel;
  final VoidCallback? onAvatarTap;

  const AppHeader({
    super.key,
    required this.credits,
    this.avatarAsset = 'assets/images/avatars/avatar_4.png',
    this.roleLabel = 'Pilot · Lv 1',
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xD90A0D17),
                Color(0x8C0A0D17),
                Colors.transparent,
              ],
              stops: [0.0, 0.7, 1.0],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar + brand
              Row(
                children: [
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
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
                          color: AP.surface,
                          child: Image.asset(
                            avatarAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.person,
                              color: AP.fgMuted,
                              size: 20,
                            ),
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
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AP.fgMuted,
                          letterSpacing: 1.62,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Credits pill
              Container(
                padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AP.radiusPill),
                  border: Border.all(
                    color: AP.blueLight.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AP.blue.withValues(alpha: 0.15),
                      blurRadius: 12,
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _DiamondGlyph(size: 14),
                    const SizedBox(width: 6),
                    Text(
                      _formatNumber(credits),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AP.fg,
                        fontFeatures: [FontFeature.tabularFigures()],
                        letterSpacing: -0.13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'CR',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AP.fgMeta,
                        letterSpacing: 1.08,
                      ),
                    ),
                  ],
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

class _DiamondGlyph extends StatelessWidget {
  final double size;
  const _DiamondGlyph({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DiamondPainter()),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.125)
      ..lineTo(size.width * 0.833, size.height * 0.417)
      ..lineTo(size.width * 0.5, size.height * 0.875)
      ..lineTo(size.width * 0.167, size.height * 0.417)
      ..close();
    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [AP.blueLight, AP.purple],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fill);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = Colors.white.withValues(alpha: 0.95);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => false;
}
