import 'package:flutter/material.dart';

import 'aetheric_pulse_dark.dart';
import 'aetheric_pulse_light.dart';

/// Kinetic Obsidian — miToosa dark theme (the legacy default).
/// Deep obsidian surfaces, Electric Cyan (#00F0FF) + Proton Purple (#7000FF),
/// glassmorphism cards, Orbitron display + Exo 2 body typography.
///
/// Aetheric Pulse (soft blue + pink pastel) tokens live in
/// `aetheric_pulse_light.dart` / `aetheric_pulse_dark.dart` — they power the
/// active theme and targeted moments without replacing the Kinetic Obsidian
/// brand identity for screens that still depend on it.
class KineticObsidian {
  // ── Surfaces (base → elevated) ─────────────────────────────────────────
  static const Color surface = Color(0xFF10131A);
  static const Color surfaceContainerLowest = Color(0xFF0B0E14);
  static const Color surfaceContainerLow = Color(0xFF191C22);
  static const Color surfaceContainer = Color(0xFF1D2026);
  static const Color surfaceContainerHigh = Color(0xFF272A31);
  static const Color surfaceContainerHighest = Color(0xFF32353C);
  static const Color surfaceBright = Color(0xFF363940);

  // ── Foreground ─────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFE1E2EB);
  static const Color onSurfaceVariant = Color(0xFFB9CACB);
  static const Color outline = Color(0xFF849495);
  static const Color outlineVariant = Color(0xFF3B494B);

  // ── Brand accents ──────────────────────────────────────────────────────
  static const Color electricCyan = Color(0xFF00F0FF); // primary action
  static const Color protonPurple = Color(0xFF7000FF); // secondary
  static const Color primarySoft = Color(
    0xFFDBFCFF,
  ); // cyan-tinted on-dark text
  static const Color secondarySoft = Color(0xFFD1BCFF); // lilac
  static const Color primaryFixed = Color(0xFF7DF4FF);
  static const Color primaryFixedDim = Color(0xFF00DBE9);
  static const Color secondaryFixed = Color(0xFFE9DDFF);
  static const Color secondaryFixedDim = Color(0xFFD1BCFF);

  // ── Error / semantic ───────────────────────────────────────────────────
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorContainer = Color(0xFF93000A);

  // ── Kinetic gradient (diagonal Proton→Cyan) ────────────────────────────
  static const LinearGradient kineticGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [protonPurple, electricCyan],
  );

  static const LinearGradient kineticGradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xD97000FF), Color(0xD900F0FF)],
  );

  static const LinearGradient plasmaGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), protonPurple],
  );

  // ── Glass card recipe ─────────────────────────────────────────────────
  static Color get glassFill => surfaceContainer.withValues(alpha: 0.50);
  static const Color glassBorderBright = Color(
    0x1AFFFFFF,
  ); // top/left 0.10 alpha
  static const Color glassBorderDim = Color(
    0x08FFFFFF,
  ); // right/bottom 0.03 alpha

  // ── Neon shadows ──────────────────────────────────────────────────────
  static const List<BoxShadow> shadowNeonSoft = [
    BoxShadow(color: Color(0x2600F0FF), blurRadius: 20),
  ];
  static const List<BoxShadow> shadowNeonMed = [
    BoxShadow(color: Color(0x4000F0FF), blurRadius: 30),
  ];
  static const List<BoxShadow> shadowNeonHot = [
    BoxShadow(color: Color(0x8000F0FF), blurRadius: 40),
  ];
  static const List<BoxShadow> shadowPurple = [
    BoxShadow(color: Color(0x597000FF), blurRadius: 30),
  ];
  static const List<BoxShadow> shadowAmbient = [
    BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 4)),
  ];

  // ── Corner radii ───────────────────────────────────────────────────────
  static const double radiusSm = 2.0;
  static const double radius = 4.0;
  static const double radiusMd = 6.0;
  static const double radiusLg = 8.0;
  static const double radiusXl = 12.0;
  static const double radiusFull = 9999.0;
  // Aetheric Pulse — iOS 2026 pillow radii for hero surfaces.
  static const double radiusPillow = 25.0;
  static const double radiusPillowLg = 32.0;
  static const double radiusHero = 40.0;

  // ── Spacing (8 px base) ───────────────────────────────────────────────
  static const double spaceXs = 4.0;
  static const double spaceBase = 8.0;
  static const double spaceSm = 12.0;
  static const double spaceMd = 24.0;
  static const double spaceLg = 48.0;
  static const double spaceXl = 80.0;
  static const double spaceGutter = 24.0;
  static const double spaceMargin = 32.0;

  // Keep old aliases used by existing screens so they compile.
  static const double spacingXs = spaceXs;
  static const double spacingSm = spaceBase;
  static const double spacingMd = spaceSm;
  static const double spacingLg = spaceMd;
  static const double spacingXl = spaceMargin;
  static const double spacingXxl = spaceLg;

  // ── Motion ────────────────────────────────────────────────────────────
  // ADHD-flow window: 150–400 ms. Keep short spring curves for perceived
  // responsiveness; avoid >500 ms waits except on explicit celebratory beats.
  static const Duration durFast = Duration(milliseconds: 150);
  static const Duration durMed = Duration(milliseconds: 250);
  static const Duration durSlow = Duration(milliseconds: 400);

  // Old animation aliases
  static const Duration animFast = durFast;
  static const Duration animNormal = durMed;
  static const Duration animSlow = durSlow;
  static const Curve springBouncy = Curves.elasticOut;
  static const Curve springSnappy = Curves.easeOutBack;
  static const Curve springSmooth = Curves.easeOutCubic;

  // ── Font families (bundled; no runtime CDN fetch) ──────────────────────
  static const String fontDisplay = 'Orbitron';
  static const String fontBody = 'Exo 2';

  // ── Fallback font families ─────────────────────────────────────────────
  static const List<String> fontFallback = [
    'Noto Sans',
    'Noto Sans Symbols',
    'Noto Color Emoji',
  ];

  // ── Typography ─────────────────────────────────────────────────────────
  static TextTheme buildTextTheme({
    Color? onSurfaceColor,
    Color? onSurfaceVariantColor,
    Color? primarySoftColor,
  }) {
    final onSurf = onSurfaceColor ?? onSurface;
    final onSurfVar = onSurfaceVariantColor ?? onSurfaceVariant;
    final primarySoft = primarySoftColor ?? KineticObsidian.primarySoft;
    TextStyle display(
      double size, {
      double letter = 2.0,
      FontWeight weight = FontWeight.w600,
      double height = 1.1,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: fontDisplay,
        fontFamilyFallback: fontFallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letter,
        color: color ?? primarySoft,
      );
    }

    TextStyle body(
      double size, {
      double letter = 0.3,
      FontWeight weight = FontWeight.w300,
      double height = 1.5,
      Color? color,
    }) {
      return TextStyle(
        fontFamily: fontBody,
        fontFamilyFallback: fontFallback,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letter,
        color: color ?? onSurfVar,
      );
    }

    return TextTheme(
      displayLarge: display(48, letter: 2.4),
      displayMedium: display(40, letter: 2.0),
      headlineLarge: display(
        32,
        letter: 1.28,
        weight: FontWeight.w500,
        height: 1.2,
        color: onSurf,
      ),
      headlineMedium: display(
        24,
        letter: 0.72,
        weight: FontWeight.w500,
        height: 1.3,
        color: onSurf,
      ),
      headlineSmall: display(
        20,
        letter: 0.6,
        weight: FontWeight.w500,
        height: 1.3,
        color: onSurf,
      ),
      titleLarge: body(
        18,
        letter: 0.36,
        weight: FontWeight.w500,
        height: 1.4,
        color: onSurf,
      ),
      titleMedium: body(
        16,
        letter: 0.32,
        weight: FontWeight.w500,
        height: 1.4,
        color: onSurf,
      ),
      titleSmall: body(
        14,
        letter: 0.84,
        weight: FontWeight.w500,
        height: 1.2,
        color: onSurf,
      ),
      bodyLarge: body(18, letter: 0.36, height: 1.6),
      bodyMedium: body(16, letter: 0.32),
      bodySmall: body(13, letter: 0.26),
      labelLarge: body(
        14,
        letter: 0.84,
        weight: FontWeight.w500,
        height: 1.2,
        color: onSurf,
      ),
      labelMedium: body(12, letter: 0.48, weight: FontWeight.w400, height: 1.2),
      labelSmall: body(10, letter: 0.80, weight: FontWeight.w400, height: 1.2),
    );
  }

  static ThemeData get theme {
    final textTheme = buildTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: electricCyan,
        onPrimary: Color(0xFF00363A),
        primaryContainer: electricCyan,
        onPrimaryContainer: Color(0xFF006970),
        secondary: protonPurple,
        onSecondary: Color(0xFF3C0090),
        secondaryContainer: protonPurple,
        onSecondaryContainer: secondarySoft,
        surface: surfaceContainer,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
        errorContainer: errorContainer,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: electricCyan),
        titleTextStyle: TextStyle(
          fontFamily: fontDisplay,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.9,
          color: electricCyan,
        ),
      ),
      cardTheme: CardThemeData(
        color: glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: glassBorderBright, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          foregroundColor: const Color(0xFF00363A),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontFamily: fontBody,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.84,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: electricCyan,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          side: const BorderSide(color: Color(0x5900F0FF), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: const TextStyle(
            fontFamily: fontBody,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.84,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? electricCyan : onSurface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? electricCyan.withValues(alpha: 0.35)
              : surfaceContainerHigh,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x0AFFFFFF),
        thickness: 1,
        space: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        indicatorColor: electricCyan.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? electricCyan
                : outline,
            size: 22,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontBody,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: states.contains(WidgetState.selected)
                ? electricCyan
                : outline,
          ),
        ),
      ),
    );
  }
}

// ── Semantic color aliases (referenced by gameplay/track screens) ────────────
extension KineticObsidianSemantics on KineticObsidian {
  static const Color success = Color(0xFF4ADE80); // green — correct answer
  static const Color warning = Color(0xFFFACC15); // amber — low time
}

// ── Alias so old code using MiToosaTheme compiles unchanged ──────────────────
class MiToosaTheme extends KineticObsidian {
  static ThemeData get darkTheme => AethericPulseDark.themeData;
  static ThemeData get lightTheme => AethericPulseLight.lightTheme;

  // Semantic colors
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFACC15);
  static const Color error = KineticObsidian.error;

  // Shadow aliases
  static List<BoxShadow> get shadowCard => KineticObsidian.shadowNeonSoft;
  static List<BoxShadow> get shadowSubtle => KineticObsidian.shadowAmbient;
  static List<BoxShadow> get shadowElevated => KineticObsidian.shadowNeonMed;

  // Radius aliases
  static const double radiusSm = KineticObsidian.radiusSm;
  static const double radiusMd = KineticObsidian.radiusMd;
  static const double radiusLg = KineticObsidian.radiusLg;
  static const double radiusXl = KineticObsidian.radiusXl;
  static const double radiusFull = KineticObsidian.radiusFull;

  // Spacing aliases (old naming convention)
  static const double spacingSm = KineticObsidian.spaceBase;
  static const double spacingMd = KineticObsidian.spaceSm;
  static const double spacingLg = KineticObsidian.spaceMd;
  static const double spacingXl = KineticObsidian.spaceMargin;
  static const double spacingXxl = KineticObsidian.spaceLg;
}
