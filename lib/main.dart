import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/design_system.dart';
import 'features/auth/login_screen.dart';
import 'features/main_app/main_app_shell.dart';
import 'features/auth/auth_provider.dart';
import 'data/player_progress_provider.dart';

import 'data/hive_persistence_provider.dart';
import 'core/content_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ContentProvider().init();
  await HivePersistenceProvider().init();

  runApp(
    const ProviderScope(
      child: MiToosaApp(),
    ),
  );
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
      darkTheme: KineticObsidian.theme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: authState.when(
        data: (playerId) => playerId.isEmpty
            ? const LoginScreen()
            : const MainAppShell(),
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
