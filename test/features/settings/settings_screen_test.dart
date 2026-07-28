import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';
import 'package:mitoosa/core/analytics_consent_service.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/features/settings/analytics_privacy_controller.dart';
import 'package:mitoosa/features/settings/settings_screen.dart';

PlayerProgress _freshProgress() => PlayerProgress(playerId: 'test');

Widget _wrap({PlayerProgress? progress}) {
  bindPrivacyPreferencesRepository(FakePrivacyPreferencesRepository());
  final p = progress ?? _freshProgress();
  return ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith((_) => Future.value(p)),
      analyticsConsentServiceProvider.overrideWithValue(
        AnalyticsConsentService(RecordingAnalyticsConsentAdapter()),
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  group('SettingsScreen', () {
    testWidgets('renders app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('shows mastery tier card', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('YOUR MASTERY'), findsOneWidget);
    });

    testWidgets('shows adaptive difficulty toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Adaptive Difficulty'), findsOneWidget);
    });

    testWidgets('shows haptics toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Haptics'), findsOneWidget);
    });

    testWidgets('shows music toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Music'), findsOneWidget);
    });

    testWidgets('shows sound effects toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('Sound FX'), findsOneWidget);
    });

    testWidgets('shows Audio section header', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      expect(find.text('SYSTEM'), findsOneWidget);
    });

    testWidgets('shows reset progress row', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Reset progress'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Reset progress'), findsOneWidget);
    });

    testWidgets('shows shipped version label', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('V1.5.1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('V1.5.1'), findsOneWidget);
    });
  });
}
