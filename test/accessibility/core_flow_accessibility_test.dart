/// BL-36 core launch accessibility matrix — T-001 through T-005 (@smoke).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/analytics_consent_service.dart';
import 'package:mitoosa/core/content_provider.dart';
import 'package:mitoosa/core/models/puzzle.dart';
import 'package:mitoosa/data/telemetry_event.dart';
import 'package:mitoosa/data/audio_preferences_repository.dart';
import 'package:mitoosa/data/player_progress.dart';
import 'package:mitoosa/data/player_progress_provider.dart';
import 'package:mitoosa/data/privacy_preferences_repository.dart';
import 'package:mitoosa/data/telemetry_provider.dart';
import 'package:mitoosa/data/telemetry_session_controller.dart';
import 'package:mitoosa/data/telemetry_repository.dart';
import 'package:mitoosa/features/auth/auth_provider.dart';
import 'package:mitoosa/features/auth/login_screen.dart';
import 'package:mitoosa/features/gameplay/gameplay_screen.dart';
import 'package:mitoosa/features/main_app/main_app_shell.dart';
import 'package:mitoosa/features/main_app/progress_screen.dart';
import 'package:mitoosa/features/onboarding/onboarding_screen.dart';
import 'package:mitoosa/features/settings/analytics_privacy_controller.dart';
import 'package:mitoosa/features/settings/settings_screen.dart';
import 'package:mitoosa/theme/design_system.dart';

// ── MediaQuery fixtures ───────────────────────────────────────────────────────

MediaQueryData coreFlowMediaQuery({
  required Size size,
  double textScale = 1.0,
  bool disableAnimations = false,
  bool accessibleNavigation = false,
}) {
  return MediaQueryData(
    size: size,
    devicePixelRatio: 1,
    textScaler: TextScaler.linear(textScale),
    disableAnimations: disableAnimations,
    accessibleNavigation: accessibleNavigation,
    padding: const EdgeInsets.only(top: 47, bottom: 34),
  );
}

Widget withCoreFlowMedia({
  required MediaQueryData data,
  required Widget child,
}) {
  return MediaQuery(data: data, child: child);
}

void expectNoLayoutOverflow(WidgetTester tester, {String? reason}) {
  final err = tester.takeException();
  if (err != null && err.toString().contains('overflowed')) {
    fail('${reason ?? 'layout overflow'}\n$err');
  }
}

void expectMinTouchTarget(WidgetTester tester, Finder finder) {
  final rect = tester.getRect(finder);
  expect(
    rect.height,
    greaterThanOrEqualTo(MiToosaAccessibility.minTouchTarget),
  );
  expect(rect.width, greaterThanOrEqualTo(MiToosaAccessibility.minTouchTarget));
}

// ── Provider stubs ────────────────────────────────────────────────────────────

class _FakeAuth extends Auth {
  @override
  Future<String> build() async => 'a11y-player';
}

class _NoOpTelemetryRepository implements TelemetryRepository {
  @override
  Future<void> init() async {}
  @override
  Future<void> record(_) async {}
  @override
  Future<List<TelemetryEvent>> readAll() async => [];
  @override
  Future<void> clear() async {}
}

final _telemetryController = TelemetrySessionController(
  _NoOpTelemetryRepository(),
);

PlayerProgress _freshProgress([String trackId = 'test_math']) {
  final p = PlayerProgress.fresh(playerId: 'a11y-player');
  p.lastDailyRewardClaim = DateTime.now();
  p.markTutorialSeen(trackId);
  return p;
}

void _bindPortraitPhoneView(WidgetTester tester, {double width = 390}) {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

TrackDefinition _mathTrack() => TrackDefinition(
  id: 'test_math',
  name: 'Math Test',
  subtitle: 'Test track',
  rule: PuzzleRule.mathAddSub,
  iconAsset: 'assets/images/icons/track_number_crunch.png',
  targetLevelCount: 5,
  category: 'Test',
);

Widget _rooted(String id, Widget child) {
  return KeyedSubtree(key: ValueKey('a11y-$id'), child: child);
}

Widget _settings({MediaQueryData? media}) {
  bindPrivacyPreferencesRepository(FakePrivacyPreferencesRepository());
  bindAudioPreferencesRepository(FakeAudioPreferencesRepository());
  final shell = ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith((_) async => _freshProgress()),
      analyticsConsentServiceProvider.overrideWithValue(
        AnalyticsConsentService(RecordingAnalyticsConsentAdapter()),
      ),
    ],
    child: const MaterialApp(home: SettingsScreen()),
  );
  if (media == null) return _rooted('settings', shell);
  return _rooted('settings', withCoreFlowMedia(data: media, child: shell));
}

Widget _mainShell({MediaQueryData? media}) {
  bindPrivacyPreferencesRepository(FakePrivacyPreferencesRepository());
  bindAudioPreferencesRepository(FakeAudioPreferencesRepository());
  final shell = ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith((_) async => _freshProgress()),
      telemetrySessionControllerProvider.overrideWithValue(
        _telemetryController,
      ),
      analyticsConsentServiceProvider.overrideWithValue(
        AnalyticsConsentService(RecordingAnalyticsConsentAdapter()),
      ),
    ],
    child: MaterialApp(
      theme: AethericPulseDark.themeData,
      home: const MainAppShell(),
    ),
  );
  if (media == null) return _rooted('shell', shell);
  return _rooted('shell', withCoreFlowMedia(data: media, child: shell));
}

Widget _login({MediaQueryData? media}) {
  final shell = ProviderScope(
    overrides: [
      authProvider.overrideWith(_FakeAuth.new),
      playerProgressProvider.overrideWith(
        (_) async => PlayerProgress.fresh(playerId: 'a11y-player'),
      ),
    ],
    child: MaterialApp(
      theme: AethericPulseDark.themeData,
      home: const LoginScreen(),
    ),
  );
  if (media == null) return _rooted('login', shell);
  return _rooted('login', withCoreFlowMedia(data: media, child: shell));
}

Widget _onboarding({MediaQueryData? media}) {
  final shell = MaterialApp(
    theme: AethericPulseDark.themeData,
    home: OnboardingScreen(onComplete: () {}),
  );
  if (media == null) return _rooted('onboarding', shell);
  return _rooted('onboarding', withCoreFlowMedia(data: media, child: shell));
}

Widget _gameplay({MediaQueryData? media}) {
  final track = _mathTrack();
  final shell = ProviderScope(
    overrides: [
      playerProgressProvider.overrideWith(
        (_) async => _freshProgress(track.id),
      ),
    ],
    child: MaterialApp(
      darkTheme: AethericPulseDark.themeData,
      themeMode: ThemeMode.dark,
      home: GameplayScreen(track: track, levelIndex: 0),
    ),
  );
  if (media == null) return _rooted('gameplay', shell);
  return _rooted('gameplay', withCoreFlowMedia(data: media, child: shell));
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUp(() {
    ContentProvider().tracks = [_mathTrack()];
  });

  tearDown(() {
    ContentProvider().tracks = [];
  });

  group('T-001 — semantic core-flow sweep @smoke', () {
    testWidgets('onboarding exposes skip and next semantics', (tester) async {
      _bindPortraitPhoneView(tester);
      await tester.pumpWidget(_onboarding());
      await tester.pumpAndSettle();
      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('Skip onboarding', caseSensitive: false)),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(
          RegExp('Next onboarding page', caseSensitive: false),
        ),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('login and shell expose primary navigation semantics', (
      tester,
    ) async {
      _bindPortraitPhoneView(tester);
      await tester.pumpWidget(_login());
      await tester.pump();
      var handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('Get started', caseSensitive: false)),
        findsWidgets,
      );
      handle.dispose();

      await tester.pumpWidget(_mainShell());
      await tester.pump();
      handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Tracks tab'), findsOneWidget);
      expect(find.bySemanticsLabel('Open profile menu'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('settings and gameplay expose control semantics', (
      tester,
    ) async {
      _bindPortraitPhoneView(tester);
      await tester.pumpWidget(_settings());
      await tester.pumpAndSettle();
      var handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel(RegExp('Sound FX', caseSensitive: false)),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Reset progress'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.bySemanticsLabel(RegExp('Reset progress', caseSensitive: false)),
        findsOneWidget,
      );
      handle.dispose();

      await tester.pumpWidget(_gameplay());
      await tester.pump();
      await tester.pump();
      handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Hint'), findsOneWidget);
      expect(find.bySemanticsLabel('Submit answer'), findsOneWidget);
      handle.dispose();
    });
  });

  group('T-002 — minimum interaction geometry @smoke', () {
    testWidgets('core CTAs meet 44pt minimum targets', (tester) async {
      _bindPortraitPhoneView(tester);
      await tester.pumpWidget(_onboarding());
      await tester.pumpAndSettle();
      expectMinTouchTarget(
        tester,
        find.bySemanticsLabel(
          RegExp('Next onboarding page', caseSensitive: false),
        ),
      );

      await tester.pumpWidget(_mainShell());
      await tester.pump();
      expectMinTouchTarget(tester, find.bySemanticsLabel('Settings tab'));

      await tester.pumpWidget(_gameplay());
      await tester.pump();
      await tester.pump();
      expectMinTouchTarget(tester, find.bySemanticsLabel('Hint'));
      expectMinTouchTarget(tester, find.bySemanticsLabel('Submit answer'));
    });
  });

  group('T-003 — high text layout matrix @smoke', () {
    for (final width in MiToosaAccessibility.portraitSmokeWidths) {
      testWidgets('no overflow at ${width.toInt()}pt × high text scale', (
        tester,
      ) async {
        _bindPortraitPhoneView(tester, width: width);
        final media = coreFlowMediaQuery(
          size: Size(width, 700),
          textScale: MiToosaAccessibility.highTextScaleFactor,
        );

        await tester.pumpWidget(_onboarding(media: media));
        await tester.pumpAndSettle();
        expectNoLayoutOverflow(tester, reason: 'Onboarding at $width pt');

        await tester.pumpWidget(_mainShell(media: media));
        await tester.pump();
        expectNoLayoutOverflow(tester, reason: 'Main shell at $width pt');

        await tester.pumpWidget(_settings(media: media));
        await tester.pumpAndSettle();
        expectNoLayoutOverflow(tester, reason: 'Settings at $width pt');

        await tester.pumpWidget(_gameplay(media: media));
        await tester.pump();
        await tester.pump();
        expectNoLayoutOverflow(tester, reason: 'Gameplay at $width pt');
      });
    }
  });

  group('T-004 — reduced-motion state preservation @smoke', () {
    testWidgets('motionDuration collapses when disableAnimations is set', (
      tester,
    ) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(
        MiToosaAccessibility.motionDuration(
          ctx,
          const Duration(milliseconds: 300),
        ),
        Duration.zero,
      );
    });

    testWidgets('gameplay remains playable with reduced motion', (
      tester,
    ) async {
      _bindPortraitPhoneView(tester);
      final media = coreFlowMediaQuery(
        size: const Size(390, 844),
        disableAnimations: true,
        accessibleNavigation: true,
      );
      await tester.pumpWidget(_gameplay(media: media));
      await tester.pump();
      await tester.pump();

      final options = find.bySemanticsLabel(RegExp(r'^\d+$'));
      expect(options, findsWidgets);
      await tester.tap(options.first);
      await tester.pump();

      final submit = find.byKey(const ValueKey('submit_primary_button'));
      expectMinTouchTarget(tester, submit);
      await tester.tap(submit);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
    });
  });

  group('T-005 — portrait route smoke @smoke', () {
    for (final width in MiToosaAccessibility.portraitSmokeWidths) {
      testWidgets('core tabs reachable at ${width.toInt()}pt portrait', (
        tester,
      ) async {
        _bindPortraitPhoneView(tester, width: width);
        final media = coreFlowMediaQuery(size: Size(width, 720));
        await tester.pumpWidget(_mainShell(media: media));
        await tester.pump();

        for (final tab in ['Path', 'Progress', 'Settings', 'Tracks']) {
          await tester.tap(find.text(tab));
          await tester.pump();
          expectNoLayoutOverflow(
            tester,
            reason: '$tab tab at ${width.toInt()}pt',
          );
        }
      });
    }
  });

  testWidgets('Progress exposes labeled engagement navigation rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.3),
        ),
        child: ProviderScope(
          overrides: [
            playerProgressProvider.overrideWith(
              (ref) async => PlayerProgress.fresh(playerId: 'a11y'),
            ),
          ],
          child: MaterialApp(
            theme: AethericPulseDark.themeData,
            home: const Scaffold(body: ProgressScreen()),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Daily rewards'), findsOneWidget);
    expect(find.text('Streak calendar'), findsOneWidget);
    expect(find.text('Achievements'), findsOneWidget);
  });
}
