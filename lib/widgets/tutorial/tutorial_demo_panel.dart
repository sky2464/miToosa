import 'package:flutter/material.dart';

import '../../core/tutorial/tutorial_definition.dart';
import '../../theme/design_system.dart';

/// Native Flutter interactive surface for BL-24 how-to demos.
class TutorialDemoPanel extends StatefulWidget {
  final TutorialDefinition definition;
  final bool requireSuccessBeforeContinue;
  final ValueChanged<bool>? onPracticeComplete;

  const TutorialDemoPanel({
    super.key,
    required this.definition,
    this.requireSuccessBeforeContinue = true,
    this.onPracticeComplete,
  });

  @override
  State<TutorialDemoPanel> createState() => _TutorialDemoPanelState();
}

class _TutorialDemoPanelState extends State<TutorialDemoPanel> {
  bool _succeeded = false;
  String? _feedback;

  void _onOptionTap(TutorialDemoOption option) {
    if (_succeeded && widget.requireSuccessBeforeContinue) return;
    if (option.id == widget.definition.correctAction) {
      setState(() {
        _succeeded = true;
        _feedback = 'Nice — you got it!';
      });
      widget.onPracticeComplete?.call(true);
    } else {
      setState(() {
        _feedback = 'Not quite — try another option.';
      });
      widget.onPracticeComplete?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label: 'Interactive tutorial practice',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.definition.demoPrompt,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: MiToosaTheme.spacingSm),
          ...widget.definition.steps.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('• $s', style: theme.textTheme.bodySmall),
            ),
          ),
          const SizedBox(height: MiToosaTheme.spacingMd),
          ...widget.definition.demoOptions.map((opt) {
            return Padding(
              padding: const EdgeInsets.only(bottom: MiToosaTheme.spacingSm),
              child: Semantics(
                button: true,
                label: opt.label,
                child: SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _onOptionTap(opt),
                    child: Text(opt.label),
                  ),
                ),
              ),
            );
          }),
          if (_feedback != null) ...[
            const SizedBox(height: MiToosaTheme.spacingSm),
            AnimatedOpacity(
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              opacity: 1,
              child: Text(
                _feedback!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _succeeded
                      ? MiToosaTheme.success
                      : theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
