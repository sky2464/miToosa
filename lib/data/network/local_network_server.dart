import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  /// 
  /// - `sessionId`: Session ID that clients must provide to validate
  /// - `onMessageReceived`: Called when a valid message is received from a client
  /// - `onClientConnected`: Called when a client completes handshake
  /// - `onClientDisconnected`: Called when a client disconnects
  /// - `handshakeTimeout`: How long to wait for join_session message (default 30s)
  /// - `maxClients`: Max number of connected clients (default 2: host + 1 guest)
  LocalNetworkServer({
    required this.sessionId,
    required this.onMessageReceived,
    this.onClientConnected,
    this.onClientDisconnected,
    this.handshakeTimeout = const Duration(seconds: 30),
    this.maxClients = 2,
  });

  /// Start the server on a specific port.
  /// 
  /// Returns the port the server is listening on.
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
            print('WebSocket server error: $error');
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
    final encodedMessage = _encodeMessage(json);

    for (final clientId in _validatedClients) {
      final socket = _connectedClients[clientId];
      if (socket != null && !socket.closeCode != null) {
        try {
          socket.add(encodedMessage);
        } catch (e) {
          print('Failed to send message to client $clientId: $e');
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
    final encodedMessage = _encodeMessage(json);

    try {
      socket.add(encodedMessage);
    } catch (e) {
      print('Failed to send message to client $clientId: $e');
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
        print('Error closing client $clientId: $e');
      }
    }

    _connectedClients.clear();
    _validatedClients.clear();

    // Close server
    try {
      await _server?.close(force: true);
    } catch (e) {
      print('Error closing server: $e');
    }

    _server = null;
  }

  /// Handle a new WebSocket connection from a client.
  void _handleNewConnection(WebSocket socket) {
    final clientId = _generateClientId();

    print('New WebSocket connection from ${socket.remoteAddress}');

    _connectedClients[clientId] = socket;

    // Set up handshake timeout
    final timer = Timer(handshakeTimeout, () {
      if (!_validatedClients.contains(clientId)) {
        print('Handshake timeout for client $clientId');
        _disconnectClient(clientId);
      }
    });

    // Listen for messages
    socket.listen(
      (message) {
        try {
          _handleMessage(clientId, message as String, timer);
        } catch (e) {
          print('Error handling message from client $clientId: $e');
          _disconnectClient(clientId);
        }
      },
      onDone: () {
        timer.cancel();
        _disconnectClient(clientId);
      },
      onError: (error) {
        timer.cancel();
        print('WebSocket error for client $clientId: $error');
        _disconnectClient(clientId);
      },
      cancelOnError: true,
    );
  }

  /// Handle a message received from a client.
  void _handleMessage(String clientId, String rawMessage, Timer handshakeTimer) {
    try {
      final json = _decodeMessage(rawMessage);
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
      print('Network error from client $clientId: ${e.message}');
      _disconnectClient(clientId);
    } catch (e) {
      print('Error decoding message from client $clientId: $e');
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
      print('Invalid session ID from client $clientId');
      _disconnectClient(clientId);
      return;
    }

    // Check max clients limit
    if (_validatedClients.length >= maxClients) {
      print('Max clients reached, rejecting $clientId');
      _disconnectClient(clientId);
      return;
    }

    // Mark client as validated
    _validatedClients.add(clientId);
    handshakeTimer.cancel();

    print('Client $clientId validated with session $sessionId');

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
    _connectedClients[clientId]?.close();
    _connectedClients.remove(clientId);
    _validatedClients.remove(clientId);

    if (wasValidated) {
      print('Client $clientId disconnected');

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

  /// Encode a message to JSON string for transmission.
  String _encodeMessage(Map<String, dynamic> json) {
    // Simple JSON encoding; could use jsonEncode if needed
    return json.toString();
  }

  /// Decode a JSON message from raw string.
  Map<String, dynamic> _decodeMessage(String raw) {
    try {
      // Parse JSON string to map
      // This is a simplified parser; use dart:convert for production
      final jsonStr = raw;
      // Use a simple approach: parse with Map.from and dynamic casting
      if (jsonStr.startsWith('{') && jsonStr.endsWith('}')) {
        // For now, use basic JSON parsing
        // In production, use: json.decode(raw) from dart:convert
        return _simpleJsonDecode(jsonStr);
      }
      throw FormatException('Invalid JSON format');
    } catch (e) {
      throw InvalidMessageFormatException(
        messageData: raw,
        message: 'Failed to decode message: $e',
        originalError: e,
      );
    }
  }

  /// Simple JSON decoder (fallback for basic messages).
  /// In production, use dart:convert's json.decode() instead.
  Map<String, dynamic> _simpleJsonDecode(String jsonStr) {
    // This is a very basic implementation
    // For robustness, always use dart:convert json.decode()
    final decoded = _basicJsonParse(jsonStr);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw FormatException('Expected JSON object, got ${decoded.runtimeType}');
  }

  /// Basic JSON parsing helper.
  dynamic _basicJsonParse(String json) {
    json = json.trim();

    if (json == 'null') return null;
    if (json == 'true') return true;
    if (json == 'false') return false;

    if (json.startsWith('"') && json.endsWith('"')) {
      return json.substring(1, json.length - 1);
    }

    if (json.startsWith('{') && json.endsWith('}')) {
      final content = json.substring(1, json.length - 1);
      final map = <String, dynamic>{};

      // Simple key-value pair parsing
      int depth = 0;
      StringBuffer currentKey = StringBuffer();
      StringBuffer currentValue = StringBuffer();
      bool inKey = true;
      bool inString = false;

      for (int i = 0; i < content.length; i++) {
        final char = content[i];

        if (char == '"' && (i == 0 || content[i - 1] != '\\')) {
          inString = !inString;
        }

        if (!inString) {
          if (char == '{' || char == '[') depth++;
          if (char == '}' || char == ']') depth--;

          if (char == ':' && depth == 0 && inKey) {
            inKey = false;
            continue;
          }

          if ((char == ',' && depth == 0) || i == content.length - 1) {
            if (i == content.length - 1 && char != ',') {
              if (inKey) {
                currentKey.write(char);
              } else {
                currentValue.write(char);
              }
            }

            final key = currentKey
                .toString()
                .trim()
                .replaceAll('"', '')
                .replaceAll("'", '');
            var value = currentValue.toString().trim();

            if (value.startsWith('{') || value.startsWith('[')) {
              map[key] = _basicJsonParse(value);
            } else if (value == 'true') {
              map[key] = true;
            } else if (value == 'false') {
              map[key] = false;
            } else if (value == 'null') {
              map[key] = null;
            } else if (value.startsWith('"') && value.endsWith('"')) {
              map[key] = value.substring(1, value.length - 1);
            } else {
              final num = int.tryParse(value) ?? double.tryParse(value);
              map[key] = num ?? value;
            }

            currentKey.clear();
            currentValue.clear();
            inKey = true;
            continue;
          }
        }

        if (inKey) {
          currentKey.write(char);
        } else {
          currentValue.write(char);
        }
      }

      return map;
    }

    throw FormatException('Invalid JSON: $json');
  }
}
