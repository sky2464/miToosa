import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../data/network/network_exceptions.dart';
import '../../data/network/network_models.dart';

typedef OnMessageReceived = void Function(NetworkMessage message, String clientId);
typedef OnClientConnected = void Function(String clientId);
typedef OnClientDisconnected = void Function(String clientId);

/// WebSocket server for host device managing multiplayer session connections.
/// 
/// Responsibilities:
/// - Accept client connections on a specified port
/// - Validate clients via handshake (join_session message with matching sessionId)
/// - Broadcast messages to all connected clients
/// - Handle client disconnections and cleanup
/// - Graceful shutdown
class LocalNetworkServer {
  final String sessionId;
  final OnMessageReceived onMessageReceived;
  final OnClientConnected? onClientConnected;
  final OnClientDisconnected? onClientDisconnected;
  final Duration handshakeTimeout;
  final int maxClients;

  HttpServer? _server;
  final Map<String, WebSocket> _connectedClients = {};
  final Set<String> _validatedClients = {};
  bool _isRunning = false;

  /// Create a new WebSocket server for local network play.
  LocalNetworkServer({
    required this.sessionId,
    required this.onMessageReceived,
    this.onClientConnected,
    this.onClientDisconnected,
    this.handshakeTimeout = const Duration(seconds: 30),
    this.maxClients = 2,
  });

  /// Start the server on a specific port.
  Future<int> start(int port) async {
    if (_isRunning) {
      throw StateError('Server is already running');
    }

    try {
      _server = await HttpServer.bind('0.0.0.0', port);
      _isRunning = true;

      _server!.transform(WebSocketTransformer()).listen(
        _handleNewConnection,
        onError: (error) {
          if (_isRunning) {
            debugPrint('WebSocket server error: $error');
          }
        },
        cancelOnError: false,
      );

      return _server!.port;
    } catch (e) {
      throw PortBindingException(
        port: port,
        message: 'Failed to bind server to port $port',
        originalError: e,
      );
    }
  }

  /// Broadcast a message to all connected and validated clients.
  void broadcast(NetworkMessage message) {
    if (!_isRunning) {
      throw StateError('Server is not running');
    }

    final json = message.toJson();
    final encodedMessage = jsonEncode(json);

    for (final clientId in _validatedClients) {
      final socket = _connectedClients[clientId];
      if (socket != null && socket.closeCode == null) {
        try {
          socket.add(encodedMessage);
        } catch (e) {
          debugPrint('Failed to send message to client $clientId: $e');
        }
      }
    }
  }

  /// Send a message to a specific client.
  void sendToClient(String clientId, NetworkMessage message) {
    if (!_isRunning) {
      throw StateError('Server is not running');
    }

    final socket = _connectedClients[clientId];
    if (socket == null) {
      throw StateError('Client $clientId not found');
    }

    final json = message.toJson();
    final encodedMessage = jsonEncode(json);

    try {
      socket.add(encodedMessage);
    } catch (e) {
      debugPrint('Failed to send message to client $clientId: $e');
    }
  }

  /// Get list of connected client IDs (after handshake validation).
  List<String> getConnectedClientIds() => List.from(_validatedClients);

  /// Check if a client is connected and validated.
  bool isClientConnected(String clientId) => _validatedClients.contains(clientId);

  /// Stop the server and close all connections.
  Future<void> stop() async {
    if (!_isRunning) return;

    _isRunning = false;

    // Close all client connections
    for (final clientId in _connectedClients.keys.toList()) {
      try {
        await _connectedClients[clientId]?.close();
      } catch (e) {
        debugPrint('Error closing client $clientId: $e');
      }
    }

    _connectedClients.clear();
    _validatedClients.clear();

    // Close server
    try {
      await _server?.close(force: true);
    } catch (e) {
      debugPrint('Error closing server: $e');
    }

    _server = null;
  }

  /// Handle a new WebSocket connection from a client.
  void _handleNewConnection(WebSocket socket) {
    final clientId = _generateClientId();

    debugPrint('New WebSocket connection: $clientId');

    _connectedClients[clientId] = socket;

    // Set up handshake timeout
    final timer = Timer(handshakeTimeout, () {
      if (!_validatedClients.contains(clientId)) {
        debugPrint('Handshake timeout for client $clientId');
        _disconnectClient(clientId);
      }
    });

    // Listen for messages
    socket.listen(
      (message) {
        try {
          _handleMessage(clientId, message as String, timer);
        } catch (e) {
          debugPrint('Error handling message from client $clientId: $e');
          _disconnectClient(clientId);
        }
      },
      onDone: () {
        timer.cancel();
        _disconnectClient(clientId);
      },
      onError: (error) {
        timer.cancel();
        debugPrint('WebSocket error for client $clientId: $error');
        _disconnectClient(clientId);
      },
      cancelOnError: true,
    );
  }

  /// Handle a message received from a client.
  void _handleMessage(String clientId, String rawMessage, Timer handshakeTimer) {
    try {
      final json = jsonDecode(rawMessage);
      if (json is! Map<String, dynamic>) {
        throw InvalidMessageFormatException(
          messageData: rawMessage,
          message: 'Expected JSON object at root',
        );
      }

      final message = NetworkMessage.fromJson(json);

      // Handle handshake for non-validated clients
      if (!_validatedClients.contains(clientId)) {
        if (message is JoinSessionMessage) {
          _handleJoinSessionMessage(clientId, message, handshakeTimer);
          return;
        } else {
          // Client must send join_session first
          throw InvalidSessionException(
            sessionId: sessionId,
            message: 'Client must send join_session before other messages',
          );
        }
      }

      // Pass validated messages to the callback
      onMessageReceived(message, clientId);
    } on NetworkException catch (e) {
      debugPrint('Network error from client $clientId: ${e.message}');
      _disconnectClient(clientId);
    } catch (e) {
      debugPrint('Error processing message from client $clientId: $e');
      _disconnectClient(clientId);
    }
  }

  /// Handle join_session handshake message.
  void _handleJoinSessionMessage(
    String clientId,
    JoinSessionMessage message,
    Timer handshakeTimer,
  ) {
    // Validate session ID
    if (message.sessionId != sessionId) {
      debugPrint('Invalid session ID from client $clientId');
      _disconnectClient(clientId);
      return;
    }

    // Check max clients limit
    if (_validatedClients.length >= maxClients) {
      debugPrint('Max clients reached, rejecting $clientId');
      _disconnectClient(clientId);
      return;
    }

    // Mark client as validated
    _validatedClients.add(clientId);
    handshakeTimer.cancel();

    debugPrint('Client $clientId validated with session $sessionId');

    // Send acknowledgment
    final ack = JoinSessionAckMessage(
      sessionId: sessionId,
      connectedPlayers: List.from(_validatedClients),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    sendToClient(clientId, ack);

    // Notify callback
    onClientConnected?.call(clientId);

    // Broadcast to other clients that a new player connected
    broadcast(
      PlayerConnectedMessage(
        sessionId: sessionId,
        playerId: message.playerId,
        playerName: 'Player ${_validatedClients.length}',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Disconnect a client and clean up.
  void _disconnectClient(String clientId) {
    final wasValidated = _validatedClients.contains(clientId);

    // Close socket
    try {
      _connectedClients[clientId]?.close();
    } catch (e) {
      debugPrint('Error closing socket for $clientId: $e');
    }

    _connectedClients.remove(clientId);
    _validatedClients.remove(clientId);

    if (wasValidated) {
      debugPrint('Client $clientId disconnected');

      // Notify callback
      onClientDisconnected?.call(clientId);

      // Broadcast disconnection to remaining clients
      if (_isRunning && _validatedClients.isNotEmpty) {
        broadcast(
          PlayerDisconnectedMessage(
            sessionId: sessionId,
            playerId: clientId,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  /// Generate a unique client ID.
  String _generateClientId() {
    return 'client-${DateTime.now().millisecondsSinceEpoch}-${_connectedClients.length}';
  }
}
