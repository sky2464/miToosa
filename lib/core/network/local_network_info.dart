import 'dart:io';

import '../../data/network/network_exceptions.dart';

/// Utilities for local network discovery and port management.
class LocalNetworkInfo {
  /// Detects the device's local IP address on the home network.
  /// 
  /// Returns an IPv4 address like "192.168.1.100" if available,
  /// otherwise falls back to "127.0.0.1" (localhost) for testing.
  static Future<String> getLocalIP() async {
    try {
      final interfaces = await NetworkInterface.list();
      for (final interface in interfaces) {
        // Look for IPv4 addresses on active interfaces
        for (final addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            // Prefer private addresses (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
            if (_isPrivateIP(addr.address)) {
              return addr.address;
            }
          }
        }
      }
    } catch (e) {
      // Fallback: use localhost for testing or if WiFi is unavailable
    }
    
    // Fallback: return localhost
    return '127.0.0.1';
  }

  /// Check if an IP address is a private address.
  static bool _isPrivateIP(String ip) {
    if (ip.startsWith('192.168.')) return true;
    if (ip.startsWith('10.')) return true;
    if (ip.startsWith('172.')) {
      final parts = ip.split('.');
      if (parts.length == 4) {
        final second = int.tryParse(parts[1]);
        // Check if in range 172.16-31.x.x
        if (second != null && second >= 16 && second <= 31) {
          return true;
        }
      }
    }
    return false;
  }

  /// Checks if a specific port is available (not in use).
  /// 
  /// Attempts to bind to the port; if successful, port is available.
  /// This is a best-effort check; there's still a race condition
  /// between check and actual bind.
  static Future<bool> isPortAvailable(int port) async {
    try {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, port);
      await server.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Finds the first available port in the given range.
  ///
  /// Starts at `startPort` and increments until `endPort`.
  /// Throws `PortBindingException` if no port is available.
  static Future<int> findAvailablePort({
    int startPort = 8765,
    int endPort = 8775,
  }) async {
    for (int port = startPort; port <= endPort; port++) {
      if (await isPortAvailable(port)) {
        return port;
      }
    }
    
    throw PortBindingException(
      port: startPort,
      message: 'No available port found in range $startPort-$endPort',
    );
  }

  /// Returns the URL for a WebSocket server on the local network.
  /// 
  /// Format: `ws://192.168.1.100:8765?session=<sessionId>&playerId=<playerId>`
  static Future<String> generateWebSocketURL({
    required int port,
    required String sessionId,
    required String playerId,
  }) async {
    final localIP = await getLocalIP();
    return 'ws://$localIP:$port?session=$sessionId&playerId=$playerId';
  }
}
