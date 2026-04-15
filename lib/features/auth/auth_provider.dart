import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../data/platform_secure_storage.dart';

part 'auth_provider.g.dart';

/// Convenience extension to extract the current player ID.
extension AuthPlayerIdX on WidgetRef {
  /// Returns the current player ID, or `null` if auth is still loading/errored.
  String? get playerId => read(authProvider).maybeWhen(
        data: (v) => v,
        orElse: () => null,
      );
}

@riverpod
class Auth extends _$Auth {
  static const _playerIdKey = 'mitoosa_active_player_id';
  final _secureStorage = PlatformSecureStorage();

  @override
  Future<String> build() async {
    return _loadOrCreatePlayerId();
  }

  Future<String> _loadOrCreatePlayerId() async {
    final existingPlayerId = await _secureStorage.read(key: _playerIdKey);
    if (existingPlayerId != null) {
      return existingPlayerId;
    }

    final playerId = const Uuid().v4();
    await _secureStorage.write(key: _playerIdKey, value: playerId);
    return playerId;
  }

  Future<void> reset() async {
    state = const AsyncLoading<String>();
    state = await AsyncValue.guard(() async {
      await _secureStorage.delete(key: _playerIdKey);
      return _loadOrCreatePlayerId();
    });
  }
}
