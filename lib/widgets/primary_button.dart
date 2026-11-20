import 'package:flutter/material.dart';

import '../theme/design_system.dart';
import '../theme/design_tokens.dart';

/// Gradient pill CTA — blue→purple background, inset white shine, press scale.
class PrimaryButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool glow;
  final EdgeInsetsGeometry padding;
  final String? semanticsLabel;

  const PrimaryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fullWidth = false,
    this.glow = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
    this.semanticsLabel,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final pressDuration = MiToosaAccessibility.motionDuration(
      context,
      AP.durPress,
    );
    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.semanticsLabel,
      excludeSemantics: widget.semanticsLabel != null,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed && !disabled ? 0.97 : 1.0,
          duration: pressDuration,
          curve: AP.easeOut,
          child: Opacity(
            opacity: disabled ? 0.55 : 1.0,
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              constraints: MiToosaAccessibility.minTouchTargetConstraints,
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: AP.gradPrimary,
                borderRadius: BorderRadius.circular(AP.radiusPill),
                boxShadow: widget.glow && !disabled
                    ? [
                        BoxShadow(
                          color: AP.blue.withValues(alpha: 0.45),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AP.radiusPill),
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: const Alignment(0, 0.35),
                              colors: [
                                Colors.white.withValues(alpha: 0.10),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 0.28,
                    ),
                    child: IconTheme(
                      data: const IconThemeData(color: Colors.white, size: 18),
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
