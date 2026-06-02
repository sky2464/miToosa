// Asserts that Aetheric Pulse tokens match the prototype tokens.css
// (Docs/mitoosa-design-system-2/project/tokens.css). These tests guard against
// drift between the design source-of-truth and the Flutter token namespace.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/theme/design_tokens.dart';

void main() {
  group('Aetheric Pulse — surface tokens match prototype', () {
    test('surface (--bg-1) is #0A0D17', () {
      expect(AethericPulseDark.surface, equals(const Color(0xFF0A0D17)));
    });
    test('surfaceEdge (--bg-0) is #060810', () {
      expect(AethericPulseDark.surfaceEdge, equals(const Color(0xFF060810)));
    });
    test('surfaceMid (--bg-2) is #0E1220', () {
      expect(AethericPulseDark.surfaceMid, equals(const Color(0xFF0E1220)));
    });
  });

  group('Aetheric Pulse — brand colors match prototype', () {
    test('brandBlue (--blue-500) is #3B82F6', () {
      expect(AethericPulseDark.brandBlue, equals(const Color(0xFF3B82F6)));
    });
    test('brandPurple (--purple-500) is #A855F7', () {
      expect(AethericPulseDark.brandPurple, equals(const Color(0xFFA855F7)));
    });
    test('accentCyan (--cyan-400) is #22D3EE', () {
      expect(AethericPulseDark.accentCyan, equals(const Color(0xFF22D3EE)));
    });
    test('accentPink (--pink-500) is #EC4899', () {
      expect(AethericPulseDark.accentPink, equals(const Color(0xFFEC4899)));
    });
    test('accentAmber (--amber-400) is #FACC15', () {
      expect(AethericPulseDark.accentAmber, equals(const Color(0xFFFACC15)));
    });
    test('accentOrange (--orange-400) is #FB923C', () {
      expect(AethericPulseDark.accentOrange, equals(const Color(0xFFFB923C)));
    });
    test('accentEmerald (--emerald-400) is #34D399', () {
      expect(AethericPulseDark.accentEmerald, equals(const Color(0xFF34D399)));
    });
  });

  group('Aetheric Pulse — glass recipe matches prototype', () {
    test('glassFill alpha ~0.08 (white)', () {
      // Prototype README + code.html use rgba(255,255,255,0.08).
      expect(AethericPulseDark.glassFill.r, equals(1.0));
      expect(AethericPulseDark.glassFill.g, equals(1.0));
      expect(AethericPulseDark.glassFill.b, equals(1.0));
    });
    test('glassBorder alpha ~0.12 (white)', () {
      expect(AethericPulseDark.glassBorder.r, equals(1.0));
      expect(AethericPulseDark.glassBorder.g, equals(1.0));
      expect(AethericPulseDark.glassBorder.b, equals(1.0));
    });
    test('glassBorderStrong is defined for emphasized states', () {
      expect(AethericPulseDark.glassBorderStrong, isA<Color>());
      // 0.18 alpha is more opaque than glassBorder (0.12)
      expect(
        AethericPulseDark.glassBorderStrong.a,
        greaterThan(AethericPulseDark.glassBorder.a),
      );
    });
  });

  group('Aetheric Pulse — corner radii match prototype', () {
    test('radiusCard is 24', () {
      expect(AethericPulseDark.radiusCard, equals(24.0));
    });
    test('radiusHeroCard is 32', () {
      expect(AethericPulseDark.radiusHeroCard, equals(32.0));
    });
    test('radiusPill is 999 (full pill)', () {
      expect(AethericPulseDark.radiusPill, equals(999.0));
    });
  });

  group('Aetheric Pulse — motion durations match prototype', () {
    test('durPress is 120ms', () {
      expect(
        AethericPulseDark.durPress,
        equals(const Duration(milliseconds: 120)),
      );
    });
    test('durHover is 180ms', () {
      expect(
        AethericPulseDark.durHover,
        equals(const Duration(milliseconds: 180)),
      );
    });
    test('durNormal is 300ms', () {
      expect(
        AethericPulseDark.durNormal,
        equals(const Duration(milliseconds: 300)),
      );
    });
    test('durHero is 600ms', () {
      expect(
        AethericPulseDark.durHero,
        equals(const Duration(milliseconds: 600)),
      );
    });
  });

  group('design_tokens.dart re-export namespace', () {
    test('AP.blue is brandBlue', () {
      expect(AP.blue, equals(AethericPulseDark.brandBlue));
    });
    test('AP.purple is brandPurple', () {
      expect(AP.purple, equals(AethericPulseDark.brandPurple));
    });
    test('AP.gradPrimary is gradPrimary', () {
      expect(AP.gradPrimary, equals(AethericPulseDark.gradPrimary));
    });
    test('AP.radiusCard is radiusCard', () {
      expect(AP.radiusCard, equals(AethericPulseDark.radiusCard));
    });
  });
}
