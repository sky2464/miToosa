import 'package:flutter/material.dart';

import 'kinetic_obsidian.dart';

/// Aetheric Pulse — soft-blue + pink pastel tokens for the light theme.
/// Targeted palette used on celebratory surfaces (login CTA, dopamine toast,
/// path-map unlocked nodes) and as the light-theme base.
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
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.9,
          color: softBlueDeep,
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
            fontSize: 15,
            fontWeight: FontWeight.w700,
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
            fontSize: 14,
            fontWeight: FontWeight.w500,
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
