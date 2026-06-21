import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/design_system.dart';
import 'features/auth/login_screen.dart';
import 'features/main_app/main_app_shell.dart';
import 'features/auth/auth_provider.dart';
import 'data/player_progress_provider.dart';

import 'data/hive_persistence_provider.dart';
import 'core/content_provider.dart';
import 'data/telemetry_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ContentProvider().init();
  await HivePersistenceProvider().init();

  if (kFirebaseEnabled) {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final analytics = FirebaseAnalytics.instance;
    await analytics.setConsent(
      analyticsStorageConsentGranted: true,
      adStorageConsentGranted: true,
      adUserDataConsentGranted: true,
      adPersonalizationSignalsConsentGranted: true,
    );
    await analytics.setAnalyticsCollectionEnabled(true);
    if (kDebugMode) {
      debugPrint('Firebase Analytics enabled for ${DefaultFirebaseOptions.ios.appId}');
      // Delay to give the native SDK time to apply Consent and Collection enablement
      Future.delayed(const Duration(seconds: 3), () async {
        debugPrint('Sending initial Firebase debug ping...');
        await analytics.logEvent(
          name: 'mitoosa_debug_ping',
          parameters: const {'source': 'main'},
        );
        final appInstanceId = await analytics.appInstanceId;
        debugPrint('Firebase appInstanceId: $appInstanceId');

        // Start a periodic pulse to provide a steady stream of events in DebugView
        Timer.periodic(const Duration(seconds: 15), (timer) async {
          debugPrint('Sending periodic Firebase debug pulse...');
          await analytics.logEvent(
            name: 'mitoosa_debug_pulse',
            parameters: {'tick': timer.tick},
          );
        });
      });
    }
  }

  runApp(const ProviderScope(child: MiToosaApp()));
}

class MiToosaApp extends ConsumerWidget {
  const MiToosaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final progressAsync = ref.watch(playerProgressProvider);
    final themeMode = progressAsync.maybeWhen(
      data: (p) => _themeModeFromOverride(p.themeModeOverride),
      orElse: () => ThemeMode.system,
    );

    return MaterialApp(
      title: 'miToosa',
      theme: AethericPulseLight.lightTheme,
      darkTheme: AethericPulseDark.themeData,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (playerId) =>
            playerId.isEmpty ? const LoginScreen() : const MainAppShell(),
        loading: () => const LoginScreen(),
        error: (_, _) => const LoginScreen(),
      ),
    );
  }

  static ThemeMode _themeModeFromOverride(int? override) {
    switch (override) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}