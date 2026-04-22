import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/content_provider.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import 'track_detail_screen.dart';

/// Path-map tab — vertical or horizontal scrollable path of levels with
/// pulsing unlocked nodes. Zooms and centers on the current (highest
/// unlocked) level on entry via [InteractiveViewer].
class WorldMapPathScreen extends ConsumerWidget {
  const WorldMapPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    final tracks = ContentProvider().tracks;
    return progressAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: KineticObsidian.electricCyan)),
      error: (e, _) => Center(
          child: Text('Error loading path',
              style: Theme.of(context).textTheme.bodyMedium)),
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

class _PathViewState extends State<_PathView> with TickerProviderStateMixin {
  final TransformationController _tCtrl = TransformationController();
  late final AnimationController _pulseController;
  late final AnimationController _zoomController;
  Animation<Matrix4>? _zoomAnim;
  bool _orientationIsVertical = true;
  bool _didCenterOnCurrent = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _zoomController = AnimationController(
      vsync: this,
      duration: KineticObsidian.durCelebrate,
    )..addListener(() {
        if (_zoomAnim != null) _tCtrl.value = _zoomAnim!.value;
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _zoomController.dispose();
    _tCtrl.dispose();
    super.dispose();
  }

  int _currentLevelIndexFor(TrackDefinition track) {
    var highest = 0;
    for (int i = 0; i < track.targetLevelCount; i++) {
      final levelId = '${track.id}_$i';
      if ((widget.progress.levelStars[levelId] ?? 0) > 0) {
        highest = i + 1;
      }
    }
    return highest.clamp(0, track.targetLevelCount - 1);
  }

  void _animateTo(Matrix4 target) {
    _zoomAnim = Matrix4Tween(begin: _tCtrl.value, end: target).animate(
      CurvedAnimation(parent: _zoomController, curve: KineticObsidian.easeOut),
    );
    _zoomController.forward(from: 0);
  }

  Matrix4 _matrixCenteredOn(Offset nodeCenter, Size viewportSize) {
    const targetScale = 1.4;
    final dx = viewportSize.width / 2 - nodeCenter.dx * targetScale;
    final dy = viewportSize.height / 2 - nodeCenter.dy * targetScale;
    return Matrix4.identity()
      ..translate(dx, dy)
      ..scale(targetScale);
  }

  @override
  Widget build(BuildContext context) {
    _orientationIsVertical =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final tracks = widget.tracks.take(6).toList();

    return LayoutBuilder(builder: (context, constraints) {
      final viewport = Size(constraints.maxWidth, constraints.maxHeight);
      final focusTrack = tracks.isNotEmpty ? tracks.first : null;
      final currentIndex =
          focusTrack != null ? _currentLevelIndexFor(focusTrack) : 0;

      // Lay out nodes along a zig-zag path. Spacing depends on orientation.
      const nodeDiameter = 72.0;
      const spacing = 120.0;
      final totalCount =
          tracks.fold<int>(0, (sum, t) => sum + t.targetLevelCount);
      final pathLengthAxis = spacing * totalCount + spacing;
      final crossAxis = _orientationIsVertical
          ? constraints.maxWidth
          : constraints.maxHeight;
      final contentWidth =
          _orientationIsVertical ? crossAxis : pathLengthAxis;
      final contentHeight =
          _orientationIsVertical ? pathLengthAxis : crossAxis;

      // Post-frame: zoom to current node once we know its position.
      if (!_didCenterOnCurrent && focusTrack != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final nodeCenter = _positionForIndex(
            trackIndex: 0,
            levelIndex: currentIndex,
            spacing: spacing,
            crossAxis: crossAxis,
            vertical: _orientationIsVertical,
            nodeDiameter: nodeDiameter,
          );
          _animateTo(_matrixCenteredOn(nodeCenter, viewport));
          _didCenterOnCurrent = true;
        });
      }

      return Stack(
        children: [
          InteractiveViewer(
            transformationController: _tCtrl,
            minScale: 0.5,
            maxScale: 2.5,
            boundaryMargin: const EdgeInsets.all(400),
            constrained: false,
            child: SizedBox(
              width: contentWidth,
              height: contentHeight,
              child: Stack(
                children: [
                  // Connector line under everything (soft Aetheric gradient).
                  CustomPaint(
                    size: Size(contentWidth, contentHeight),
                    painter: _PathLinePainter(
                      spacing: spacing,
                      crossAxis: crossAxis,
                      totalCount: totalCount,
                      vertical: _orientationIsVertical,
                      nodeDiameter: nodeDiameter,
                    ),
                  ),
                  for (int t = 0; t < tracks.length; t++)
                    ..._buildNodesForTrack(
                      track: tracks[t],
                      trackIndex: t,
                      priorCount:
                          tracks.take(t).fold<int>(0, (s, x) => s + x.targetLevelCount),
                      spacing: spacing,
                      crossAxis: crossAxis,
                      nodeDiameter: nodeDiameter,
                      currentLevelIndex: t == 0 ? currentIndex : -1,
                    ),
                ],
              ),
            ),
          ),
          // Orientation toggle (floating) — bottom-right.
          Positioned(
            right: KineticObsidian.spaceMd,
            bottom: KineticObsidian.spaceMd,
            child: _OrientationToggle(
              isVertical: _orientationIsVertical,
              onTap: () {
                setState(() {
                  _orientationIsVertical = !_orientationIsVertical;
                  _didCenterOnCurrent = false; // re-center in new orientation
                  _tCtrl.value = Matrix4.identity();
                });
              },
            ),
          ),
        ],
      );
    });
  }

  Offset _positionForIndex({
    required int trackIndex,
    required int levelIndex,
    required double spacing,
    required double crossAxis,
    required bool vertical,
    required double nodeDiameter,
  }) {
    final axisPos = spacing * (levelIndex + 1);
    final zig = (levelIndex.isEven ? 0.18 : 0.82) * crossAxis;
    if (vertical) {
      return Offset(zig, axisPos);
    }
    return Offset(axisPos, zig);
  }

  List<Widget> _buildNodesForTrack({
    required TrackDefinition track,
    required int trackIndex,
    required int priorCount,
    required double spacing,
    required double crossAxis,
    required double nodeDiameter,
    required int currentLevelIndex,
  }) {
    final widgets = <Widget>[];
    for (int i = 0; i < track.targetLevelCount; i++) {
      final overallIndex = priorCount + i;
      final pos = _positionForIndex(
        trackIndex: trackIndex,
        levelIndex: overallIndex,
        spacing: spacing,
        crossAxis: crossAxis,
        vertical: _orientationIsVertical,
        nodeDiameter: nodeDiameter,
      );
      final levelId = '${track.id}_$i';
      final stars = widget.progress.levelStars[levelId] ?? 0;
      final isUnlocked = i == 0 ||
          (widget.progress.levelStars['${track.id}_${i - 1}'] ?? 0) > 0;
      final isCurrent = i == currentLevelIndex;
      widgets.add(Positioned(
        left: pos.dx - nodeDiameter / 2,
        top: pos.dy - nodeDiameter / 2,
        child: _LevelNode(
          diameter: nodeDiameter,
          label: '${i + 1}',
          stars: stars,
          unlocked: isUnlocked,
          current: isCurrent,
          pulseController: _pulseController,
          onTap: isUnlocked
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TrackDetailScreen(track: track),
                    ),
                  );
                }
              : null,
        ),
      ));
    }
    return widgets;
  }
}

class _PathLinePainter extends CustomPainter {
  final double spacing;
  final double crossAxis;
  final int totalCount;
  final bool vertical;
  final double nodeDiameter;

  _PathLinePainter({
    required this.spacing,
    required this.crossAxis,
    required this.totalCount,
    required this.vertical,
    required this.nodeDiameter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalCount == 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = AethericPulse.gradient.createShader(rect)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < totalCount; i++) {
      final axisPos = spacing * (i + 1);
      final zig = (i.isEven ? 0.18 : 0.82) * crossAxis;
      final p = vertical ? Offset(zig, axisPos) : Offset(axisPos, zig);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathLinePainter old) =>
      old.spacing != spacing ||
      old.crossAxis != crossAxis ||
      old.totalCount != totalCount ||
      old.vertical != vertical;
}

class _LevelNode extends StatelessWidget {
  final double diameter;
  final String label;
  final int stars;
  final bool unlocked;
  final bool current;
  final AnimationController pulseController;
  final VoidCallback? onTap;

  const _LevelNode({
    required this.diameter,
    required this.label,
    required this.stars,
    required this.unlocked,
    required this.current,
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fill = unlocked
        ? AethericPulse.gradient
        : const LinearGradient(
            colors: [Color(0xFF2A2D34), Color(0xFF1D2026)],
          );
    final sem = stars > 0
        ? 'Level $label completed with $stars stars'
        : unlocked
            ? 'Level $label, unlocked'
            : 'Level $label, locked';
    final node = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        gradient: fill,
        shape: BoxShape.circle,
        boxShadow: unlocked ? AethericPulse.shadowSoftBlue : null,
        border: Border.all(
          color: unlocked ? Colors.white.withValues(alpha: 0.7) : Colors.white10,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: KineticObsidian.fontDisplay,
              fontFamilyFallback: KineticObsidian.fontFallback,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          if (stars > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < stars.clamp(0, 3); i++)
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 10),
              ],
            ),
        ],
      ),
    );

    Widget pulsed = node;
    if (unlocked) {
      pulsed = ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: current ? 1.08 : 1.03).animate(
          CurvedAnimation(
            parent: pulseController,
            curve: KineticObsidian.easeSnappy,
          ),
        ),
        child: node,
      );
    }

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      label: sem,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: KineticObsidian.minTapTarget,
          minHeight: KineticObsidian.minTapTarget,
        ),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: pulsed,
        ),
      ),
    );
  }
}

class _OrientationToggle extends StatelessWidget {
  final bool isVertical;
  final VoidCallback onTap;
  const _OrientationToggle({required this.isVertical, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = isVertical ? 'Switch to horizontal layout' : 'Switch to vertical layout';
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          borderRadius: KineticObsidian.radiusPillow,
          padding: const EdgeInsets.all(12),
          child: Icon(
            isVertical ? Icons.view_week_rounded : Icons.view_stream_rounded,
            color: KineticObsidian.electricCyan,
            size: 24,
          ),
        ),
      ),
    );
  }
}
