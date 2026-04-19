import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MiToosaColors extends ThemeExtension<MiToosaColors> {
  final Color ghostBorder;
  final Color primaryLight;
  final Color secondaryFixed;
  final Color secondaryDim;

  const MiToosaColors({
    required this.ghostBorder,
    required this.primaryLight,
    required this.secondaryFixed,
    required this.secondaryDim,
  });

  @override
  MiToosaColors copyWith({
    Color? ghostBorder,
    Color? primaryLight,
    Color? secondaryFixed,
    Color? secondaryDim,
  }) {
    return MiToosaColors(
      ghostBorder: ghostBorder ?? this.ghostBorder,
      primaryLight: primaryLight ?? this.primaryLight,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      secondaryDim: secondaryDim ?? this.secondaryDim,
    );
  }

  @override
  MiToosaColors lerp(ThemeExtension<MiToosaColors>? other, double t) {
    if (other is! MiToosaColors) return this;
    return MiToosaColors(
      ghostBorder: Color.lerp(ghostBorder, other.ghostBorder, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      secondaryFixed: Color.lerp(secondaryFixed, other.secondaryFixed, t)!,
      secondaryDim: Color.lerp(secondaryDim, other.secondaryDim, t)!,
    );
  }
}

class MiToosaTheme {
  // ── Softer palette inspired by iToosa ──
  static const Color primary = Color(0xFF597AFA);      // Soft blue
  static const Color primaryDark = Color(0xFF7B95FF);   // Lighter blue for dark mode
  static const Color secondary = Color(0xFF9470DC);     // Soft purple
  static const Color accent = Color(0xFFFF6B9D);        // Soft pink
  
  static const Color error = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF51CF66);
  static const Color warning = Color(0xFFFFD43B);

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  static const double radiusSm = 14;
  static const double radiusMd = 22;
  static const double radiusLg = 30;
  static const double radiusXl = 40;
  static const double radiusFull = 999;

  // ── Shadow presets ──
  static List<BoxShadow> get shadowSubtle => [
    BoxShadow(color: primary.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
  ];
  static List<BoxShadow> get shadowCard => [
    BoxShadow(color: primary.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, 4)),
    BoxShadow(color: primary.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1)),
  ];
  static List<BoxShadow> get shadowElevated => [
    BoxShadow(color: primary.withValues(alpha: 0.12), blurRadius: 24, offset: const Offset(0, 8)),
    BoxShadow(color: primary.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  // ── Spring animation curves ──
  static const Curve springBouncy = Curves.elasticOut;
  static const Curve springSnappy = Curves.easeOutBack;
  static const Curve springSmooth = Curves.easeOutCubic;
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // Fallback font families to cover missing glyphs (emoji, symbols, CJK, etc.)
  // Place font assets in `assets/fonts/` and register them in `pubspec.yaml`.
  static const List<String> _fontFamilyFallback = [
    'Noto Sans',
    'Noto Sans Symbols',
    'Noto Color Emoji',
  ];

  static const _lightColors = MiToosaColors(
    ghostBorder: Color(0x334C4353),
    primaryLight: Color(0xFFB8C9FF),
    secondaryFixed: Color(0xFFB89EF0),
    secondaryDim: Color(0xFF7B5CBF),
  );

  static const _darkColors = MiToosaColors(
    ghostBorder: Color(0x664C4353),
    primaryLight: Color(0xFF7B95FF),
    secondaryFixed: Color(0xFF9470DC),
    secondaryDim: Color(0xFF6B4FC0),
  );

    static TextTheme _buildTextTheme(Color titleColor, Color bodyColor) {
      const fallbackStyle = TextStyle(fontFamilyFallback: _fontFamilyFallback);

    return TextTheme(
      displayLarge: GoogleFonts.nunito(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w900, fontSize: 36, letterSpacing: -0.5),
      displayMedium: GoogleFonts.nunito(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w800, fontSize: 28),
      headlineLarge: GoogleFonts.nunito(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w700, fontSize: 24),
      headlineMedium: GoogleFonts.nunito(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.bold, fontSize: 20),
      titleLarge: GoogleFonts.nunito(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: GoogleFonts.quicksand(textStyle: fallbackStyle, color: bodyColor, fontSize: 17, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.quicksand(textStyle: fallbackStyle, color: bodyColor.withValues(alpha: 0.75), fontSize: 15),
      bodySmall: GoogleFonts.quicksand(textStyle: fallbackStyle, color: bodyColor.withValues(alpha: 0.6), fontSize: 13),
      labelLarge: GoogleFonts.nunito(textStyle: fallbackStyle, fontWeight: FontWeight.bold, fontSize: 16),
      labelMedium: GoogleFonts.nunito(textStyle: fallbackStyle, fontWeight: FontWeight.w600, fontSize: 14),
      labelSmall: GoogleFonts.nunito(textStyle: fallbackStyle, fontWeight: FontWeight.w600, fontSize: 12),
    );
  }

    static ElevatedButtonThemeData _buildButtonTheme(Color bgColor, Color fgColor) {
      const fallbackStyle = TextStyle(fontFamilyFallback: _fontFamilyFallback);

    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusFull)),
        textStyle: GoogleFonts.nunito(textStyle: fallbackStyle, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

    static ThemeData get lightTheme {
      const fallbackStyle = TextStyle(fontFamilyFallback: _fontFamilyFallback);

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF8F9FF),
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: Color(0xFFFFFFFF),
        error: error,
      ),
      textTheme: _buildTextTheme(const Color(0xFF1A1D2E), const Color(0xFF4A4D5E)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.nunito(
          textStyle: fallbackStyle,
          color: const Color(0xFF1A1D2E),
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: primary.withValues(alpha: 0.10), width: 1.5),
        ),
      ),
      elevatedButtonTheme: _buildButtonTheme(primary, Colors.white),
      extensions: [_lightColors],
    );
  }

  static ThemeData get darkTheme {
    const onSurface = Color(0xFFE8E6F0);
    const onSurfaceVariant = Color(0xFFBDB8C7);

    const fallbackStyle = TextStyle(fontFamilyFallback: _fontFamilyFallback);

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF141420),
      primaryColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondary,
        tertiary: accent,
        surface: Color(0xFF1E1E2E),
        error: error,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      ),
      textTheme: _buildTextTheme(onSurface, onSurfaceVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryDark),
        titleTextStyle: GoogleFonts.nunito(
          textStyle: fallbackStyle,
          color: onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E2E),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: Color(0x664C4353), width: 1.5),
        ),
      ),
      elevatedButtonTheme: _buildButtonTheme(primary, onSurface),
      extensions: [_darkColors],
    );
  }
}
