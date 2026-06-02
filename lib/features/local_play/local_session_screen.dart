import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local_session/local_session_provider.dart';

/// Screen displayed during an active local multiplayer session.
///
/// Shows both players' live scores side-by-side and provides
/// session management controls (end session).
///
/// This screen acts as a session overlay — it displays scoring context
/// while the core puzzle gameplay continues via the existing gameplay
/// view model. When the session ends, it shows a results summary.
class LocalSessionScreen extends ConsumerWidget {
  const LocalSessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(localSessionProvider);
    final isActive = state.phase == LocalSessionPhase.playing;

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
          title: const Text('Local Play'),
          actions: [
            if (state.phase == LocalSessionPhase.playing)
              IconButton(
                onPressed: () =>
                    ref.read(localSessionProvider.notifier).endSession(),
                icon: const Icon(Icons.close_rounded),
                tooltip: 'End Session',
              ),
          ],
        ),
        body: _buildBody(context, ref, state),
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

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    LocalSessionState state,
  ) {
    switch (state.phase) {
      case LocalSessionPhase.playing:
        return _buildPlayingState(context, ref, state);
      case LocalSessionPhase.ended:
        return _buildEndedState(context, ref, state);
      case LocalSessionPhase.error:
        return _buildErrorState(context, ref, state);
      default:
        return _buildIdleState(context);
    }
  }

  Widget _buildPlayingState(
    BuildContext context,
    WidgetRef ref,
    LocalSessionState state,
  ) {
    final players = state.players.values.toList();
    final currentPlayerId = state.currentPlayerId;

    return Column(
      children: [
        // Score panel
        _buildScorePanel(context, players, currentPlayerId),
        const Divider(height: 1),
        // Session info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Session: ${_shortSessionId(state.sessionId)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (state.expiresAt != null)
                Text(
                  _formatExpiry(state.expiresAt!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Gameplay area placeholder
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.sports_esports_rounded,
                  size: 64,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Game in Progress',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${players.length} player${players.length == 1 ? '' : 's'} connected',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        // End session button
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () =>
                ref.read(localSessionProvider.notifier).endSession(),
            icon: const Icon(Icons.stop_circle_outlined),
            label: const Text('End Session'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScorePanel(
    BuildContext context,
    List<LocalSessionPlayer> players,
    String? currentPlayerId,
  ) {
    if (players.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No players connected'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: players.map((player) {
          final isCurrentPlayer = player.playerId == currentPlayerId;
          return Expanded(
            child: _buildPlayerScore(context, player, isCurrentPlayer),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlayerScore(
    BuildContext context,
    LocalSessionPlayer player,
    bool isCurrentPlayer,
  ) {
    return Card(
      color: isCurrentPlayer
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isCurrentPlayer)
              Text(
                'You',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Text(
              player.name,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${player.xp} XP',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              '${player.stars} ★',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndedState(
    BuildContext context,
    WidgetRef ref,
    LocalSessionState state,
  ) {
    final players = state.players.values.toList()
      ..sort((a, b) => b.xp.compareTo(a.xp)); // sort by XP descending

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Session Ended',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Results table
            if (players.isNotEmpty) ...[
              Text('Results', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...players.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final player = entry.value;
                return ListTile(
                  leading: CircleAvatar(child: Text('$rank')),
                  title: Text(player.name),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${player.xp} XP',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${player.stars} ★'),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () =>
                  ref.read(localSessionProvider.notifier).resetError(),
              child: const Text('Return to Menu'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    LocalSessionState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage ?? 'An error occurred during the session.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(localSessionProvider.notifier).resetError(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleState(BuildContext context) {
    return const Center(child: Text('No active session'));
  }

  String _shortSessionId(String? sessionId) {
    if (sessionId == null) return '—';
    return sessionId.length > 12 ? '${sessionId.substring(0, 12)}…' : sessionId;
  }

  String _formatExpiry(DateTime expiresAt) {
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) return 'Expired';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return 'Expires in ${minutes}m ${seconds}s';
  }
}
