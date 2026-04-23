import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../local_session/local_session_provider.dart';
import 'qr_host_screen.dart';
import 'qr_scanner_screen.dart';
import 'local_session_screen.dart';

/// Entry screen for local multiplayer — choose Host or Join.
class LocalPlayModeScreen extends ConsumerWidget {
  const LocalPlayModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(localSessionProvider);

    // If already in an active session, go straight to the session screen.
    if (sessionState.isActive) {
      return const LocalSessionScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Locally'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Text(
              'Local Multiplayer',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Play with friends on the same Wi-Fi network.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _ModeCard(
              icon: Icons.qr_code_rounded,
              title: 'Host a Game',
              subtitle: 'Start a session and let friends scan your QR code.',
              onTap: () => _startHosting(context, ref),
            ),
            const SizedBox(height: 16),
            _ModeCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Join a Game',
              subtitle: 'Scan a QR code or enter a session URL to join.',
              onTap: () => _navigateToScanner(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startHosting(BuildContext context, WidgetRef ref) async {
    final playerId = ref.read(authProvider).maybeWhen(
      data: (id) => id,
      orElse: () => null,
    );
    if (playerId == null || !context.mounted) return;

    await ref
        .read(localSessionProvider.notifier)
        .startHosting(playerId, 'Host');

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const QRHostScreen()),
      );
    }
  }

  void _navigateToScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
