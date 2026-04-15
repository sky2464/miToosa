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
  static const Color primary = Color(0xFF7B2CBF);
  static const Color primaryDark = Color(0xFF9D4EDD);
  static const Color secondary = Color(0xFF00F5D4);
  static const Color accent = Color(0xFFFF007F);
  
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF00FF87);
  static const Color warning = Color(0xFFFFBE0B);

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  static const double radiusSm = 12;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double radiusXl = 36;
  static const double radiusFull = 999;

  // Fallback font families to cover missing glyphs (emoji, symbols, CJK, etc.)
  // Place font assets in `assets/fonts/` and register them in `pubspec.yaml`.
  static const List<String> _fontFamilyFallback = [
    'Noto Sans',
    'Noto Sans Symbols',
    'Noto Color Emoji',
  ];

  static const _lightColors = MiToosaColors(
    ghostBorder: Color(0x4D4C4353),
    primaryLight: Color(0xFFDEB7FF),
    secondaryFixed: Color(0xFF26FEDC),
    secondaryDim: Color(0xFF00DFC1),
  );

  static const _darkColors = MiToosaColors(
    ghostBorder: Color(0x804C4353),
    primaryLight: Color(0xFF9D4EDD),
    secondaryFixed: Color(0xFF00DFC1),
    secondaryDim: Color(0xFF00B4A0),
  );

    static TextTheme _buildTextTheme(Color titleColor, Color bodyColor) {
      const fallbackStyle = TextStyle(fontFamilyFallback: _fontFamilyFallback);

    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w900, fontSize: 36, letterSpacing: -1.0),
      displayMedium: GoogleFonts.spaceGrotesk(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w800, fontSize: 28, letterSpacing: -0.5),
      headlineLarge: GoogleFonts.spaceGrotesk(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w700, fontSize: 24),
      headlineMedium: GoogleFonts.spaceGrotesk(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.bold, fontSize: 20),
      titleLarge: GoogleFonts.spaceGrotesk(textStyle: fallbackStyle, color: titleColor, fontWeight: FontWeight.w600, fontSize: 18),
      bodyLarge: GoogleFonts.manrope(textStyle: fallbackStyle, color: bodyColor, fontSize: 17, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.manrope(textStyle: fallbackStyle, color: bodyColor.withValues(alpha: 0.75), fontSize: 15),
      bodySmall: GoogleFonts.manrope(textStyle: fallbackStyle, color: bodyColor.withValues(alpha: 0.6), fontSize: 13),
      labelLarge: GoogleFonts.plusJakartaSans(textStyle: fallbackStyle, fontWeight: FontWeight.bold, fontSize: 16),
      labelMedium: GoogleFonts.plusJakartaSans(textStyle: fallbackStyle, fontWeight: FontWeight.w600, fontSize: 14),
      labelSmall: GoogleFonts.plusJakartaSans(textStyle: fallbackStyle, fontWeight: FontWeight.w600, fontSize: 12),
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
        textStyle: GoogleFonts.spaceGrotesk(textStyle: fallbackStyle, fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

    static ThemeData get lightTheme {
      const fallbackStyle = TextStyle(fontFamilyFallback: _fontFamilyFallback);

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F2FF),
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: Color(0xFFFFFFFF),
        error: error,
      ),
      textTheme: _buildTextTheme(const Color(0xFF1A1128), const Color(0xFF444444)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: primary),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          textStyle: fallbackStyle,
          color: const Color(0xFF1A1128),
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: primary.withValues(alpha: 0.08), width: 1.5),
        ),
      ),
      elevatedButtonTheme: _buildButtonTheme(primary, Colors.white),
      extensions: [_lightColors],
    );
  }

  static ThemeData get darkTheme {
    const onSurface = Color(0xFFEADFF1);
    const onSurfaceVariant = Color(0xFFCFC2D5);

    const fallbackStyle = TextStyle(fontFamilyFallback: _fontFamilyFallback);

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF16111D),
      primaryColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondary,
        tertiary: accent,
        surface: Color(0xFF2E2735),
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
        titleTextStyle: GoogleFonts.spaceGrotesk(
          textStyle: fallbackStyle,
          color: onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF2E2735),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: Color(0x804C4353), width: 1.5),
        ),
      ),
      elevatedButtonTheme: _buildButtonTheme(primary, onSurface),
      extensions: [_darkColors],
    );
  }
}
