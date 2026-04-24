import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../local_session/local_session_provider.dart';

/// QR code host screen for local multiplayer sessions.
/// 
/// Displays:
/// - Large scannable QR code
/// - Session ID
/// - Connected players list
/// - Start Game button (when ready)
/// - Error state handling
class QRHostScreen extends ConsumerWidget {
  const QRHostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(localSessionProvider);
    final isActive = sessionState.phase == LocalSessionPhase.hosting ||
        sessionState.phase == LocalSessionPhase.playing;

    return PopScope(
      canPop: !isActive,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context);
        if (shouldExit && context.mounted) {
          ref.read(localSessionProvider.notifier).endSession();
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Host Multiplayer Session'),
          centerTitle: true,
        ),
        body: _buildBody(context, ref, sessionState),
        floatingActionButton: sessionState.phase == LocalSessionPhase.hosting
            ? FloatingActionButton(
                onPressed: () {
                  ref.read(localSessionProvider.notifier).endSession();
                },
                tooltip: 'End Session',
                child: const Icon(Icons.close),
              )
            : null,
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Game?'),
        content: const Text('Leaving will end the session for all players.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, LocalSessionState state) {
    switch (state.phase) {
      case LocalSessionPhase.idle:
        return _buildIdleState(context);
      case LocalSessionPhase.hosting:
        return _buildHostingState(context, ref, state);
      case LocalSessionPhase.playing:
        return _buildPlayingState(context, state);
      case LocalSessionPhase.error:
        return _buildErrorState(context, ref, state);
      default:
        return _buildIdleState(context);
    }
  }

  Widget _buildIdleState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No active session',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildHostingState(BuildContext context, WidgetRef ref, LocalSessionState state) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // QR Code Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (state.qrUrl != null)
                      QrImageView(
                        data: state.qrUrl!,
                        version: QrVersions.auto,
                        size: 240,
                        embeddedImage: const AssetImage('assets/images/app_icon.png'),
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      )
                    else
                      Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (state.sessionId != null)
                      Column(
                        children: [
                          const Text(
                            'Session ID',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            state.sessionId!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people, size: 20, color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(
                          'Players: ${state.players.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (state.players.isEmpty)
                      const Column(
                        children: [
                          SizedBox(
                            height: 24,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Waiting for players to scan QR code...',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...state.players.values.map((player) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.account_circle,
                                    size: 32,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '★ ${player.stars} | XP ${player.xp}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Button
            if (state.players.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref.read(localSessionProvider.notifier).startGame();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'Start Game',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayingState(BuildContext context, LocalSessionState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.games, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Game in Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.players.length} player${state.players.length != 1 ? 's' : ''} connected',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, LocalSessionState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (state.errorMessage != null)
            Text(
              state.errorMessage!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(localSessionProvider.notifier).resetError();
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
