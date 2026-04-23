import 'package:equatable/equatable.dart';

/// Sealed union for all network message types.
sealed class NetworkMessage extends Equatable {
  const NetworkMessage();

  /// Serialize to JSON for network transmission.
  Map<String, dynamic> toJson();

  /// Deserialize from JSON received over network.
  static NetworkMessage fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'join_session':
        return JoinSessionMessage.fromJson(json);
      case 'join_session_ack':
        return JoinSessionAckMessage.fromJson(json);
      case 'game_start':
        return GameStartMessage.fromJson(json);
      case 'move_selected':
        return MoveSelectedMessage.fromJson(json);
      case 'timer_tick':
        return TimerTickMessage.fromJson(json);
      case 'player_connected':
        return PlayerConnectedMessage.fromJson(json);
      case 'player_disconnected':
        return PlayerDisconnectedMessage.fromJson(json);
      case 'session_ended':
        return SessionEndedMessage.fromJson(json);
      case 'request_sync':
        return RequestSyncMessage.fromJson(json);
      case 'sync_state':
        return SyncStateMessage.fromJson(json);
      default:
        throw FormatException('Unknown message type: $type');
    }
  }
}

/// Client joins an existing session.
class JoinSessionMessage extends NetworkMessage {
  final String playerId;
  final String sessionId;
  final int timestamp;

  const JoinSessionMessage({
    required this.playerId,
    required this.sessionId,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'join_session',
        'playerId': playerId,
        'sessionId': sessionId,
        'timestamp': timestamp,
      };

  static JoinSessionMessage fromJson(Map<String, dynamic> json) =>
      JoinSessionMessage(
        playerId: json['playerId'] as String,
        sessionId: json['sessionId'] as String,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [playerId, sessionId, timestamp];
}

/// Server acknowledges client joined the session.
class JoinSessionAckMessage extends NetworkMessage {
  final String sessionId;
  final List<String> connectedPlayers;
  final int timestamp;

  const JoinSessionAckMessage({
    required this.sessionId,
    required this.connectedPlayers,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'join_session_ack',
        'sessionId': sessionId,
        'connectedPlayers': connectedPlayers,
        'timestamp': timestamp,
      };

  static JoinSessionAckMessage fromJson(Map<String, dynamic> json) =>
      JoinSessionAckMessage(
        sessionId: json['sessionId'] as String,
        connectedPlayers: List<String>.from(json['connectedPlayers'] as List),
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [sessionId, connectedPlayers, timestamp];
}

/// Host signals that the game is starting.
class GameStartMessage extends NetworkMessage {
  final String sessionId;
  final String levelId;
  final int durationSeconds;
  final int timestamp;

  const GameStartMessage({
    required this.sessionId,
    required this.levelId,
    required this.durationSeconds,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'game_start',
        'sessionId': sessionId,
        'levelId': levelId,
        'durationSeconds': durationSeconds,
        'timestamp': timestamp,
      };

  static GameStartMessage fromJson(Map<String, dynamic> json) =>
      GameStartMessage(
        sessionId: json['sessionId'] as String,
        levelId: json['levelId'] as String,
        durationSeconds: json['durationSeconds'] as int,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props =>
      [sessionId, levelId, durationSeconds, timestamp];
}

/// Player selected an option in the current level.
class MoveSelectedMessage extends NetworkMessage {
  final String playerId;
  final String sessionId;
  final String levelId;
  final int optionIndex;
  final bool isCorrect;
  final int stars;
  final int xpGained;
  final int timestamp;

  const MoveSelectedMessage({
    required this.playerId,
    required this.sessionId,
    required this.levelId,
    required this.optionIndex,
    required this.isCorrect,
    required this.stars,
    required this.xpGained,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'move_selected',
        'playerId': playerId,
        'sessionId': sessionId,
        'levelId': levelId,
        'optionIndex': optionIndex,
        'isCorrect': isCorrect,
        'stars': stars,
        'xpGained': xpGained,
        'timestamp': timestamp,
      };

  static MoveSelectedMessage fromJson(Map<String, dynamic> json) =>
      MoveSelectedMessage(
        playerId: json['playerId'] as String,
        sessionId: json['sessionId'] as String,
        levelId: json['levelId'] as String,
        optionIndex: json['optionIndex'] as int,
        isCorrect: json['isCorrect'] as bool,
        stars: json['stars'] as int,
        xpGained: json['xpGained'] as int,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [
        playerId,
        sessionId,
        levelId,
        optionIndex,
        isCorrect,
        stars,
        xpGained,
        timestamp,
      ];
}

/// Host broadcasts timer tick to all clients (sent periodically).
class TimerTickMessage extends NetworkMessage {
  final String sessionId;
  final int remainingSeconds;
  final int timestamp;

  const TimerTickMessage({
    required this.sessionId,
    required this.remainingSeconds,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'timer_tick',
        'sessionId': sessionId,
        'remainingSeconds': remainingSeconds,
        'timestamp': timestamp,
      };

  static TimerTickMessage fromJson(Map<String, dynamic> json) =>
      TimerTickMessage(
        sessionId: json['sessionId'] as String,
        remainingSeconds: json['remainingSeconds'] as int,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [sessionId, remainingSeconds, timestamp];
}

/// A new player has connected to the session.
class PlayerConnectedMessage extends NetworkMessage {
  final String sessionId;
  final String playerId;
  final String playerName;
  final int timestamp;

  const PlayerConnectedMessage({
    required this.sessionId,
    required this.playerId,
    required this.playerName,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'player_connected',
        'sessionId': sessionId,
        'playerId': playerId,
        'playerName': playerName,
        'timestamp': timestamp,
      };

  static PlayerConnectedMessage fromJson(Map<String, dynamic> json) =>
      PlayerConnectedMessage(
        sessionId: json['sessionId'] as String,
        playerId: json['playerId'] as String,
        playerName: json['playerName'] as String,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props =>
      [sessionId, playerId, playerName, timestamp];
}

/// A player has disconnected from the session.
class PlayerDisconnectedMessage extends NetworkMessage {
  final String sessionId;
  final String playerId;
  final int timestamp;

  const PlayerDisconnectedMessage({
    required this.sessionId,
    required this.playerId,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'player_disconnected',
        'sessionId': sessionId,
        'playerId': playerId,
        'timestamp': timestamp,
      };

  static PlayerDisconnectedMessage fromJson(Map<String, dynamic> json) =>
      PlayerDisconnectedMessage(
        sessionId: json['sessionId'] as String,
        playerId: json['playerId'] as String,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [sessionId, playerId, timestamp];
}

/// Host has ended the session.
class SessionEndedMessage extends NetworkMessage {
  final String sessionId;
  final String reason; // 'host_ended', 'timeout', 'error'
  final int timestamp;

  const SessionEndedMessage({
    required this.sessionId,
    required this.reason,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'session_ended',
        'sessionId': sessionId,
        'reason': reason,
        'timestamp': timestamp,
      };

  static SessionEndedMessage fromJson(Map<String, dynamic> json) =>
      SessionEndedMessage(
        sessionId: json['sessionId'] as String,
        reason: json['reason'] as String,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [sessionId, reason, timestamp];
}

/// Client requests current game state (for resync after lag/disconnect).
class RequestSyncMessage extends NetworkMessage {
  final String playerId;
  final String sessionId;
  final int timestamp;

  const RequestSyncMessage({
    required this.playerId,
    required this.sessionId,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'request_sync',
        'playerId': playerId,
        'sessionId': sessionId,
        'timestamp': timestamp,
      };

  static RequestSyncMessage fromJson(Map<String, dynamic> json) =>
      RequestSyncMessage(
        playerId: json['playerId'] as String,
        sessionId: json['sessionId'] as String,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [playerId, sessionId, timestamp];
}

/// Server sends current game state snapshot to client (response to RequestSync).
class SyncStateMessage extends NetworkMessage {
  final String sessionId;
  final String currentLevelId;
  final Map<String, int> playerScores; // playerId -> xpGained
  final int remainingSeconds;
  final int timestamp;

  const SyncStateMessage({
    required this.sessionId,
    required this.currentLevelId,
    required this.playerScores,
    required this.remainingSeconds,
    required this.timestamp,
  });

  @override
  Map<String, dynamic> toJson() => {
        'type': 'sync_state',
        'sessionId': sessionId,
        'currentLevelId': currentLevelId,
        'playerScores': playerScores,
        'remainingSeconds': remainingSeconds,
        'timestamp': timestamp,
      };

  static SyncStateMessage fromJson(Map<String, dynamic> json) =>
      SyncStateMessage(
        sessionId: json['sessionId'] as String,
        currentLevelId: json['currentLevelId'] as String,
        playerScores: Map<String, int>.from(json['playerScores'] as Map),
        remainingSeconds: json['remainingSeconds'] as int,
        timestamp: json['timestamp'] as int,
      );

  @override
  List<Object?> get props => [
        sessionId,
        currentLevelId,
        playerScores,
        remainingSeconds,
        timestamp,
      ];
}

/// Local play session metadata.
class LocalPlaySession extends Equatable {
  final String id;
  final String hostPlayerId;
  final String? guestPlayerId;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const LocalPlaySession({
    required this.id,
    required this.hostPlayerId,
    this.guestPlayerId,
    required this.createdAt,
    this.expiresAt,
  });

  /// Check if session is still valid (not expired).
  bool get isValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Copy with updated fields.
  LocalPlaySession copyWith({
    String? id,
    String? hostPlayerId,
    String? guestPlayerId,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) =>
      LocalPlaySession(
        id: id ?? this.id,
        hostPlayerId: hostPlayerId ?? this.hostPlayerId,
        guestPlayerId: guestPlayerId ?? this.guestPlayerId,
        createdAt: createdAt ?? this.createdAt,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  @override
  List<Object?> get props =>
      [id, hostPlayerId, guestPlayerId, createdAt, expiresAt];
}

/// Score for a player in the current local session.
class PlayerScore extends Equatable {
  final String playerId;
  final int xpGained;
  final int coinsGained;
  final int starsEarned;
  final List<int> moveHistory; // star counts per level

  const PlayerScore({
    required this.playerId,
    required this.xpGained,
    required this.coinsGained,
    required this.starsEarned,
    required this.moveHistory,
  });

  /// Copy with updated fields.
  PlayerScore copyWith({
    String? playerId,
    int? xpGained,
    int? coinsGained,
    int? starsEarned,
    List<int>? moveHistory,
  }) =>
      PlayerScore(
        playerId: playerId ?? this.playerId,
        xpGained: xpGained ?? this.xpGained,
        coinsGained: coinsGained ?? this.coinsGained,
        starsEarned: starsEarned ?? this.starsEarned,
        moveHistory: moveHistory ?? this.moveHistory,
      );

  @override
  List<Object?> get props =>
      [playerId, xpGained, coinsGained, starsEarned, moveHistory];
}
