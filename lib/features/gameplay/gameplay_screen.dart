import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/gameplay_level.dart';
import '../../core/engine/gameplay_engine.dart';
import '../../core/engine/progression_engine.dart';
import '../../core/models/puzzle.dart';
import '../../core/content_provider.dart';
import '../../widgets/shape_renderer.dart';
import 'game_over_overlay.dart';
import 'session_complete_overlay.dart';
import '../../core/audio_service.dart';
import '../../core/haptics_service.dart';
import '../../core/music_service.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/countdown_timer_widget.dart';
import '../../widgets/hint_button.dart';
import '../../widgets/how_to_play_modal.dart';
import '../../widgets/run_timer_overlay.dart';
import '../auth/auth_provider.dart';
import 'gameplay_view_model.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final TrackDefinition track;
  final int levelIndex;
  /// When true the screen starts a timed run covering [runTotalLevels] levels.
  final bool isRunMode;
  final int runTotalLevels;
  /// Optional difficulty tier selected by the user before entering gameplay.
  final DifficultyTier? initialDifficulty;

  const GameplayScreen({
    super.key,
    required this.track,
    required this.levelIndex,
    this.isRunMode = false,
    this.runTotalLevels = 0,
    this.initialDifficulty,
    this.sessionStartLevelIndex = -1,
    this.sessionXP = 0,
  });

  /// -1 means free-play (no session). ≥0 is the level index where the session started.
  final int sessionStartLevelIndex;
  /// Accumulated XP from earlier puzzles in the current session.
  final int sessionXP;

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with TickerProviderStateMixin {
  late GameplayLevel level;
  bool _animatingTransition = false;
  bool _gameOverActive = false;
  bool _sessionCompleteActive = false;
  int _sessionCompleteXP = 0;
  late AnimationController _entryController;
  late AnimationController _feedbackController;
  late Animation<double> _feedbackScale;
  Timer? _runTimer;
  Timer? _puzzleTimer;
  Duration _runTotalTime = Duration.zero;
  late final AppLifecycleListener _lifecycleListener;

  bool get _inSession => widget.sessionStartLevelIndex >= 0;

  /// 0-based index of the current puzzle within the session.
  int get _sessionPuzzleIndex =>
      _inSession ? widget.levelIndex - widget.sessionStartLevelIndex : 0;

  /// Total number of puzzles in this session (capped at puzzlesPerSession).
  int get _sessionTotalPuzzles => _inSession
      ? min(
          ContentProvider.puzzlesPerSession,
          widget.track.targetLevelCount - widget.sessionStartLevelIndex,
        )
      : 1;

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

    _lifecycleListener = AppLifecycleListener(
      onPause: _onAppPause,
      onResume: _onAppResume,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameplayViewModelProvider(level).notifier).start();
      _entryController.forward();
      if (widget.initialDifficulty != null) {
        ref
            .read(gameplayViewModelProvider(level).notifier)
            .setDifficultyTier(widget.initialDifficulty!);
        _startPuzzleTimer();
      }
      if (widget.isRunMode && widget.runTotalLevels > 0) {
        _runTotalTime = Duration(minutes: widget.runTotalLevels);
        ref
            .read(gameplayViewModelProvider(level).notifier)
            .startRun(widget.runTotalLevels);
        _startRunTimer();
      }
    });
  }

  void _startRunTimer() {
    _runTimer?.cancel();
    _runTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final notifier = ref.read(gameplayViewModelProvider(level).notifier);
      notifier.tickTimer(const Duration(seconds: 1));
      final state = ref.read(gameplayViewModelProvider(level));
      if (!state.isRunActive && state.runTimeRemaining == Duration.zero) {
        _runTimer?.cancel();
        _showTimeUpBanner();
      }
    });
  }

  void _pauseTimer() {
    _runTimer?.cancel();
    ref.read(gameplayViewModelProvider(level).notifier).pausePuzzleTimer();
    _puzzleTimer?.cancel();
  }

  void _resumeTimer() {
    final state = ref.read(gameplayViewModelProvider(level));
    if (state.isRunActive) _startRunTimer();
    if (state.difficultyTier != null) {
      ref.read(gameplayViewModelProvider(level).notifier).resumePuzzleTimer();
      _startPuzzleTimer();
    }
  }

  void _startPuzzleTimer() {
    _puzzleTimer?.cancel();
    _puzzleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final notifier = ref.read(gameplayViewModelProvider(level).notifier);
      final expired = notifier.tickPuzzleTimer();
      if (expired) {
        _puzzleTimer?.cancel();
        HapticsService().heavyImpact();
        AudioService().playErrorBuzzer();
        _feedbackController.forward(from: 0);
        if (_inSession) _handleTimerExpiry();
      }
    });
  }

  Future<void> _handleTimerExpiry() async {
    final playerId = ref.playerId;
    if (playerId == null) return;
    await ref.read(persistenceProvider).deductHeart(playerId);
    ref.invalidate(playerProgressProvider);
    if (!mounted) return;
    final progress = await ref.read(persistenceProvider).loadProgress(playerId);
    if (progress.hearts <= 0) {
      setState(() => _gameOverActive = true);
    } else {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted || _gameOverActive) return;
        final notifier = ref.read(gameplayViewModelProvider(level).notifier);
        notifier.resetPuzzleTimer();
        _startPuzzleTimer();
      });
    }
  }

  void _stopPuzzleTimer() {
    _puzzleTimer?.cancel();
  }

  void _onAppPause() {
    _pauseTimer();
    MusicService().pause();
  }

  void _onAppResume() {
    _resumeTimer();
    MusicService().resume();
  }

  void _showTimeUpBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text("⏰ Time's up!"),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRunBonusBanner() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('FULL RUN! 🔥 +1 💎'),
        backgroundColor: MiToosaTheme.success,
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _awardRunBonusDiamond() async {
    final playerId = ref.playerId;
    if (playerId == null) return;
    await ref.read(persistenceProvider).addDiamond(playerId);
    ref.invalidate(playerProgressProvider);
  }

  @override
  void dispose() {
    _runTimer?.cancel();
    _puzzleTimer?.cancel();
    _lifecycleListener.dispose();
    _entryController.dispose();
    _feedbackController.dispose();
    MusicService().stop();
    super.dispose();
  }

  Future<void> _handleOptionTap(PuzzleOption option, GameplayLevel level) async {
    final state = ref.read(gameplayViewModelProvider(level));
    if (state.phase.isCompleted || _animatingTransition) return;

    final isCorrect = option.id == level.puzzle.correctOptionId;
    if (isCorrect) {
      HapticsService().mediumImpact();
      AudioService().playSuccessPop();
    } else {
      HapticsService().heavyImpact();
      AudioService().playErrorBuzzer();
    }

    ref.read(gameplayViewModelProvider(level).notifier).selectOption(option.id);
    _feedbackController.forward(from: 0);

    if (isCorrect && mounted) {
      // Grace period: pause timer immediately to prevent ticking during transition
      if (widget.initialDifficulty != null) {
        _stopPuzzleTimer();
        ref.read(gameplayViewModelProvider(level).notifier).pausePuzzleTimer();
      }
      await _saveProgress();
      if (widget.isRunMode) {
        final bonus = ref
            .read(gameplayViewModelProvider(level).notifier)
            .completeLevel();
        if (bonus) {
          _showRunBonusBanner();
          await _awardRunBonusDiamond();
        }
      }
      setState(() => _animatingTransition = true);

      // Compute XP earned this puzzle for session accumulation
      final state2 = ref.read(gameplayViewModelProvider(level));
      final stars = level.stars(state2.incorrectAttempts, hintUsed: state2.hintUsed);
      final earnedXP = ProgressionEngine.computeXP(stars, hintUsed: state2.hintUsed);
      final newSessionXP = widget.sessionXP + earnedXP;

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        // Session complete: last puzzle in session
        if (_inSession && _sessionPuzzleIndex + 1 >= _sessionTotalPuzzles) {
          setState(() {
            _sessionCompleteActive = true;
            _sessionCompleteXP = newSessionXP;
          });
          return;
        }
        // Track end (free-play or session end aligns with track end)
        if (widget.levelIndex + 1 >= widget.track.targetLevelCount) {
          Navigator.pop(context);
          return;
        }
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) =>
                GameplayScreen(
                  track: widget.track,
                  levelIndex: widget.levelIndex + 1,
                  isRunMode: widget.isRunMode,
                  runTotalLevels: widget.runTotalLevels,
                  initialDifficulty: widget.initialDifficulty,
                  sessionStartLevelIndex: widget.sessionStartLevelIndex,
                  sessionXP: newSessionXP,
                ),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      });
    }
  }

  Future<void> _useHint(int hearts) async {
    final used = ref
        .read(gameplayViewModelProvider(level).notifier)
        .useHint(hearts: hearts);
    if (!used) return;

    // Deduct heart in persistence
    final playerId = ref.playerId;
    if (playerId != null) {
      await ref.read(persistenceProvider).deductHeart(playerId);
      ref.invalidate(playerProgressProvider);
    }

    // Show hint in bottom sheet
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MiToosaTheme.radiusLg),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(MiToosaTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.lightbulb_rounded,
                  color: MiToosaTheme.warning, size: 22),
              const SizedBox(width: 8),
              Text('Hint',
                  style: Theme.of(context).textTheme.headlineMedium),
            ]),
            const SizedBox(height: MiToosaTheme.spacingMd),
            Text(level.hint ?? '', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: MiToosaTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProgress() async {
    final playerId = ref.playerId;
    if (playerId == null) return;
    final persistence = ref.read(persistenceProvider);
    final levelId = '${widget.track.id}_${widget.levelIndex}';
    final state = ref.read(gameplayViewModelProvider(level));
    final stars = level.stars(state.incorrectAttempts, hintUsed: state.hintUsed);

    // Load progress BEFORE updating level star to detect first-clear
    final progress = await persistence.loadProgress(playerId);
    final previousStars = progress.levelStars[levelId] ?? 0;
    final isFirstClear = previousStars == 0 && stars > 0;

    await persistence.updateLevelStar(playerId, levelId, stars);

    // Update XP using stars-based formula (max 10 XP per level)
    final gainedXP = ProgressionEngine.computeXP(stars, hintUsed: state.hintUsed);
    progress.totalXP = progress.totalXP + gainedXP;

    // v6: record per-level bests
    progress.recordLevelXP(levelId, gainedXP);
    if (widget.initialDifficulty != null) {
      progress.recordLevelDifficulty(levelId, widget.initialDifficulty!.name);
    }
    progress.addDailyXP(gainedXP);

    // Award coins based on stars and first-clear status
    final coinReward = ProgressionEngine.computeCoinReward(
      stars: stars,
      isFirstClear: isFirstClear,
    );
    progress.addCoins(coinReward);

    await persistence.saveProgress(progress);

    // Reward: completing a lower level grants a heart refuel
    final completedCount = progress.levelStars.values
        .where((s) => s > 0)
        .length;
    if (ProgressionEngine.isLowerLevel(widget.levelIndex, completedCount)) {
      await persistence.refuelHeartLowerLevel(playerId);
    }

    // Refresh global progress provider so UI (world map / header) shows updated XP
    ref.invalidate(playerProgressProvider);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameplayViewModelProvider(level));
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                  // ─── Run timer bar ─────────────────────────────
                  if (widget.isRunMode)
                    RunTimerOverlay(
                      timeRemaining: state.runTimeRemaining,
                      totalTime: _runTotalTime,
                    ),
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
          // ─── Game over overlay ───────────────────────────
          if (_gameOverActive)
            GameOverOverlay(
              puzzlesCompleted: _sessionPuzzleIndex,
              sessionTotalPuzzles: _sessionTotalPuzzles,
              sessionXP: widget.sessionXP,
              onRetry: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameplayScreen(
                      track: widget.track,
                      levelIndex: widget.sessionStartLevelIndex,
                      initialDifficulty: widget.initialDifficulty,
                      sessionStartLevelIndex: widget.sessionStartLevelIndex,
                      sessionXP: 0,
                    ),
                  ),
                );
              },
              onBackToTrack: () => Navigator.pop(context),
            ),
          // ─── Session complete overlay ─────────────────────
          if (_sessionCompleteActive)
            SessionCompleteOverlay(
              puzzlesCompleted: _sessionTotalPuzzles,
              sessionXP: _sessionCompleteXP,
              hasNextLevel:
                  widget.levelIndex + 1 < widget.track.targetLevelCount,
              onNextLevel: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameplayScreen(
                      track: widget.track,
                      levelIndex: widget.levelIndex + 1,
                    ),
                  ),
                );
              },
              onBackToTrack: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GameplayLevel level, GameplayState eng) {
    final theme = Theme.of(context);
    final maxLevels = widget.track.targetLevelCount;
    final progress = (widget.levelIndex + 1) / maxLevels;
    final progressAsync = ref.watch(playerProgressProvider);
    final hearts = progressAsync.maybeWhen(
      data: (p) => p.hearts,
      orElse: () => 5,
    );

    // Live XP potential (decreases with wrong answers / hint)
    final liveStars =
        level.stars(eng.incorrectAttempts, hintUsed: eng.hintUsed);
    final liveXP =
        ProgressionEngine.computeXP(liveStars, hintUsed: eng.hintUsed)
            .clamp(1, 10);

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
                    if (_inSession)
                      Text(
                        'Puzzle ${_sessionPuzzleIndex + 1} / $_sessionTotalPuzzles',
                        style: theme.textTheme.headlineMedium,
                      )
                    else
                      Text(
                        'Level ${widget.levelIndex + 1}',
                        style: theme.textTheme.headlineMedium,
                      ),
                  ],
                ),
              ),
              // Hint button
              HintButton(
                hint: level.hint,
                hearts: hearts,
                hintUsed: eng.hintUsed,
                onUseHint: () => _useHint(hearts),
                onNoHearts: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Not enough hearts – use a 💎 or play a lower level',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Puzzle countdown timer (visible when difficulty tier is set)
              if (eng.difficultyTier != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CountdownTimerWidget(
                    remainingSeconds: eng.puzzleTimeRemaining,
                    totalSeconds: eng.difficultyTier!.seconds,
                    size: 38,
                  ),
                ),
              // Live XP potential (visible when in difficulty session)
              if (eng.difficultyTier != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: liveXP >= 8
                          ? MiToosaTheme.success.withValues(alpha: 0.12)
                          : liveXP >= 5
                              ? MiToosaTheme.warning.withValues(alpha: 0.12)
                              : MiToosaTheme.error.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(MiToosaTheme.radiusSm),
                    ),
                    child: Text(
                      '$liveXP XP',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: liveXP >= 8
                            ? MiToosaTheme.success
                            : liveXP >= 5
                                ? MiToosaTheme.warning
                                : MiToosaTheme.error,
                      ),
                    ),
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
              const SizedBox(width: 4),
              // Reopen how-to-play
              IconButton(
                key: const ValueKey('how_to_play_reopen'),
                onPressed: () => HowToPlayModal.show(
                  context,
                  track: widget.track,
                  onStart: () => Navigator.of(context).pop(),
                ),
                icon: Icon(Icons.help_outline_rounded,
                    color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    size: 22),
                tooltip: 'How to play',
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
          boxShadow: MiToosaTheme.shadowElevated,
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
              )
            else
              ...MiToosaTheme.shadowCard,
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

    final stars = eng.level.stars(eng.incorrectAttempts, hintUsed: eng.hintUsed);

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
        boxShadow: MiToosaTheme.shadowSubtle,
      ),
      child: Row(
        children: [
          // Stars
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: i < stars ? MiToosaTheme.warning : theme.colorScheme.primary.withValues(alpha: 0.2),
                size: 32,
              );
            }),
          ),
          const Spacer(),
          // XP (stars-based, max 10)
          Text(
            '+${ProgressionEngine.computeXP(stars, hintUsed: eng.hintUsed)} XP',
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

