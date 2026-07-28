/// BL-31 — Truthful launch surface regression tests (T-001, T-002, T-006).
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics_consent_service.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';
import 'package:mitoosa/data/telemetry_event.dart';
import 'package:mitoosa/data/telemetry_provider.dart';
import 'package:mitoosa/data/telemetry_repository.dart';
import 'package:mitoosa/data/telemetry_session_controller.dart';
import 'package:mitoosa/features/main_app/main_app_shell.dart';
import 'package:mitoosa/features/settings/analytics_privacy_controller.dart';
import 'package:mitoosa/features/navigation/world_map_screen.dart';
import 'package:mitoosa/features/settings/settings_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

class _NoOpTelemetryRepository implements TelemetryRepository {
  @override
  Future<void> init() async {}
  @override
  Future<void> record(TelemetryEvent event) async {}
  @override
  Future<List<TelemetryEvent>> readAll() async => [];
  @override
  Future<void> clear() async {}
}

final _noOpController = TelemetrySessionController(_NoOpTelemetryRepository());

PlayerProgress _freshProgress() =>
    PlayerProgress.fresh(playerId: 'test-player');

Widget _shell() {
  bindPrivacyPreferencesRepository(FakePrivacyPreferencesRepository());
  return ProviderScope(
  overrides: [
    playerProgressProvider.overrideWith((ref) async => _freshProgress()),
    telemetrySessionControllerProvider.overrideWithValue(_noOpController),
    analyticsConsentServiceProvider.overrideWithValue(
      AnalyticsConsentService(RecordingAnalyticsConsentAdapter()),
    ),
  ],
  child: MaterialApp(
    theme: AethericPulseDark.themeData,
    home: const MainAppShell(),
  ),
);
}

Widget _settings() {
  bindPrivacyPreferencesRepository(FakePrivacyPreferencesRepository());
  return ProviderScope(
  overrides: [
    playerProgressProvider.overrideWith((ref) async => _freshProgress()),
    analyticsConsentServiceProvider.overrideWithValue(
      AnalyticsConsentService(RecordingAnalyticsConsentAdapter()),
    ),
  ],
    child: const MaterialApp(home: SettingsScreen()),
  );
}

Widget _tracks() {
  ContentProvider().init();
  return ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith((ref) async => _freshProgress()),
    ],
    child: const MaterialApp(home: WorldMapScreen()),
  );
}

void main() {
  group('Truthful launch surfaces — shell tabs (T-001)', () {
    testWidgets('release shell exposes only supported tabs', (tester) async {
      tester.view.physicalSize = const Size(600, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_shell());
      await tester.pump();

      expect(find.text('Tracks'), findsOneWidget);
      expect(find.text('Path'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Leaders'), findsNothing);
    });
  });

  group('Truthful launch surfaces — settings catalog (T-002)', () {
    testWidgets('settings omits deferred or inert controls', (tester) async {
      await tester.pumpWidget(_settings());
      await tester.pumpAndSettle();

      expect(find.text('Share miToosa'), findsNothing);
      expect(find.text('Go VIP'), findsNothing);
      expect(find.text('Daily reminder'), findsNothing);
      expect(find.text('PILOT_042'), findsNothing);
      expect(find.text('ACCOUNT'), findsNothing);

      await tester.scrollUntilVisible(
        find.text('Reset progress'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Reset progress'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.textContaining('V1.5.1'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('V1.5.1'), findsOneWidget);
    });
  });

  group('Truthful launch surfaces — preview reachability (T-006)', () {
    testWidgets('tracks screen does not expose local play entry', (tester) async {
      await tester.pumpWidget(_tracks());
      await tester.pumpAndSettle();

      expect(find.text('Play Locally'), findsNothing);
      expect(find.textContaining('same Wi-Fi'), findsNothing);
    });

    test('release feature sources omit preview launch claims', () {
      final files = [
        File('lib/features/main_app/main_app_shell.dart'),
        File('lib/features/navigation/world_map_screen.dart'),
        File('lib/features/settings/settings_screen.dart'),
        File('lib/widgets/profile_menu_sheet.dart'),
      ];

      final banned = RegExp(
        r'preview live|coming soon|play locally|go vip|daily reminder|edit profile',
        caseSensitive: false,
      );

      for (final file in files) {
        expect(file.existsSync(), isTrue, reason: file.path);
        final text = file.readAsStringSync();
        expect(
          banned.hasMatch(text),
          isFalse,
          reason: '${file.path} contains deferred launch wording',
        );
      }
    });
  });
}
