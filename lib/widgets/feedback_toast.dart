import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Short, celebratory per-puzzle reward overlay ("IQ +1!", "+N XP") shown
/// after a correct answer. Animates in with a spring easeOutBack scale+fade,
/// holds briefly, then fades out. Additive to SessionCompleteOverlay — this
/// is for instant reward, not end-of-session summary.
class FeedbackToast extends StatefulWidget {
  final String headline;
  final String amount;
  final IconData icon;
  final VoidCallback? onDismissed;

  const FeedbackToast({
    super.key,
    required this.headline,
    required this.amount,
    this.icon = Icons.bolt_rounded,
    this.onDismissed,
  });

  /// Show the toast as an [OverlayEntry] anchored near the top of the screen.
  /// Caller is responsible for a11y announcement; screen readers hear the
  /// Semantics label embedded in the widget.
  static OverlayEntry show(
    BuildContext context, {
    required String headline,
    required String amount,
    IconData icon = Icons.bolt_rounded,
    Duration holdFor = const Duration(milliseconds: 900),
  }) {
    final entry = OverlayEntry(
      builder: (_) => _ToastPositioner(
        child: FeedbackToast(headline: headline, amount: amount, icon: icon),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    Timer(holdFor + AethericPulseDark.durCelebrate * 2, () {
      try {
        entry.remove();
      } catch (_) {}
    });
    return entry;
  }

  @override
  State<FeedbackToast> createState() => _FeedbackToastState();
}

class _FeedbackToastState extends State<FeedbackToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: AethericPulseDark.springSoft),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: AethericPulseDark.easeOut));
    _ctrl.forward();
    // Auto-reverse after a short hold so it doesn't linger.
    Timer(const Duration(milliseconds: 900), () {
      if (mounted) {
        _ctrl.reverse().whenComplete(() => widget.onDismissed?.call());
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark
        ? AethericPulseDark.glassBorder
        : AethericPulseLight.glassBorderDimLight;
    return Semantics(
      liveRegion: true,
      label: '${widget.headline} ${widget.amount}',
      container: true,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: isDark
                    ? AethericPulseDark.gradPrimary
                    : AethericPulseLight.gradientSoft,
                borderRadius: BorderRadius.circular(
                  AethericPulseDark.radiusHero,
                ),
                border: Border.all(color: border, width: 1),
                boxShadow: AethericPulseLight.shadowSoftBlue,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 22, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    widget.headline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: Colors.white,
                      shadows: const [
                        Shadow(blurRadius: 8, color: Color(0x66000000)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.amount,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastPositioner extends StatelessWidget {
  final Widget child;
  const _ToastPositioner({required this.child});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: topInset + 72,
      left: 0,
      right: 0,
      child: Center(child: child),
    );
  }
}
