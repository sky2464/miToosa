import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Protocol-driven haptics service with enable/disable toggle.
///
/// Uses Flutter's built-in [HapticFeedback] — no extra dependency.
/// No-op on web and when [enabled] is false.
class HapticsService {
  static final HapticsService _instance = HapticsService._internal();
  factory HapticsService() => _instance;
  HapticsService._internal();

  bool enabled = true;

  bool get _shouldFire => enabled && !kIsWeb;

  /// Light tap — e.g. button press, tile selection.
  Future<void> lightImpact() async {
    if (!_shouldFire) return;
    await HapticFeedback.lightImpact();
  }

  /// Medium impact — e.g. correct answer, level complete.
  Future<void> mediumImpact() async {
    if (!_shouldFire) return;
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact — e.g. wrong answer, heart lost.
  Future<void> heavyImpact() async {
    if (!_shouldFire) return;
    await HapticFeedback.heavyImpact();
  }

  /// Selection tick — e.g. scrolling through options.
  Future<void> selectionClick() async {
    if (!_shouldFire) return;
    await HapticFeedback.selectionClick();
  }

  /// Notification-style vibration — e.g. achievement unlocked.
  Future<void> vibrate() async {
    if (!_shouldFire) return;
    await HapticFeedback.vibrate();
  }
}
