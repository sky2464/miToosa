import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../theme/design_tokens.dart';

/// Outlined ghost button — subtle glass fill, pill radius.
class GhostButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;

  const GhostButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fullWidth = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Semantics(
      button: true,
      enabled: !disabled,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: fullWidth ? double.infinity : null,
          constraints: MiToosaAccessibility.minTouchTargetConstraints,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AP.radiusPill),
            border: Border.all(color: AP.glassBorderStrong, width: 1),
          ),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFFD1D5DB),
              ),
              child: IconTheme(
                data: const IconThemeData(color: Color(0xFFD1D5DB), size: 16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
