import 'package:flutter/material.dart';

import '../core/content_provider.dart';
import '../core/tutorial/tutorial_definition.dart';
import '../theme/design_system.dart';
import 'tutorial/tutorial_demo_panel.dart';

/// Full-screen overlay for interactive how-to demos (BL-24).
class HowToPlayModal extends StatefulWidget {
  final TrackDefinition track;
  final TutorialDefinition tutorial;
  final VoidCallback onStart;

  /// Help reopen from gameplay — practice optional, does not persist seen state.
  final bool helpMode;

  const HowToPlayModal({
    super.key,
    required this.track,
    required this.tutorial,
    required this.onStart,
    this.helpMode = false,
  });

  static Future<void> show(
    BuildContext context, {
    required TrackDefinition track,
    required TutorialDefinition tutorial,
    required VoidCallback onStart,
    bool helpMode = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => HowToPlayModal(
        track: track,
        tutorial: tutorial,
        onStart: onStart,
        helpMode: helpMode,
      ),
    );
  }

  @override
  State<HowToPlayModal> createState() => _HowToPlayModalState();
}

class _HowToPlayModalState extends State<HowToPlayModal> {
  bool _practiceOk = false;

  @override
  void initState() {
    super.initState();
    _practiceOk = widget.helpMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconAsset = ContentProvider().iconAssetForTrack(widget.track);
    final ctaEnabled = _practiceOk;

    return Dialog(
      key: const ValueKey('how_to_play_modal'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MiToosaTheme.radiusXl),
      ),
      backgroundColor: theme.colorScheme.surface,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MiToosaTheme.spacingLg,
            vertical: MiToosaTheme.spacingXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(iconAsset, width: 40, height: 40),
                ),
              ),
              const SizedBox(height: MiToosaTheme.spacingMd),
              Text(
                widget.track.name,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MiToosaTheme.spacingSm),
              Text(
                widget.tutorial.goal,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: MiToosaTheme.spacingLg),
              TutorialDemoPanel(
                definition: widget.tutorial,
                requireSuccessBeforeContinue: !widget.helpMode,
                onPracticeComplete: (ok) {
                  if (ok) setState(() => _practiceOk = true);
                },
              ),
              const SizedBox(height: MiToosaTheme.spacingXl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  key: const ValueKey('how_to_play_cta'),
                  onPressed: ctaEnabled ? widget.onStart : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: MiToosaTheme.spacingMd,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MiToosaTheme.radiusMd,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.helpMode ? 'Back to game' : "Let's Go! 🚀",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
