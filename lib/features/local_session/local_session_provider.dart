import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/network/local_network_client.dart';
import '../../data/network/local_network_server.dart';
import '../../data/network/network_models.dart';

/// Local session state for multiplayer play.
enum LocalSessionPhase {
  idle,
  hosting,
  joining,
  playing,
  ended,
  error,
}

/// Model for a player in a local session.
class LocalSessionPlayer {
  final String playerId;
  final String name;
  int xp;
  int coins;
  int stars;

  LocalSessionPlayer({
    required this.playerId,
    required this.name,
    this.xp = 0,
    this.coins = 0,
    this.stars = 0,
  });

  LocalSessionPlayer copyWith({
    String? playerId,
    String? name,
    int? xp,
    int? coins,
    int? stars,
  }) {
    return LocalSessionPlayer(
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      stars: stars ?? this.stars,
    );
  }
}

/// Local session state container.
class LocalSessionState {
  final LocalSessionPhase phase;
  final String? sessionId;
  final String? hostIp;
  final int? hostPort;
  final String? qrUrl;
  final Map<String, LocalSessionPlayer> players;
  final String? currentPlayerId;
  final String? errorMessage;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  LocalSessionState({
    required this.phase,
    this.sessionId,
    this.hostIp,
    this.hostPort,
    this.qrUrl,
    this.players = const {},
    this.currentPlayerId,
    this.errorMessage,
    this.createdAt,
    this.expiresAt,
  });

  LocalSessionState copyWith({
    LocalSessionPhase? phase,
    String? sessionId,
    String? hostIp,
    int? hostPort,
    String? qrUrl,
    Map<String, LocalSessionPlayer>? players,
    String? currentPlayerId,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return LocalSessionState(
      phase: phase ?? this.phase,
      sessionId: sessionId ?? this.sessionId,
      hostIp: hostIp ?? this.hostIp,
      hostPort: hostPort ?? this.hostPort,
      qrUrl: qrUrl ?? this.qrUrl,
      players: players ?? this.players,
      currentPlayerId: currentPlayerId ?? this.currentPlayerId,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if session is still valid (not expired).
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Check if session is active (hosting or playing).
  bool get isActive =>
      phase == LocalSessionPhase.hosting ||
      phase == LocalSessionPhase.joining ||
      phase == LocalSessionPhase.playing;
}

/// Riverpod provider for managing local multiplayer sessions.
class _LocalSessionNotifier extends Notifier<LocalSessionState> {
  LocalNetworkServer? _server;
  LocalNetworkClient? _client;

  @override
  LocalSessionState build() {
    return LocalSessionState(phase: LocalSessionPhase.idle);
  }

  /// Start hosting a local session.
  Future<void> startHosting(String playerId, String playerName) async {
    state = state.copyWith(phase: LocalSessionPhase.hosting);

    try {
      final sessionId = 'session-${DateTime.now().millisecondsSinceEpoch}';
      final players = <String, LocalSessionPlayer>{
        playerId: LocalSessionPlayer(
          playerId: playerId,
          name: playerName,
        ),
      };

      state = state.copyWith(
        phase: LocalSessionPhase.hosting,
        sessionId: sessionId,
        players: players,
        currentPlayerId: playerId,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
    } catch (e) {
      state = state.copyWith(
        phase: LocalSessionPhase.error,
        errorMessage: 'Failed to start hosting: $e',
      );
    }
  }

  /// Join a local session via QR code.
  Future<void> joinSession(String qrUrl, String playerId, String playerName) async {
    state = state.copyWith(phase: LocalSessionPhase.joining);

    try {
      final parsed = LocalNetworkClient.parseQrUrl(qrUrl);
      if (parsed == null) {
        throw StateError('Invalid QR URL format');
      }

      final (url, sessionId, _) = parsed;

      _client = LocalNetworkClient(
        wsUrl: url,
        playerId: playerId,
        sessionId: sessionId,
        onMessageReceived: _handleRemoteMessage,
        onConnectionStateChanged: _handleConnectionStateChange,
      );

      state = state.copyWith(
        phase: LocalSessionPhase.joining,
        sessionId: sessionId,
        qrUrl: qrUrl,
        players: {
          playerId: LocalSessionPlayer(
            playerId: playerId,
            name: playerName,
          ),
        },
        currentPlayerId: playerId,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
    } catch (e) {
      state = state.copyWith(
        phase: LocalSessionPhase.error,
        errorMessage: 'Failed to join session: $e',
      );
    }
  }

  /// Start the actual game play.
  void startGame() {
    if (!state.isActive) return;

    state = state.copyWith(
      phase: LocalSessionPhase.playing,
    );
  }

  /// Record a move for the current player.
  void recordMove(int optionIndex, bool isCorrect, int stars, int xpGained) {
    if (!state.isActive || state.currentPlayerId == null) return;

    final playerId = state.currentPlayerId!;
    final player = state.players[playerId];
    if (player == null) return;

    final updatedPlayers = {...state.players};
    updatedPlayers[playerId] = player.copyWith(
      stars: player.stars + stars,
      xp: player.xp + xpGained,
    );

    state = state.copyWith(players: updatedPlayers);
  }

  /// Handle incoming message from remote player.
  void _handleRemoteMessage(NetworkMessage message) {
    if (message is MoveSelectedMessage) {
      final playerId = message.playerId;
      final player = state.players[playerId];
      if (player != null) {
        final updatedPlayers = {...state.players};
        updatedPlayers[playerId] = player.copyWith(
          stars: player.stars + message.stars,
          xp: player.xp + message.xpGained,
        );
        state = state.copyWith(players: updatedPlayers);
      }
    } else if (message is PlayerConnectedMessage) {
      if (!state.players.containsKey(message.playerId)) {
        final updatedPlayers = {...state.players};
        updatedPlayers[message.playerId] = LocalSessionPlayer(
          playerId: message.playerId,
          name: message.playerName,
        );
        state = state.copyWith(players: updatedPlayers);
      }
    } else if (message is PlayerDisconnectedMessage) {
      final updatedPlayers = {...state.players};
      updatedPlayers.remove(message.playerId);
      state = state.copyWith(players: updatedPlayers);
    } else if (message is SessionEndedMessage) {
      endSession();
    }
  }

  /// Handle connection state changes.
  void _handleConnectionStateChange(LocalNetworkClientState clientState) {
    if (clientState == LocalNetworkClientState.connected &&
        state.phase == LocalSessionPhase.joining) {
      startGame();
    } else if (clientState == LocalNetworkClientState.error) {
      state = state.copyWith(
        phase: LocalSessionPhase.error,
        errorMessage: 'Connection error',
      );
    } else if (clientState == LocalNetworkClientState.disconnected) {
      state = state.copyWith(
        phase: LocalSessionPhase.idle,
        sessionId: null,
        players: {},
      );
    }
  }

  /// End the current session.
  Future<void> endSession() async {
    try {
      if (_server != null) {
        await _server!.stop();
        _server = null;
      }
      if (_client != null) {
        await _client!.disconnect();
        _client = null;
      }

      state = state.copyWith(
        phase: LocalSessionPhase.idle,
        sessionId: null,
        players: {},
        currentPlayerId: null,
        qrUrl: null,
      );
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  /// Reset error state.
  void resetError() {
    if (state.phase == LocalSessionPhase.error) {
      state = state.copyWith(
        phase: LocalSessionPhase.idle,
        errorMessage: null,
        sessionId: null,
        players: {},
      );
    }
  }
}

/// Riverpod provider for local session management.
final localSessionProvider =
    NotifierProvider<_LocalSessionNotifier, LocalSessionState>(() {
  return _LocalSessionNotifier();
});
