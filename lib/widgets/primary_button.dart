import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Gradient pill CTA — blue→purple background, inset white shine, press scale.
class PrimaryButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final bool glow;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fullWidth = false,
    this.glow = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: AP.durPress,
        curve: AP.easeOut,
        child: Opacity(
          opacity: disabled ? 0.55 : 1.0,
          child: Container(
            width: widget.fullWidth ? double.infinity : null,
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
                        color: Colors.white.withValues(alpha: 0.25),
                        blurRadius: 0,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Inset shine highlight
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AP.radiusPill),
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
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
    );
  }
}
