import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/gameplay_level.dart';
import '../../core/engine/gameplay_engine.dart';
import '../../core/models/puzzle.dart';
import '../../core/models/shape_item.dart';
import '../../core/content_provider.dart';
import '../../core/audio_service.dart';
import '../../data/hive_persistence_provider.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../auth/auth_provider.dart';
import 'gameplay_view_model.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final TrackDefinition track;
  final int levelIndex;

  const GameplayScreen({
    super.key,
    required this.track,
    required this.levelIndex,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with TickerProviderStateMixin {
  late GameplayLevel level;
  bool _animatingTransition = false;
  late AnimationController _entryController;
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScale;

  @override
  void initState() {
    super.initState();
    level = ContentProvider().buildLevelForTrack(widget.track, widget.levelIndex);

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _feedbackScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameplayViewModelProvider(level).notifier).start();
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _handleOptionTap(PuzzleOption option, GameplayLevel level) {
    final state = ref.read(gameplayViewModelProvider(level));
    if (state.phase.isCompleted || _animatingTransition) return;

    final isCorrect = option.id == level.puzzle.correctOptionId;
    HapticFeedback.mediumImpact();
    if (isCorrect) {
      AudioService().playSuccessPop();
    } else {
      AudioService().playErrorBuzzer();
    }

    ref.read(gameplayViewModelProvider(level).notifier).selectOption(option.id);
    _feedbackController.forward(from: 0);

    if (isCorrect && mounted) {
      _saveProgress();
      setState(() => _animatingTransition = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) =>
                GameplayScreen(track: widget.track, levelIndex: widget.levelIndex + 1),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      });
    }
  }

  Future<void> _saveProgress() async {
    final playerId = ref.read(authProvider).maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );
    if (playerId == null) return;
    final persistence = HivePersistenceProvider();
    final levelId = '${widget.track.id}_${widget.levelIndex}';
    final state = ref.read(gameplayViewModelProvider(level));
    final stars = level.stars(state.incorrectAttempts);
    await persistence.updateLevelStar(playerId, levelId, stars);

    // Update XP
    final progress = await persistence.loadProgress(playerId);
    final gainedXP = state.score.toInt();
    progress.totalXP = progress.totalXP + gainedXP;
    await persistence.saveProgress(progress);

    // Refresh global progress provider so UI (world map / header) shows updated XP
    ref.invalidate(playerProgressProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameplayViewModelProvider(level));
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ─── Header ──────────────────────────────────
              _buildHeader(context, level, state),
              // ─── Scrollable Content ──────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MiToosaTheme.spacingLg,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: MiToosaTheme.spacingMd),
                      // Prompt
                      Text(
                        level.puzzle.prompt,
                        style: theme.textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: MiToosaTheme.spacingLg),
                      // Target shapes
                      _buildTargetArea(context, level),
                      const SizedBox(height: MiToosaTheme.spacingMd),
                      // Feedback
                      if (state.feedback != null)
                        ScaleTransition(
                          scale: _feedbackScale,
                          child: _buildFeedback(context, state),
                        ),
                      const SizedBox(height: MiToosaTheme.spacingLg),
                      // Options
                      _buildOptions(context, level, state, screenWidth),
                      const SizedBox(height: MiToosaTheme.spacingXxl),
                    ],
                  ),
                ),
              ),
              // ─── Footer ─────────────────────────────────
              _buildFooter(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameplayLevel level, GameplayState eng) {
    final theme = Theme.of(context);
    final maxLevels = widget.track.targetLevelCount;
    final progress = (widget.levelIndex + 1) / maxLevels;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        MiToosaTheme.spacingSm, MiToosaTheme.spacingSm,
        MiToosaTheme.spacingMd, 0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: theme.colorScheme.primary, size: 22),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.track.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      'Level ${widget.levelIndex + 1}',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
              // Score badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MiToosaTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 18, color: theme.colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '${eng.score}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: MiToosaTheme.spacingSm),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetArea(BuildContext context, GameplayLevel level) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _entryController.value),
          child: Opacity(
            opacity: _entryController.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(MiToosaTheme.radiusXl),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: MiToosaTheme.spacingMd,
          runSpacing: MiToosaTheme.spacingMd,
          children: level.puzzle.targetItems
              .map((item) => ShapeRenderer(item: item, size: 44))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFeedback(BuildContext context, GameplayState eng) {
    final theme = Theme.of(context);
    final isCompleted = eng.phase.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MiToosaTheme.spacingLg,
        vertical: MiToosaTheme.spacingMd,
      ),
      decoration: BoxDecoration(
        color: (isCompleted ? MiToosaTheme.success : MiToosaTheme.warning)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.celebration_rounded : Icons.replay_rounded,
            color: isCompleted ? MiToosaTheme.success : MiToosaTheme.warning,
          ),
          const SizedBox(width: MiToosaTheme.spacingSm),
          Flexible(
            child: Text(
              eng.feedback!.message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isCompleted ? MiToosaTheme.success : MiToosaTheme.warning,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(
    BuildContext context, GameplayLevel level, GameplayState eng, double screenWidth,
  ) {
    final options = level.puzzle.options;
    final isTextBased = options.any((o) => o.label != null);

    if (isTextBased) {
      return _buildTextOptions(context, level, eng, options);
    }

    return Wrap(
      spacing: MiToosaTheme.spacingMd,
      runSpacing: MiToosaTheme.spacingMd,
      alignment: WrapAlignment.center,
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return _buildOptionCard(context, option, level, eng, index, screenWidth);
      }).toList(),
    );
  }

  Widget _buildTextOptions(
    BuildContext context, GameplayLevel level, GameplayState eng, List<PuzzleOption> options,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: options.asMap().entries.map((entry) {
        final option = entry.value;
        final isSelected = eng.selectedOptionId == option.id;
        final isCorrect = option.id == level.puzzle.correctOptionId;
        final isCompleted = eng.phase.isCompleted;

        Color bgColor = theme.colorScheme.surface;
        Color borderColor = theme.colorScheme.primary.withValues(alpha: 0.1);

        if (isCompleted && isCorrect) {
          bgColor = MiToosaTheme.success.withValues(alpha: 0.12);
          borderColor = MiToosaTheme.success;
        } else if (isCompleted && isSelected && !isCorrect) {
          bgColor = MiToosaTheme.error.withValues(alpha: 0.12);
          borderColor = MiToosaTheme.error;
        } else if (isSelected) {
          borderColor = theme.colorScheme.primary;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: MiToosaTheme.spacingSm),
          child: GestureDetector(
            onTap: () => _handleOptionTap(option, level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: MiToosaTheme.spacingLg,
                vertical: MiToosaTheme.spacingMd,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
                border: Border.all(color: borderColor, width: 2.5),
              ),
              child: Center(
                child: Text(
                  option.label ?? '',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    PuzzleOption option,
    GameplayLevel level,
    GameplayState eng,
    int index,
    double screenWidth,
  ) {
    final theme = Theme.of(context);
    final isSelected = eng.selectedOptionId == option.id;
    final isCorrect = option.id == level.puzzle.correctOptionId;
    final isCompleted = eng.phase.isCompleted;

    Color borderColor = theme.colorScheme.primary.withValues(alpha: 0.08);
    Color bgColor = theme.colorScheme.surface;

    if (isCompleted && isCorrect) {
      borderColor = MiToosaTheme.success;
      bgColor = MiToosaTheme.success.withValues(alpha: 0.08);
    } else if (isCompleted && isSelected && !isCorrect) {
      borderColor = MiToosaTheme.error;
      bgColor = MiToosaTheme.error.withValues(alpha: 0.08);
    } else if (isSelected && !isCompleted) {
      borderColor = theme.colorScheme.primary;
    }

    final cardWidth = (screenWidth - MiToosaTheme.spacingLg * 2 - MiToosaTheme.spacingMd) / 2;

    return GestureDetector(
      onTap: () => _handleOptionTap(option, level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: cardWidth.clamp(120.0, 200.0),
        transform: Matrix4.diagonal3Values(
          isSelected ? 0.96 : 1.0,
          isSelected ? 0.96 : 1.0,
          1.0,
        ),
        padding: const EdgeInsets.all(MiToosaTheme.spacingMd),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(MiToosaTheme.radiusLg),
          border: Border.all(color: borderColor, width: 3),
          boxShadow: [
            if (borderColor != theme.colorScheme.primary.withValues(alpha: 0.08))
              BoxShadow(
                color: borderColor.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: option.items
              .map((item) => ShapeRenderer(item: item, size: 28))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, GameplayState eng) {
    final theme = Theme.of(context);
    if (!eng.phase.isCompleted) return const SizedBox.shrink();

    final stars = eng.level.stars(eng.incorrectAttempts);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        MiToosaTheme.spacingLg, MiToosaTheme.spacingMd,
        MiToosaTheme.spacingLg, MiToosaTheme.spacingLg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(MiToosaTheme.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stars
          Row(
            children: List.generate(3, (i) {
              return Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < stars ? MiToosaTheme.warning : theme.colorScheme.primary.withValues(alpha: 0.2),
                size: 32,
              );
            }),
          ),
          const Spacer(),
          // Score
          Text(
            '+${eng.score} XP',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ShapeRenderer (CustomPainter-based) ─────────────────────

class ShapeRenderer extends StatelessWidget {
  final ShapeItem item;
  final double size;

  const ShapeRenderer({super.key, required this.item, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ShapePainter(item: item),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final ShapeItem item;

  _ShapePainter({required this.item});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = item.color.value
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    switch (item.fill) {
      case ShapeFill.filled:
        paint.style = PaintingStyle.fill;
        break;
      case ShapeFill.outlined:
        paint.style = PaintingStyle.stroke;
        break;
      case ShapeFill.striped:
        paint.style = PaintingStyle.fill;
        break;
    }

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;

    switch (item.shape) {
      case Shape.circle:
        canvas.drawCircle(Offset(cx, cy), r, paint);
        if (item.fill == ShapeFill.striped) {
          _drawStripes(canvas, size, paint);
        }
        break;

      case Shape.square:
        final rr = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: r * 1.8, height: r * 1.8),
          Radius.circular(r * 0.2),
        );
        canvas.drawRRect(rr, paint);
        break;

      case Shape.triangle:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy + r * 0.8)
          ..lineTo(cx - r, cy + r * 0.8)
          ..close();
        canvas.drawPath(path, paint);
        break;

      case Shape.star:
        canvas.drawPath(_starPath(cx, cy, r, 5), paint);
        break;

      case Shape.hexagon:
        canvas.drawPath(_polygonPath(cx, cy, r, 6), paint);
        break;

      case Shape.diamond:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.7, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.7, cy)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  Path _starPath(double cx, double cy, double r, int points) {
    final path = Path();
    final innerR = r * 0.4;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? r : innerR;
      final angle = (pi / 2 * -1) + (i * pi / points);
      final x = cx + radius * cos(angle);
      final y = cy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  Path _polygonPath(double cx, double cy, double r, int sides) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (pi / 2 * -1) + (i * 2 * pi / sides);
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawStripes(Canvas canvas, Size size, Paint paint) {
    final stripePaint = Paint()
      ..color = paint.color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (double y = 3; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), stripePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) => old.item != item;
}
