import 'package:flutter/material.dart';

/// Aetheric Pulse Dark — the active dark theme for miToosa (2026 redesign).
/// Inter font, #0a0d17 surface, blue #3b82f6 + purple #a855f7 brand pair,
/// glassmorphism cards.
class AethericPulseDark {
  // ── Surfaces ──────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFF0A0D17);
  static const Color surfaceEdge = Color(0xFF060810);
  static const Color surfaceMid = Color(0xFF0E1220);

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color brandBlue = Color(0xFF3B82F6);
  static const Color brandPurple = Color(0xFFA855F7);
  static const Color brandBlueLight = Color(0xFF60A5FA); // blue-400 for atmosphere

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
  static const Color accentEmerald = Color(0xFF34D399);

  // ── Glass recipe ──────────────────────────────────────────────────────────
  static const Color glassFill = Color(0x14FFFFFF);          // rgba(255,255,255,0.08)
  static const Color glassBorder = Color(0x1FFFFFFF);        // rgba(255,255,255,0.12)
  static const Color glassBorderStrong = Color(0x2EFFFFFF);  // rgba(255,255,255,0.18)
  static const Color glassHoverBorder = Color(0x2EFFFFFF);   // alias for glassBorderStrong
  static const Color activeBorder = Color(0x8C3B82F6);       // rgba(59,130,246,0.55)
  static const Color nestedWell = Color(0x0DFFFFFF);         // rgba(255,255,255,0.05)
  static const Color primaryGlow = Color(0x663B82F6);        // rgba(59,130,246,0.40)

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

  /// Locked/inactive node fill in dark mode.
  static const LinearGradient gradLocked = LinearGradient(
    colors: [Color(0xFF2A2D34), Color(0xFF1D2026)],
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
  static const Duration durCelebrate = Duration(milliseconds: 500);
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeSnappy = Curves.easeInOut;
  static const Curve springSoft = Curves.easeOutBack;

  // ── Accessibility ─────────────────────────────────────────────────────────
  static const double minTapTarget = 44.0;

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
    letterSpacing: -1.28,
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
    letterSpacing: 0.96,
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
