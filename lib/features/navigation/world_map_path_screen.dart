import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/path_constellation.dart';
import 'track_detail_screen.dart';

/// Path-map tab — vertical scrollable S-curve constellation of level nodes,
/// rendered by [PathConstellation]. Scrolls to the current node on first frame.
/// Supports track switching via chips when multiple tracks are available.
class WorldMapPathScreen extends ConsumerWidget {
  const WorldMapPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final tracks = ContentProvider().tracks;
    return progressAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AethericPulseDark.brandBlue),
      ),
      error: (e, _) => Center(
        child: Text(
          'Error loading path',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      data: (progress) => _PathView(progress: progress, tracks: tracks),
    );
  }
}

class _PathView extends StatefulWidget {
  final PlayerProgress progress;
  final List<TrackDefinition> tracks;
  const _PathView({required this.progress, required this.tracks});

  @override
  State<_PathView> createState() => _PathViewState();
}

class _PathViewState extends State<_PathView> {
  int _selectedTrackIndex = 0;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentNode());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TrackDefinition? get _selectedTrack {
    final tracks = widget.tracks;
    if (tracks.isEmpty) return null;
    return tracks[_selectedTrackIndex.clamp(0, tracks.length - 1)];
  }

  /// Returns the 0-based index of the first unstarred level (= the current level).
  int _currentLevelIndex(TrackDefinition track) {
    for (int i = 0; i < track.targetLevelCount; i++) {
      if ((widget.progress.levelStars['${track.id}_$i'] ?? 0) == 0) return i;
    }
    return (track.targetLevelCount - 1).clamp(0, track.targetLevelCount - 1);
  }

  /// Maps per-track levelStars into a [PathLevel] list for [PathConstellation].
  List<PathLevel> _buildLevels(TrackDefinition track) {
    final currentIdx = _currentLevelIndex(track);
    return [
      for (int i = 0; i < track.targetLevelCount; i++)
        PathLevel(
          n: i + 1,
          state: (widget.progress.levelStars['${track.id}_$i'] ?? 0) > 0
              ? PathNodeState.done
              : i == currentIdx
              ? PathNodeState.current
              : PathNodeState.locked,
          type: (i + 1) % 5 == 0 ? PathNodeType.boss : PathNodeType.regular,
        ),
    ];
  }

  void _scrollToCurrentNode() {
    final track = _selectedTrack;
    if (track == null || !_scrollController.hasClients) return;
    try {
      const rowHeight = 84.0;
      final idx = _currentLevelIndex(track);
      final targetY = idx * rowHeight + 40.0;
      final maxExtent = _scrollController.position.maxScrollExtent;
      final viewportHeight = _scrollController.position.viewportDimension;
      final offset = (targetY - viewportHeight / 2).clamp(0.0, maxExtent);
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } catch (_) {
      // Scroll position may not be ready yet — will center on next interaction.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tracks = widget.tracks.take(6).toList();
    final selectedTrack = _selectedTrack;
    final levels = selectedTrack != null
        ? _buildLevels(selectedTrack)
        : <PathLevel>[];

    return Column(
      children: [
        // Track selector chips — shown only when there are multiple tracks.
        if (tracks.length > 1)
          _TrackChips(
            tracks: tracks,
            selectedIndex: _selectedTrackIndex,
            onSelect: (i) {
              setState(() => _selectedTrackIndex = i);
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToCurrentNode(),
              );
            },
          ),
        // PathConstellation in a scrollable view.
        Expanded(
          child: levels.isEmpty
              ? Center(
                  child: Text(
                    'No levels yet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: PathConstellation(
                    levels: levels,
                    onTapLevel: selectedTrack != null
                        ? (_) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TrackDetailScreen(track: selectedTrack),
                            ),
                          )
                        : null,
                  ),
                ),
        ),
      ],
    );
  }
}

class _TrackChips extends StatelessWidget {
  final List<TrackDefinition> tracks;
  final int selectedIndex;
  final void Function(int) onSelect;

  const _TrackChips({
    required this.tracks,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < tracks.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(tracks[i].name),
                selected: selectedIndex == i,
                onSelected: (_) => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}
