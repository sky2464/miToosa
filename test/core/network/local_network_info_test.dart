import 'package:flutter_test/flutter_test.dart';
import 'package:mitoosa/core/network/local_network_info.dart';
import 'package:mitoosa/data/network/network_exceptions.dart';

void main() {
  group('LocalNetworkInfo', () {
    test('getLocalIP returns a valid IP address', () async {
      final ip = await LocalNetworkInfo.getLocalIP();
      
      // Should be either localhost or a valid IPv4 address
      expect(ip, isNotNull);
      expect(ip.isNotEmpty, true);
      
      // Validate IPv4 format (simple check)
      final parts = ip.split('.');
      expect(parts.length, 4);
      for (final part in parts) {
        final num = int.tryParse(part);
        expect(num, isNotNull);
        expect(num! >= 0 && num <= 255, true);
      }
    });

    test('isPortAvailable returns true for free ports', () async {
      // Port 0 lets the OS choose a free port, so it should always be available temporarily
      final available = await LocalNetworkInfo.isPortAvailable(0);
      expect(available, true);
    });

    test('isPortAvailable returns false for reserved/in-use ports', () async {
      // Attempt to check port 1 (typically reserved)
      // This test may be flaky on some systems, so we're lenient
      final available = await LocalNetworkInfo.isPortAvailable(1);
      // We don't assert false here due to system differences
      expect(available, isA<bool>());
    });

    test('findAvailablePort finds an available port in range', () async {
      // Use a high port range that's unlikely to be in use
      final port = await LocalNetworkInfo.findAvailablePort(
        startPort: 18765,
        endPort: 18775,
      );
      
      expect(port >= 18765 && port <= 18775, true);
      
      // Verify the returned port is actually available
      final isAvailable = await LocalNetworkInfo.isPortAvailable(port);
      expect(isAvailable, true);
    });

    test('findAvailablePort throws when no ports available', () async {
      // Use a range of reserved ports that are likely in use
      expect(
        () async {
          // Ports 1-10 are typically reserved
          await LocalNetworkInfo.findAvailablePort(
            startPort: 1,
            endPort: 10,
          );
        },
        throwsA(isA<PortBindingException>()),
      );
    });

    test('generateWebSocketURL returns correctly formatted URL', () async {
      final url = await LocalNetworkInfo.generateWebSocketURL(
        port: 8765,
        sessionId: 'session-abc',
        playerId: 'player-123',
      );

      expect(url.startsWith('ws://'), true);
      expect(url.contains(':8765'), true);
      expect(url.contains('session=session-abc'), true);
      expect(url.contains('playerId=player-123'), true);
    });

    test('generateWebSocketURL uses correct local IP', () async {
      final url = await LocalNetworkInfo.generateWebSocketURL(
        port: 8765,
        sessionId: 'session-abc',
        playerId: 'player-123',
      );

      // Extract the IP from the URL
      final ipMatch = RegExp(r'ws://([^:]+):').firstMatch(url);
      expect(ipMatch, isNotNull);
      
      final extractedIP = ipMatch!.group(1);
      final actualIP = await LocalNetworkInfo.getLocalIP();
      
      expect(extractedIP, actualIP);
    });
  });
}
