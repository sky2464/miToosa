import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/main_app/progress_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

Widget _progressAt320(PlayerProgress progress) {
  return MediaQuery(
    data: const MediaQueryData(
      size: Size(320, 640),
      textScaler: TextScaler.linear(1.3),
    ),
    child: ProviderScope(
      overrides: [playerProgressProvider.overrideWith((ref) async => progress)],
      child: MaterialApp(
        theme: AethericPulseDark.themeData,
        home: const Scaffold(body: ProgressScreen()),
      ),
    ),
  );
}

void main() {
  testWidgets('Progress exposes labeled engagement navigation rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _progressAt320(PlayerProgress.fresh(playerId: 'a11y')),
    );
    await tester.pump();
    expect(find.text('Daily rewards'), findsOneWidget);
    expect(find.text('Streak calendar'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
  });
}
