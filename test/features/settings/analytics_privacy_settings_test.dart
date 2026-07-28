import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics_consent_service.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';
import 'package:mitoosa/features/settings/analytics_privacy_controller.dart';
import 'package:mitoosa/features/settings/privacy_disclosure_copy.dart';
import 'package:mitoosa/features/settings/privacy_policy_screen.dart';
import 'package:mitoosa/features/settings/settings_screen.dart';
import 'package:mitoosa/widgets/settings_row.dart';
import 'package:mitoosa/widgets/toggle_switch.dart';

PlayerProgress _freshProgress() => PlayerProgress(playerId: 'test');

Future<void> _scrollToPrivacy(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text(kAnonymousAnalyticsTitle),
    200,
    scrollable: find.byType(Scrollable).first,
  );
}

Widget _wrap({
  PlayerProgress? progress,
  FakePrivacyPreferencesRepository? preferences,
  RecordingAnalyticsConsentAdapter? adapter,
}) {
  final prefs = preferences ?? FakePrivacyPreferencesRepository();
  bindPrivacyPreferencesRepository(prefs);
  final consentAdapter = adapter ?? RecordingAnalyticsConsentAdapter();
  return ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith((_) => Future.value(progress ?? _freshProgress())),
      analyticsConsentServiceProvider.overrideWithValue(
        AnalyticsConsentService(consentAdapter),
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

void main() {
  group('Settings privacy disclosure T-004', () {
    testWidgets('shows anonymous analytics disclosure and toggle', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await _scrollToPrivacy(tester);

      expect(find.text('PRIVACY'), findsOneWidget);
      expect(find.text(kAnonymousAnalyticsTitle), findsOneWidget);
      expect(find.text(kAnonymousAnalyticsSubtitle), findsOneWidget);
      expect(find.text(kPrivacyPolicyLinkLabel), findsOneWidget);
    });

    testWidgets('shows opt-out effect when analytics disabled', (tester) async {
      await tester.pumpWidget(
        _wrap(preferences: FakePrivacyPreferencesRepository()..storedValue = false),
      );
      await tester.pumpAndSettle();
      await _scrollToPrivacy(tester);

      expect(find.text(kAnonymousAnalyticsDisabledEffect), findsOneWidget);
    });

    testWidgets('privacy policy route is accessible', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pumpAndSettle();
      await _scrollToPrivacy(tester);

      await tester.tap(find.text(kPrivacyPolicyLinkLabel));
      await tester.pumpAndSettle();

      expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
      expect(find.text(kPrivacyPolicySummary), findsOneWidget);
    });

    testWidgets('toggle persists preference and applies consent', (tester) async {
      final preferences = FakePrivacyPreferencesRepository();
      final adapter = RecordingAnalyticsConsentAdapter();
      await tester.pumpWidget(_wrap(preferences: preferences, adapter: adapter));
      await tester.pumpAndSettle();
      await _scrollToPrivacy(tester);

      final analyticsRow = find.ancestor(
        of: find.text(kAnonymousAnalyticsTitle),
        matching: find.byType(SettingsRow),
      );
      final toggle = find.descendant(
        of: analyticsRow,
        matching: find.byType(ToggleSwitch),
      );
      expect(toggle, findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      expect(preferences.storedValue, isFalse);
      expect(adapter.lastCollectionEnabled, isFalse);
      expect(adapter.lastAdStorage, isFalse);
    });
  });
}
