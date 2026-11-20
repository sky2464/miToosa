import 'package:flutter/material.dart';

import 'aetheric_pulse_dark.dart';

/// Shared accessibility constants and MediaQuery helpers for launch surfaces.
///
/// UI layers consume these helpers; engines must not import this file.
abstract final class MiToosaAccessibility {
  /// WCAG / Apple HIG minimum touch target (logical pixels).
  static const double minTouchTarget = AethericPulseDark.minTapTarget;

  /// Largest Dynamic Type scale covered by automated layout tests.
  static const double highTextScaleFactor = 2.0;

  /// iPhone portrait widths exercised in BL-36 layout smoke tests.
  static const List<double> portraitSmokeWidths = [320, 375, 430];

  /// True when the platform asks for reduced or simplified motion.
  static bool prefersReducedMotion(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.disableAnimations || mq.accessibleNavigation;
  }

  /// Returns [Duration.zero] when reduced motion is requested.
  static Duration motionDuration(BuildContext context, Duration normal) {
    return prefersReducedMotion(context) ? Duration.zero : normal;
  }

  /// Minimum [BoxConstraints] for an interactive control.
  static BoxConstraints get minTouchTargetConstraints =>
      const BoxConstraints(minWidth: minTouchTarget, minHeight: minTouchTarget);
}
