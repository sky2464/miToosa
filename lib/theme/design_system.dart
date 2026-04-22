import 'package:flutter/material.dart';

/// Kinetic Obsidian — miToosa dark theme (the default).
/// Deep obsidian surfaces, Electric Cyan (#00F0FF) + Proton Purple (#7000FF),
/// glassmorphism cards, Orbitron display + Exo 2 body typography.
///
/// Aetheric Pulse (soft blue + pink pastel) tokens live alongside the Kinetic
/// Obsidian palette below — they power the light theme and targeted moments
/// (login CTA, dopamine toast, path-map unlocked nodes) without replacing the
/// primary dark-mode brand identity.
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
  static const Color electricCyan = Color(0xFF00F0FF);   // primary action
  static const Color protonPurple = Color(0xFF7000FF);   // secondary
  static const Color primarySoft = Color(0xFFDBFCFF);    // cyan-tinted on-dark text
  static const Color secondarySoft = Color(0xFFD1BCFF);  // lilac
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
  static const Color glassBorderBright = Color(0x1AFFFFFF); // top/left 0.10 alpha
  static const Color glassBorderDim = Color(0x08FFFFFF);    // right/bottom 0.03 alpha

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
  // Kinetic Obsidian's Soft-Tech scale (keep for existing screens that rely
  // on compact corners). Aetheric Pulse adds the large "pillow" radii below.
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
  static const Duration durCelebrate = Duration(milliseconds: 500);
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeSnappy = Curves.easeInOut;
  static const Curve springSoft = Curves.easeOutBack;

  // Old animation aliases
  static const Duration animFast = durFast;
  static const Duration animNormal = durMed;
  static const Duration animSlow = durSlow;
  static const Curve springBouncy = Curves.elasticOut;
  static const Curve springSnappy = Curves.easeOutBack;
  static const Curve springSmooth = Curves.easeOutCubic;

  // ── Accessibility ──────────────────────────────────────────────────────
  /// iOS HIG + WCAG minimum hit target (44×44 pt).
  static const double minTapTarget = 44.0;

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
  static TextTheme buildTextTheme({Color? onSurfaceColor, Color? onSurfaceVariantColor, Color? primarySoftColor}) {
    final onSurf = onSurfaceColor ?? onSurface;
    final onSurfVar = onSurfaceVariantColor ?? onSurfaceVariant;
    final primarySoft = primarySoftColor ?? KineticObsidian.primarySoft;
    TextStyle display(double size, {double letter = 2.0, FontWeight weight = FontWeight.w600, double height = 1.1, Color? color}) {
      return TextStyle(
        fontFamily: fontDisplay,
        fontFamilyFallback: fontFallback,
        fontSize: size, fontWeight: weight, height: height,
        letterSpacing: letter, color: color ?? primarySoft,
      );
    }
    TextStyle body(double size, {double letter = 0.3, FontWeight weight = FontWeight.w300, double height = 1.5, Color? color}) {
      return TextStyle(
        fontFamily: fontBody,
        fontFamilyFallback: fontFallback,
        fontSize: size, fontWeight: weight, height: height,
        letterSpacing: letter, color: color ?? onSurfVar,
      );
    }

    return TextTheme(
      // Orbitron — display & headlines
      displayLarge: display(48, letter: 2.4),
      displayMedium: display(40, letter: 2.0),
      headlineLarge: display(32, letter: 1.28, weight: FontWeight.w500, height: 1.2, color: onSurf),
      headlineMedium: display(24, letter: 0.72, weight: FontWeight.w500, height: 1.3, color: onSurf),
      headlineSmall: display(20, letter: 0.6, weight: FontWeight.w500, height: 1.3, color: onSurf),
      // Exo 2 — UI & body
      titleLarge: body(18, letter: 0.36, weight: FontWeight.w500, height: 1.4, color: onSurf),
      titleMedium: body(16, letter: 0.32, weight: FontWeight.w500, height: 1.4, color: onSurf),
      titleSmall: body(14, letter: 0.84, weight: FontWeight.w500, height: 1.2, color: onSurf),
      bodyLarge: body(18, letter: 0.36, height: 1.6),
      bodyMedium: body(16, letter: 0.32),
      bodySmall: body(13, letter: 0.26),
      labelLarge: body(14, letter: 0.84, weight: FontWeight.w500, height: 1.2, color: onSurf),
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
          fontSize: 18, fontWeight: FontWeight.w900,
          letterSpacing: 0.9, color: electricCyan,
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
            fontSize: 14, fontWeight: FontWeight.w700,
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
            fontSize: 14, fontWeight: FontWeight.w500,
            letterSpacing: 0.84,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? electricCyan : onSurface),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? electricCyan.withValues(alpha: 0.35)
                : surfaceContainerHigh),
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
            color: states.contains(WidgetState.selected) ? electricCyan : outline,
            size: 22,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontBody,
            fontSize: 10, fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: states.contains(WidgetState.selected) ? electricCyan : outline,
          ),
        ),
      ),
    );
  }
}

// ── Semantic color aliases (referenced by gameplay/track screens) ────────────
extension KineticObsidianSemantics on KineticObsidian {
  static const Color success = Color(0xFF4ADE80);   // green — correct answer
  static const Color warning = Color(0xFFFACC15);   // amber — low time
}

// ── Alias so old code using MiToosaTheme compiles unchanged ──────────────────
class MiToosaTheme extends KineticObsidian {
  // Theme aliases for tests / legacy callers.
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

// ─── Aetheric Pulse — soft-blue + pink pastel tokens ─────────────────────────
/// Targeted palette used on celebratory surfaces (login CTA, dopamine toast,
/// path-map unlocked nodes) and as the light-theme base. Not a replacement
/// for Kinetic Obsidian — the two coexist.
class AethericPulseLight {
  // Aetheric core — soft cognitive blue + pink pastel.
  static const Color softBlue = Color(0xFF597AFA);
  static const Color softBlueDeep = Color(0xFF3B5BDB);
  static const Color pinkPastel = Color(0xFFFFB3D1);
  static const Color pinkPastelDeep = Color(0xFFFF7AA8);
  static const Color lavender = Color(0xFFE9E6FF);

  // Light-theme surfaces (subtle lavender tint for warmth).
  static const Color lightSurface = Color(0xFFFBFAFF);
  static const Color lightSurfaceContainer = Color(0xFFF2F0FB);
  static const Color lightSurfaceContainerHigh = Color(0xFFE6E3F5);
  static const Color lightOnSurface = Color(0xFF1A1B2B);
  static const Color lightOnSurfaceVariant = Color(0xFF4A4C5E);
  static const Color lightOutline = Color(0xFF9A9BAE);
  static const Color lightOutlineVariant = Color(0xFFCECFDD);

  // Soft-blue → pink signature gradient (Aetheric Pulse hero moment).
  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softBlue, pinkPastel],
  );

  static const LinearGradient gradientReverse = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [pinkPastel, softBlue],
  );

  // Softer, semi-transparent variant for glows and backgrounds.
  static const LinearGradient gradientSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xCC597AFA), Color(0xCCFFB3D1)],
  );

  // Glows for light-mode surfaces (replaces cyan neon which halates on white).
  static const List<BoxShadow> shadowSoftBlue = [
    BoxShadow(color: Color(0x40597AFA), blurRadius: 24, offset: Offset(0, 6)),
  ];
  static const List<BoxShadow> shadowPinkPastel = [
    BoxShadow(color: Color(0x33FF7AA8), blurRadius: 20, offset: Offset(0, 4)),
  ];

  // Glass recipe for light mode — higher-alpha fill against off-white surfaces.
  static Color get glassFillLight => Colors.white.withValues(alpha: 0.60);
  static const Color glassBorderBrightLight = Color(0x66FFFFFF);
  static const Color glassBorderDimLight = Color(0x1A1A1B2B);

  /// Light theme paired with Aetheric Pulse tokens.
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: softBlue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFDDE4FF),
      onPrimaryContainer: softBlueDeep,
      secondary: pinkPastelDeep,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFE0EC),
      onSecondaryContainer: Color(0xFF6B2342),
      surface: lightSurface,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      outlineVariant: lightOutlineVariant,
      error: Color(0xFFBA1A1A),
      errorContainer: Color(0xFFFFDAD6),
    );
    final textTheme = KineticObsidian.buildTextTheme(
      onSurfaceColor: lightOnSurface,
      onSurfaceVariantColor: lightOnSurfaceVariant,
      primarySoftColor: softBlueDeep,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightSurface,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: softBlueDeep),
        titleTextStyle: TextStyle(
          fontFamily: KineticObsidian.fontDisplay,
          fontSize: 18, fontWeight: FontWeight.w900,
          letterSpacing: 0.9, color: softBlueDeep,
        ),
      ),
      cardTheme: CardThemeData(
        color: glassFillLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KineticObsidian.radiusPillow),
          side: const BorderSide(color: glassBorderDimLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: softBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KineticObsidian.radiusPillowLg),
          ),
          textStyle: const TextStyle(
            fontFamily: KineticObsidian.fontBody,
            fontSize: 15, fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: softBlueDeep,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: const BorderSide(color: softBlue, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KineticObsidian.radiusPillowLg),
          ),
          textStyle: const TextStyle(
            fontFamily: KineticObsidian.fontBody,
            fontSize: 14, fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x14000000),
        thickness: 1,
        space: 0,
      ),
    );
  }
}

// ─── Aetheric Pulse Dark — 2026 redesign tokens ───────────────────────────────
/// The primary dark theme for miToosa. Inter font, #0a0d17 surface,
/// blue #3b82f6 + purple #a855f7 gradient brand pair, glassmorphism cards.
class AethericPulseDark {
  // ── Surfaces ──────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFF0A0D17);
  static const Color surfaceEdge = Color(0xFF060810);

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandPurple = Color(0xFFA855F7);

  // ── Foreground ────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceSecondary = Color(0xFFD1D5DB);
  static const Color onSurfaceMeta = Color(0xFF9CA3AF);
  static const Color onSurfaceMuted = Color(0xFF6B7280);

  // ── Accents ───────────────────────────────────────────────────────────────
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentAmber = Color(0xFFFACC15);
  static const Color accentOrange = Color(0xFFFB923C);

  // ── Glass recipe ──────────────────────────────────────────────────────────
  static const Color glassFill = Color(0x14FFFFFF);       // rgba(255,255,255,0.08)
  static const Color glassBorder = Color(0x1FFFFFFF);     // rgba(255,255,255,0.12)
  static const Color glassHoverBorder = Color(0x2EFFFFFF); // rgba(255,255,255,0.18)
  static const Color activeBorder = Color(0x8C3B82F6);    // rgba(59,130,246,0.55)
  static const Color nestedWell = Color(0x0DFFFFFF);      // rgba(255,255,255,0.05)
  static const Color primaryGlow = Color(0x663B82F6);     // rgba(59,130,246,0.40)

  // ── Gradients ─────────────────────────────────────────────────────────────
  /// Blue → purple 135°. Used for primary buttons, progress fills, nav indicator.
  static const LinearGradient gradPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandBlue, brandPurple],
  );

  /// Cyan → blue 135°. Used for memory-track accent.
  static const LinearGradient gradMemory = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentCyan, brandBlue],
  );

  /// Top-center blue radial glow. Used for app background atmosphere.
  static const RadialGradient heroGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 0.7,
    colors: [Color(0x593B82F6), Colors.transparent],
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static const List<BoxShadow> cardOuter = [
    BoxShadow(color: Color(0x40000000), blurRadius: 32, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> cardInner = [
    BoxShadow(color: Color(0x18FFFFFF), blurRadius: 20),
  ];
  static const List<BoxShadow> blueGlow = [
    BoxShadow(color: Color(0x663B82F6), blurRadius: 24),
  ];
  static const List<BoxShadow> energyGlow = [
    BoxShadow(color: Color(0x73FACC15), blurRadius: 18),
  ];

  // ── Corner radii ──────────────────────────────────────────────────────────
  static const double radiusChip = 10.0;
  static const double radiusWell = 16.0;
  static const double radiusSmCard = 16.0;
  static const double radiusCard = 24.0;
  static const double radiusHeroCard = 32.0;
  static const double radiusHero = 40.0;
  static const double radiusPill = 999.0;

  // ── Spacing (4 pt base) ───────────────────────────────────────────────────
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 48.0;

  // ── Motion ────────────────────────────────────────────────────────────────
  static const Duration durHover = Duration(milliseconds: 180);
  static const Duration durPress = Duration(milliseconds: 120);
  static const Duration durNormal = Duration(milliseconds: 300);
  static const Duration durHero = Duration(milliseconds: 600);

  // ── Font families ─────────────────────────────────────────────────────────
  static const String fontBody = 'Inter';
  static const List<String> fontFallback = [
    'Exo 2',
    'Noto Sans',
    'Noto Color Emoji',
  ];

  // ── Typography scale (Inter) ──────────────────────────────────────────────
  static TextStyle heroNumeric({Color? color}) => TextStyle(
    fontFamily: fontBody,
    fontFamilyFallback: fontFallback,
    fontSize: 64,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.28, // -0.02em × 64
    color: color ?? onSurface,
    height: 1.0,
  );

  static TextStyle display({Color? color}) => TextStyle(
    fontFamily: fontBody,
    fontFamilyFallback: fontFallback,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.88,
    color: color ?? onSurface,
    height: 1.1,
  );

  static TextStyle headlineLg({Color? color}) => TextStyle(
    fontFamily: fontBody,
    fontFamilyFallback: fontFallback,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: color ?? onSurface,
    height: 1.2,
  );

  static TextStyle headlineMd({Color? color}) => TextStyle(
    fontFamily: fontBody,
    fontFamilyFallback: fontFallback,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: color ?? onSurface,
    height: 1.3,
  );

  static TextStyle bodyLg({Color? color}) => TextStyle(
    fontFamily: fontBody,
    fontFamilyFallback: fontFallback,
    fontSize: 18,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: color ?? onSurfaceSecondary,
    height: 1.5,
  );

  static TextStyle bodyMd({Color? color}) => TextStyle(
    fontFamily: fontBody,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: color ?? onSurfaceSecondary,
    height: 1.5,
  );

  static TextStyle label({Color? color}) => TextStyle(
    fontFamily: fontBody,
    fontFamilyFallback: fontFallback,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.96, // 0.08em × 12
    color: color ?? onSurfaceMeta,
    height: 1.2,
  );

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.dark(
        primary: brandBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF1D3461),
        onPrimaryContainer: Color(0xFFBFD7FF),
        secondary: brandPurple,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF3B1F5C),
        onSecondaryContainer: Color(0xFFE5C6FF),
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceSecondary,
        outline: onSurfaceMeta,
        outlineVariant: onSurfaceMuted,
        error: Color(0xFFFF6B6B),
        errorContainer: Color(0xFF7B1D1D),
      ),
      textTheme: TextTheme(
        displayLarge: heroNumeric(),
        displayMedium: display(),
        headlineLarge: headlineLg(),
        headlineMedium: headlineMd(),
        headlineSmall: headlineMd(color: onSurfaceSecondary),
        titleLarge: bodyLg(color: onSurface),
        titleMedium: bodyMd(color: onSurface),
        titleSmall: label(color: onSurface),
        bodyLarge: bodyLg(),
        bodyMedium: bodyMd(),
        bodySmall: label(),
        labelLarge: label(color: onSurface),
        labelMedium: label(),
        labelSmall: label(color: onSurfaceMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: onSurface),
        titleTextStyle: headlineMd(),
      ),
      cardTheme: CardThemeData(
        color: glassFill,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: const BorderSide(color: glassBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: brandBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: label(color: Colors.white),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? brandBlue : onSurfaceMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? brandBlue.withValues(alpha: 0.4)
                : onSurfaceMuted.withValues(alpha: 0.3)),
      ),
      dividerTheme: const DividerThemeData(
        color: glassBorder,
        thickness: 1,
        space: 0,
      ),
    );
  }
}
