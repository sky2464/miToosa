/// BL-29 copy audit — T-001 top-level economy strings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/navigation/world_map_screen.dart';
import 'package:mitoosa/theme/design_system.dart';
import 'package:mitoosa/widgets/app_header.dart';
import 'package:mitoosa/widgets/free_games_depleted_sheet.dart';

Widget _wrap(Widget child, {PlayerProgress? progress}) {
  return ProviderScope(
    overrides: [
      if (progress != null)
        playerProgressProvider.overrideWith((ref) async => progress),
    ],
    child: MaterialApp(theme: AethericPulseDark.themeData, home: child),
  );
}

void main() {
  group('BL-29 top-level copy (T-001)', () {
    testWidgets('AppHeader shows free games, not credits or CR', (tester) async {
      await tester.pumpWidget(
        _wrap(const Scaffold(body: AppHeader(freeGamesAvailable: 18))),
      );

      expect(find.text('free games'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('CR'), findsNothing);
      expect(find.textContaining('credit'), findsNothing);
    });

    testWidgets('WorldMapScreen stat strip uses free games label', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final progress = PlayerProgress.fresh(playerId: 'copy-audit')
        ..freeGamesRemaining = 12;

      await tester.pumpWidget(
        _wrap(const Scaffold(body: WorldMapScreen()), progress: progress),
      );
      await tester.pump();

      expect(find.textContaining('free games'), findsWidgets);
      expect(find.textContaining('energy'), findsNothing);
      expect(find.textContaining('sessions'), findsNothing);
    });

    testWidgets('depleted sheet offers share CTA without paywall copy', (
      tester,
    ) async {
      final progress = PlayerProgress.fresh(playerId: 'depleted')
        ..freeGamesRemaining = 0
        ..shareBonusGames = 0;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AethericPulseDark.themeData,
            home: _DepletedSheetOpener(progress: progress),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Share for +40 games'), findsOneWidget);
      expect(find.textContaining('VIP'), findsNothing);
      expect(find.textContaining('Go ad-free'), findsNothing);
    });
  });
}

class _DepletedSheetOpener extends ConsumerWidget {
  const _DepletedSheetOpener({required this.progress});

  final PlayerProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              showFreeGamesDepletedSheet(context, ref: ref, progress: progress),
          child: const Text('open'),
        ),
      ),
    );
  }
}
