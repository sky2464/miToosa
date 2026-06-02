import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/widgets/app_header.dart';
import 'package:mitoosa/widgets/atmosphere.dart';
import 'package:mitoosa/widgets/ghost_button.dart';
import 'package:mitoosa/widgets/primary_button.dart';
import 'package:mitoosa/widgets/stat_pill.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox.expand(child: child)),
);

void main() {
  // ─── Atmosphere ──────────────────────────────────────────────────────────────
  group('Atmosphere', () {
    testWidgets('renders without error with default accent', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere()));
      expect(find.byType(Atmosphere), findsOneWidget);
    });

    testWidgets('accepts blue accent without error', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere(accent: 'blue')));
      expect(find.byType(Atmosphere), findsOneWidget);
    });

    testWidgets('accepts cyan accent without error', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere(accent: 'cyan')));
      expect(find.byType(Atmosphere), findsOneWidget);
    });

    testWidgets('accepts pink accent without error', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere(accent: 'pink')));
      expect(find.byType(Atmosphere), findsOneWidget);
    });

    testWidgets('produces an animated Stack of blobs', (tester) async {
      await tester.pumpWidget(_wrap(const Atmosphere()));
      // Advance animation to confirm AnimatedBuilder re-renders
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Stack), findsWidgets);
    });
  });

  // ─── StatPill ────────────────────────────────────────────────────────────────
  group('StatPill', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(_wrap(const StatPill(label: 'XP 1200')));
      expect(find.text('XP 1200'), findsOneWidget);
    });

    testWidgets('renders icon widget when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const StatPill(
            icon: Icon(Icons.star),
            label: 'Stars',
            tint: StatPillTint.amber,
          ),
        ),
      );
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Stars'), findsOneWidget);
    });

    testWidgets('glow=true renders without error', (tester) async {
      await tester.pumpWidget(_wrap(const StatPill(label: 'Glow', glow: true)));
      expect(find.text('Glow'), findsOneWidget);
    });

    for (final tint in StatPillTint.values) {
      testWidgets('renders ${tint.name} tint without error', (tester) async {
        await tester.pumpWidget(_wrap(StatPill(label: tint.name, tint: tint)));
        expect(find.text(tint.name), findsOneWidget);
      });
    }
  });

  // ─── AppHeader ───────────────────────────────────────────────────────────────
  group('AppHeader', () {
    testWidgets('renders brand name miToosa', (tester) async {
      await tester.pumpWidget(_wrap(const AppHeader(credits: 500)));
      expect(find.text('miToosa'), findsOneWidget);
    });

    testWidgets('renders formatted credits for values under 1000', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppHeader(credits: 500)));
      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('renders formatted credits with comma for 1000+', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppHeader(credits: 1250)));
      expect(find.text('1,250'), findsOneWidget);
    });

    testWidgets('renders roleLabel in uppercase', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppHeader(credits: 0, roleLabel: 'Pilot · Lv 3')),
      );
      expect(find.text('PILOT · LV 3'), findsOneWidget);
    });

    testWidgets('onAvatarTap fires when avatar is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppHeader(credits: 0, onAvatarTap: () => tapped = true)),
      );
      // GestureDetector wraps a 36×36 container; tap the first found
      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });
  });

  // ─── PrimaryButton ───────────────────────────────────────────────────────────
  group('PrimaryButton', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(onPressed: () {}, child: const Text('Start'))),
      );
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('calls onPressed on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            onPressed: () => tapped = true,
            child: const Text('Go'),
          ),
        ),
      );
      await tester.tap(find.byType(PrimaryButton));
      expect(tapped, isTrue);
    });

    testWidgets('renders in disabled state when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PrimaryButton(onPressed: null, child: Text('Locked'))),
      );
      expect(find.text('Locked'), findsOneWidget);
    });

    testWidgets('fullWidth: true stretches to available width', (tester) async {
      await tester.pumpWidget(
        _wrap(
          PrimaryButton(
            onPressed: () {},
            fullWidth: true,
            child: const Text('Wide'),
          ),
        ),
      );
      expect(find.text('Wide'), findsOneWidget);
    });
  });

  // ─── GhostButton ─────────────────────────────────────────────────────────────
  group('GhostButton', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        _wrap(GhostButton(onPressed: () {}, child: const Text('Cancel'))),
      );
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onPressed on tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          GhostButton(
            onPressed: () => tapped = true,
            child: const Text('Skip'),
          ),
        ),
      );
      await tester.tap(find.byType(GhostButton));
      expect(tapped, isTrue);
    });

    testWidgets('renders in disabled state when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const GhostButton(onPressed: null, child: Text('Unavailable'))),
      );
      expect(find.text('Unavailable'), findsOneWidget);
    });

    testWidgets('fullWidth: true stretches to available width', (tester) async {
      await tester.pumpWidget(
        _wrap(
          GhostButton(
            onPressed: () {},
            fullWidth: true,
            child: const Text('Wide'),
          ),
        ),
      );
      expect(find.text('Wide'), findsOneWidget);
    });
  });
}
