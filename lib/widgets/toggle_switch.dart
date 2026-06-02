import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Custom toggle with gradient active fill and spring thumb animation.
class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Center(
          child: AnimatedContainer(
            duration: AP.durHover,
            curve: AP.easeOut,
            width: 42,
            height: 24,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: value ? AP.gradPrimary : null,
              color: value ? null : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: AP.blue.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
