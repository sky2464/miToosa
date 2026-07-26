import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_progress_provider.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/main_app/main_app_shell.dart';
import '../features/onboarding/onboarding_screen.dart';

/// Declarative root destination from authentication and persisted progress.
class RootAppRouter extends ConsumerWidget {
  const RootAppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      loading: () => const AppStartupLoading(),
      error: (_, _) => AppStartupError(
        onRetry: () => ref.invalidate(authProvider),
      ),
      data: (playerId) {
        if (playerId.isEmpty) {
          return const LoginScreen();
        }

        final progressAsync = ref.watch(playerProgressProvider);
        return progressAsync.when(
          loading: () => const AppStartupLoading(),
          error: (_, _) => AppStartupError(
            onRetry: () {
              ref.invalidate(authProvider);
              ref.invalidate(playerProgressProvider);
            },
          ),
          data: (progress) {
            if (!progress.onboardingComplete) {
              return OnboardingScreen(
                onComplete: () => _completeOnboarding(ref, playerId),
              );
            }
            return const MainAppShell();
          },
        );
      },
    );
  }

  Future<void> _completeOnboarding(WidgetRef ref, String playerId) async {
    final persistence = ref.read(persistenceProvider);
    await persistence.completeOnboarding(playerId);
    ref.invalidate(playerProgressProvider);
  }
}

/// Non-interactive startup gate while auth or progress resolves.
class AppStartupLoading extends StatelessWidget {
  const AppStartupLoading({super.key});

  static const loadingKey = ValueKey<String>('app-startup-loading');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: loadingKey,
      body: Center(
        child: Semantics(
          label: 'Loading',
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Recoverable startup failure — generic copy, no storage internals.
class AppStartupError extends StatelessWidget {
  const AppStartupError({super.key, required this.onRetry});

  static const errorKey = ValueKey<String>('app-startup-error');
  static const retryKey = ValueKey<String>('app-startup-retry');

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: errorKey,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Please try again.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: retryKey,
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
