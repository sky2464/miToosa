import 'package:flutter/material.dart';
import 'design_system.dart';

/// Short-form alias for [AethericPulseDark]. Use this in widget code to keep
/// declarations terse while preserving a single source of truth for tokens.
///
/// Example:
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     color: AP.glassFill,
///     border: Border.all(color: AP.glassBorder),
///     borderRadius: BorderRadius.circular(AP.radiusCard),
///   ),
/// )
/// ```
class AP {
  AP._();

  // Surfaces
  static const Color surface = AethericPulseDark.surface;
  static const Color surfaceEdge = AethericPulseDark.surfaceEdge;
  static const Color surfaceMid = AethericPulseDark.surfaceMid;

  // Brand
  static const Color blue = AethericPulseDark.brandBlue;
  static const Color blueLight = AethericPulseDark.brandBlueLight;
  static const Color purple = AethericPulseDark.brandPurple;

  // Foreground
  static const Color fg = AethericPulseDark.onSurface;
  static const Color fgSecondary = AethericPulseDark.onSurfaceSecondary;
  static const Color fgMeta = AethericPulseDark.onSurfaceMeta;
  static const Color fgMuted = AethericPulseDark.onSurfaceMuted;

  // Accents
  static const Color cyan = AethericPulseDark.accentCyan;
  static const Color pink = AethericPulseDark.accentPink;
  static const Color amber = AethericPulseDark.accentAmber;
  static const Color orange = AethericPulseDark.accentOrange;
  static const Color emerald = AethericPulseDark.accentEmerald;

  // Glass
  static const Color glassFill = AethericPulseDark.glassFill;
  static const Color glassBorder = AethericPulseDark.glassBorder;
  static const Color glassBorderStrong = AethericPulseDark.glassBorderStrong;
  static const Color nestedWell = AethericPulseDark.nestedWell;
  static const Color activeBorder = AethericPulseDark.activeBorder;
  static const Color primaryGlow = AethericPulseDark.primaryGlow;

  // Gradients
  static const LinearGradient gradPrimary = AethericPulseDark.gradPrimary;
  static const LinearGradient gradMemory = AethericPulseDark.gradMemory;
  static const RadialGradient heroGlow = AethericPulseDark.heroGlow;

  /// Energy gradient — orange → amber (used for streak/energy pills).
  static const LinearGradient gradEnergy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AethericPulseDark.accentOrange, AethericPulseDark.accentAmber],
  );

  /// Gold gradient — soft amber → deep amber (VIP/mastery moments).
  static const LinearGradient gradGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
  );

  // Shadows
  static const List<BoxShadow> cardOuter = AethericPulseDark.cardOuter;
  static const List<BoxShadow> cardInner = AethericPulseDark.cardInner;
  static const List<BoxShadow> blueGlow = AethericPulseDark.blueGlow;
  static const List<BoxShadow> energyGlow = AethericPulseDark.energyGlow;

  // Radii
  static const double radiusChip = AethericPulseDark.radiusChip;
  static const double radiusWell = AethericPulseDark.radiusWell;
  static const double radiusCard = AethericPulseDark.radiusCard;
  static const double radiusHeroCard = AethericPulseDark.radiusHeroCard;
  static const double radiusHero = AethericPulseDark.radiusHero;
  static const double radiusPill = AethericPulseDark.radiusPill;

  // Spacing (4pt base)
  static const double spaceXs = AethericPulseDark.spaceXs;
  static const double spaceSm = AethericPulseDark.spaceSm;
  static const double spaceMd = AethericPulseDark.spaceMd;
  static const double spaceLg = AethericPulseDark.spaceLg;
  static const double spaceXl = AethericPulseDark.spaceXl;

  // Motion
  static const Duration durPress = AethericPulseDark.durPress;
  static const Duration durHover = AethericPulseDark.durHover;
  static const Duration durNormal = AethericPulseDark.durNormal;
  static const Duration durHero = AethericPulseDark.durHero;
  static const Curve easeOut = AethericPulseDark.easeOut;
  static const Curve springSoft = AethericPulseDark.springSoft;

  // Typography helpers
  static TextStyle heroNumeric({Color? color}) =>
      AethericPulseDark.heroNumeric(color: color);
  static TextStyle display({Color? color}) =>
      AethericPulseDark.display(color: color);
  static TextStyle headlineLg({Color? color}) =>
      AethericPulseDark.headlineLg(color: color);
  static TextStyle headlineMd({Color? color}) =>
      AethericPulseDark.headlineMd(color: color);
  static TextStyle bodyLg({Color? color}) =>
      AethericPulseDark.bodyLg(color: color);
  static TextStyle bodyMd({Color? color}) =>
      AethericPulseDark.bodyMd(color: color);
  static TextStyle label({Color? color}) =>
      AethericPulseDark.label(color: color);

  /// Eyebrow — small uppercase metadata label with tracking.
  static TextStyle eyebrow({Color? color}) => TextStyle(
        fontFamily: AethericPulseDark.fontBody,
        fontFamilyFallback: AethericPulseDark.fontFallback,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6, // 0.16em × 10
        color: color ?? AethericPulseDark.onSurfaceMeta,
        height: 1.2,
      );

  // Asset path helpers
  static const String iconDir = 'assets/images/icons';
  static const String avatarDir = 'assets/images/avatars';
  static const String badgeDir = 'assets/images/badges';

  /// Map a track ID (e.g. 'pattern_match') to its 3D icon PNG path.
  static String trackIcon(String id) => '$iconDir/track_$id.png';

  /// Map an avatar index (1-12) to its PNG path.
  static String avatar(int index) => '$avatarDir/avatar_$index.png';

  /// Map a badge ID (e.g. 'novice_mind') to its PNG path.
  static String badge(String id) => '$badgeDir/$id.png';
}
