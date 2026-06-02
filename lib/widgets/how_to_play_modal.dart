import 'package:flutter/material.dart';
import '../theme/design_system.dart';
import '../core/content_provider.dart';

/// Full-screen overlay shown the first time a player enters a world.
///
/// Displays the world [icon], [name], [subtitle] as the rule description,
/// and a CTA to start playing. The caller is responsible for recording the
/// world as seen (via [onStart]) and navigating to gameplay.
class HowToPlayModal extends StatelessWidget {
  final TrackDefinition track;

  /// Called when the player taps the CTA. Dismiss and navigate from here.
  final VoidCallback onStart;

  const HowToPlayModal({super.key, required this.track, required this.onStart});

  /// Shows this modal over the given [context] as a full-screen dialog.
  /// Returns after the modal is dismissed.
  static Future<void> show(
    BuildContext context, {
    required TrackDefinition track,
    required VoidCallback onStart,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => HowToPlayModal(track: track, onStart: onStart),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      key: const ValueKey('how_to_play_modal'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MiToosaTheme.radiusXl),
      ),
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MiToosaTheme.spacingLg,
          vertical: MiToosaTheme.spacingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // World icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(track.icon, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(height: MiToosaTheme.spacingMd),
            // World name
            Text(
              track.name,
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MiToosaTheme.spacingSm),
            // Subtitle / rule description
            Text(
              track.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: MiToosaTheme.spacingXl),
            // CTA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: const ValueKey('how_to_play_cta'),
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: MiToosaTheme.spacingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MiToosaTheme.radiusMd),
                  ),
                ),
                child: Text(
                  "Let's Go! 🚀",
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
    );
  }
}
