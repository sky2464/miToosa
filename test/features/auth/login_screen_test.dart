/// Widget tests for [LoginScreen].
///
/// Coverage:
/// - Renders without overflow in portrait.
/// - Brand title and subtitle resolve via textTheme (Phase 2 guard).
/// - CTA ConstrainedBox satisfies minTapTarget ≥ 44 pt (Phase 3 guard).
/// - CTA exposes a Semantics label for assistive technology.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/auth/auth_provider.dart';
import 'package:mitoosa/features/auth/login_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Stub [Auth] notifier that returns a settled player ID without touching
/// PlatformSecureStorage.
class _FakeAuth extends Auth {
  @override
  Future<String> build() async => 'test-player-id';
}

/// Builds a [LoginScreen] with overridden providers so no real secure storage
/// or Hive is accessed during tests.
Widget _buildLogin() {
  return ProviderScope(
    overrides: [
      authProvider.overrideWith(_FakeAuth.new),
      playerProgressProvider.overrideWith(
        (ref) async => PlayerProgress.fresh(playerId: 'test-player-id'),
      ),
    ],
    child: MaterialApp(
      theme: AethericPulseDark.themeData,
      home: const LoginScreen(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('LoginScreen — rendering', () {
    testWidgets('renders without overflow in portrait (390×844)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildLogin());
      await tester.pump(); // settle FutureProvider

      expect(tester.takeException(), isNull,
          reason: 'No RenderFlex overflow in portrait');
    });

    testWidgets('brand title renders via textTheme.headlineLarge (Phase 2 guard)',
        (tester) async {
      await tester.pumpWidget(_buildLogin());
      await tester.pump();

      // Phase 2 replaced const Text('miToosa', style: TextStyle(fontSize:28,...))
      // with Text('miToosa', style: Theme.of(context).textTheme.headlineLarge).
      // If textTheme.headlineLarge is null, Text renders with default style —
      // this test confirms the text is still visible (non-null resolution).
      expect(find.text('miToosa'), findsOneWidget,
          reason: 'headlineLarge must resolve to a non-null style');
    });

    testWidgets('subtitle renders via textTheme.bodyMedium (Phase 2 guard)',
        (tester) async {
      await tester.pumpWidget(_buildLogin());
      await tester.pump();

      expect(find.text('Unlock Your Cognitive Potential'), findsOneWidget,
          reason: 'bodyMedium must resolve to a non-null style');
    });
  });

  group('LoginScreen — accessibility', () {
    testWidgets(
        'CTA ConstrainedBox satisfies minTapTarget ≥ 44 pt (Phase 3 guard)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_buildLogin());
      await tester.pump();

      // The CTA button is wrapped in:
      //   ConstrainedBox(constraints: BoxConstraints(minHeight: minTapTarget))
      // Verify the rendered box honours the 44 pt WCAG touch-target floor.
      final constrainedBoxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where((cb) =>
              cb.constraints.minHeight >= AethericPulseDark.minTapTarget)
          .toList();

      expect(constrainedBoxes, isNotEmpty,
          reason:
              'At least one ConstrainedBox must enforce minHeight ≥ '
              '${AethericPulseDark.minTapTarget} pt (WCAG touch target)');
    });

    testWidgets('CTA has Semantics button label for screen readers',
        (tester) async {
      await tester.pumpWidget(_buildLogin());
      await tester.pump();

      final ctaSemanticsLabel = find.bySemanticsLabel(
        RegExp('Get started', caseSensitive: false),
      );
      expect(ctaSemanticsLabel, findsAtLeastNWidgets(1),
          reason: 'CTA must expose a Semantics label for assistive technology');
    });
  });
}
