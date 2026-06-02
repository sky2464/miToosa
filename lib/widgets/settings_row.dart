import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Row used inside settings cards: tinted icon well + title/subtitle + trailing.
class SettingsRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color tint;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.tint = AP.blueLight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: tint.withValues(alpha: 0.19),
                    width: 1,
                  ),
                ),
                child: IconTheme(
                  data: IconThemeData(color: tint, size: 18),
                  child: Center(child: icon),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AP.fg,
                        letterSpacing: -0.14,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: AP.fgMeta,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null)
                IconTheme(
                  data: const IconThemeData(color: AP.fgMuted, size: 18),
                  child: trailing!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hairline divider between settings rows.
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 60),
      color: Colors.white.withValues(alpha: 0.04),
    );
  }
}
