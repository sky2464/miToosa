/// Widget tests for [MainAppShell] navigation — all 4 release tabs present,
/// tab switching works, and no crash on init.
///
/// Test IDs: T-006, T-007 (AC-005, AC-008)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics_consent_service.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';
import 'package:mitoosa/data/telemetry_event.dart';
import 'package:mitoosa/data/telemetry_provider.dart';
import 'package:mitoosa/data/telemetry_session_controller.dart';
import 'package:mitoosa/data/telemetry_repository.dart';
import 'package:mitoosa/features/main_app/main_app_shell.dart';
import 'package:mitoosa/features/settings/analytics_privacy_controller.dart';
import 'package:mitoosa/theme/design_system.dart';

// ─── No-op stub TelemetryRepository ────────────────────────────────────────────

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

// ─── Helpers ──────────────────────────────────────────────────────────────────

PlayerProgress _freshProgress() =>
    PlayerProgress.fresh(playerId: 'test-player');

final _noOpController = TelemetrySessionController(_NoOpTelemetryRepository());

Widget _wrap(PlayerProgress progress) {
  bindPrivacyPreferencesRepository(FakePrivacyPreferencesRepository());
  return ProviderScope(
  overrides: [
    playerProgressProvider.overrideWith((ref) async => progress),
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

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('MainAppShell — navigation bar (AC-005, T-006)', () {
    testWidgets('all 4 release tab labels are visible', (tester) async {
      tester.view.physicalSize = const Size(600, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();

      expect(find.text('Tracks'), findsOneWidget);
      expect(find.text('Path'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Leaders'), findsNothing);
    });

    testWidgets('first tab (Tracks) is active on launch', (tester) async {
      tester.view.physicalSize = const Size(600, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();
      // WorldMapScreen renders Daily Spark hero when Tracks tab is active
      expect(find.text("Today's session"), findsOneWidget);
    });
  });

  group('MainAppShell — tab switching (AC-008, T-007)', () {
    testWidgets('tapping Progress tab switches screen without crash', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();

      await tester.tap(find.text('Progress'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping Settings tab switches screen without crash', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(_wrap(_freshProgress()));
      await tester.pump();

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
