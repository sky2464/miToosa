import 'package:flutter/material.dart';

/// Returns [theme] with Material splash effects disabled for widget tests.
///
/// Material 3 [InkSparkle] loads `shaders/ink_sparkle.frag`, which fails in the
/// headless test binding with "Unsupported runtime stages format version".
ThemeData testSafeTheme(ThemeData theme) {
  return theme.copyWith(
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

/// Default [ThemeData] for widget tests that tap Material buttons.
ThemeData get testSafeMaterialTheme => testSafeTheme(ThemeData(useMaterial3: true));
