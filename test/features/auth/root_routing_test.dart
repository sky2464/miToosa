/// Widget tests for declarative root routing — fresh, completed, loading,
/// error, and completion refresh paths.
///
/// Test IDs: T-001–T-005 (AC-001–AC-005)
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/app/root_app_router.dart';
import 'package:mitoosa/core/analytics_consent_service.dart';
import 'package:mitoosa/data/hive_persistence_provider.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';
import 'package:mitoosa/data/telemetry_event.dart';
import 'package:mitoosa/data/telemetry_provider.dart';
import 'package:mitoosa/data/telemetry_session_controller.dart';
import 'package:mitoosa/data/telemetry_repository.dart';
import 'package:mitoosa/features/auth/auth_provider.dart';
import 'package:mitoosa/features/auth/login_screen.dart';
import 'package:mitoosa/features/main_app/main_app_shell.dart';
import 'package:mitoosa/features/settings/analytics_privacy_controller.dart';
import 'package:mitoosa/theme/design_system.dart';

// ── Stubs ────────────────────────────────────────────────────────────────────

class _FakeAuth extends Auth {
  @override
  Future<String> build() async => 'test-player-id';
}

class _NeverCompletesAuth extends Auth {
  @override
  Future<String> build() async => Completer<String>().future;
}

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

class _InMemoryPersistence extends HivePersistenceProvider {
  final Map<String, PlayerProgress> _store = {};

  @override
  Future<void> init() async {}

  @override
  Future<PlayerProgress> loadProgress(String playerId) async {
    return _store.putIfAbsent(
      playerId,
      () => PlayerProgress.fresh(playerId: playerId),
    );
  }

  @override
  Future<void> saveProgress(PlayerProgress progress) async {
    _store[progress.playerId] = progress;
  }

  @override
  Future<void> completeOnboarding(String playerId) async {
    final progress = await loadProgress(playerId);
    progress.completeOnboarding();
    await saveProgress(progress);
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

final _noOpTelemetry = TelemetrySessionController(_NoOpTelemetryRepository());

Future<void> _settleStartup(WidgetTester tester, {int frames = 5}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

Widget _wrap({required List overrides}) {
  bindPrivacyPreferencesRepository(FakePrivacyPreferencesRepository());
  return ProviderScope(
    overrides: [
      telemetrySessionControllerProvider.overrideWithValue(_noOpTelemetry),
      analyticsConsentServiceProvider.overrideWithValue(
        AnalyticsConsentService(RecordingAnalyticsConsentAdapter()),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      theme: AethericPulseDark.themeData,
      home: const RootAppRouter(),
    ),
  );
}

PlayerProgress _progress({required bool onboardingComplete}) {
  final progress = PlayerProgress.fresh(playerId: 'test-player-id');
  if (onboardingComplete) {
    progress.completeOnboarding();
  }
  return progress;
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('RootAppRouter — fresh player (T-001, AC-001)', () {
    testWidgets('renders onboarding and not MainAppShell', (tester) async {
      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith(_FakeAuth.new),
            playerProgressProvider.overrideWith(
              (ref) async => _progress(onboardingComplete: false),
            ),
          ],
        ),
      );
      await _settleStartup(tester);

      expect(find.text('Welcome to miToosa'), findsOneWidget);
      expect(find.byType(MainAppShell), findsNothing);
    });
  });

  group('RootAppRouter — completed player (T-002, AC-002)', () {
    testWidgets('renders MainAppShell and not onboarding', (tester) async {
      tester.view.physicalSize = const Size(600, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith(_FakeAuth.new),
            playerProgressProvider.overrideWith(
              (ref) async => _progress(onboardingComplete: true),
            ),
          ],
        ),
      );
      await _settleStartup(tester);

      expect(find.byType(MainAppShell), findsOneWidget);
      expect(find.text('Welcome to miToosa'), findsNothing);
    });
  });

  group('RootAppRouter — completion refresh (T-003, AC-003)', () {
    testWidgets('skip onboarding routes to MainAppShell without restart', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final persistence = _InMemoryPersistence();

      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith(_FakeAuth.new),
            persistenceProvider.overrideWithValue(persistence),
          ],
        ),
      );
      await _settleStartup(tester);

      expect(find.text('Welcome to miToosa'), findsOneWidget);

      await tester.tap(find.text('Skip'));
      await _settleStartup(tester);

      expect(find.byType(MainAppShell), findsOneWidget);
      expect(find.text('Welcome to miToosa'), findsNothing);
    });
  });

  group('RootAppRouter — loading (T-004, AC-004)', () {
    testWidgets('auth loading shows startup gate without shell flash', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith(_NeverCompletesAuth.new),
            playerProgressProvider.overrideWith(
              (ref) async => _progress(onboardingComplete: false),
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byKey(AppStartupLoading.loadingKey), findsOneWidget);
      expect(find.byType(MainAppShell), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('progress loading shows startup gate without shell flash', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith(_FakeAuth.new),
            playerProgressProvider.overrideWith(
              (ref) async => Completer<PlayerProgress>().future,
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.byKey(AppStartupLoading.loadingKey), findsOneWidget);
      expect(find.byType(MainAppShell), findsNothing);
      expect(find.byType(LoginScreen), findsNothing);
    });
  });

  group('RootAppRouter — error recovery (T-005, AC-005)', () {
    testWidgets('progress error shows recoverable UI without raw details', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          overrides: [
            authProvider.overrideWith(_FakeAuth.new),
            playerProgressProvider.overrideWithValue(
              AsyncValue.error(Exception('progress failed'), StackTrace.empty),
            ),
          ],
        ),
      );
      await _settleStartup(tester);

      expect(find.byKey(AppStartupError.errorKey), findsOneWidget);
      expect(find.textContaining('progress failed'), findsNothing);
      expect(find.byType(MainAppShell), findsNothing);
      expect(find.byKey(AppStartupError.retryKey), findsOneWidget);
    });

    testWidgets('Try again invokes recovery callback', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppStartupError(onRetry: () => retried = true),
        ),
      );

      await tester.tap(find.byKey(AppStartupError.retryKey));
      expect(retried, isTrue);
    });
  });
}
