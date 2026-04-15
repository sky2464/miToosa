import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hive_persistence_provider.dart';
import 'persistence_provider.dart';
import 'player_progress.dart';
import '../features/auth/auth_provider.dart';

/// Provides singleton instance of [IPersistenceProvider].
final persistenceProvider = Provider<HivePersistenceProvider>((ref) {
  return HivePersistenceProvider();
});

/// Provides the current player's [PlayerProgress] for any screen that needs it.
///
/// Invalidate this provider after saving an update to force a refresh:
/// ```dart
/// ref.invalidate(playerProgressProvider);
/// ```
final playerProgressProvider = FutureProvider<PlayerProgress>((ref) async {
  final authState = ref.watch(authProvider);
  return authState.when(
    data: (playerId) async {
      final provider = ref.watch(persistenceProvider);
      return provider.loadProgress(playerId);
    },
    loading: () => PlayerProgress(playerId: 'loading'),
    error: (e, st) => throw e,
  );
});
