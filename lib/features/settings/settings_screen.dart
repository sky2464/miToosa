import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/progression_engine.dart';
import '../../core/audio_service.dart';
import '../../core/haptics_service.dart';
import '../../core/music_service.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/kinetic_background.dart';
import '../../widgets/settings_row.dart';
import '../../widgets/toggle_switch.dart';
import 'analytics_privacy_controller.dart';
import 'privacy_disclosure_copy.dart';
import 'privacy_policy_screen.dart';
import 'reset_progress_controller.dart';

/// Shipped app version label — keep in sync with `pubspec.yaml` `version:`.
const String kShippedAppVersionLabel = '1.5.1';

// ─── Settings screen — Aetheric Pulse ────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    return KineticBackground(
      child: progressAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AethericPulseDark.brandBlue),
        ),
        error: (e, _) => Center(
          child: Text(
            'Could not load settings.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        data: (progress) => _SettingsBody(progress: progress),
      ),
    );
  }
}

class _SettingsBody extends ConsumerStatefulWidget {
  final PlayerProgress progress;
  const _SettingsBody({required this.progress});

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  late bool _soundEffectsEnabled;
  bool _analyticsEnabled = true;
  bool _analyticsUpdating = false;

  @override
  void initState() {
    super.initState();
    _soundEffectsEnabled = AudioService().enabled;
    _loadAnalyticsPreference();
  }

  Future<void> _loadAnalyticsPreference() async {
    final enabled = await ref
        .read(analyticsPrivacyControllerProvider)
        .loadEnabled();
    if (!mounted) return;
    setState(() => _analyticsEnabled = enabled);
  }

  Future<void> _onAnalyticsChanged(bool enabled) async {
    if (_analyticsUpdating) return;
    final previous = _analyticsEnabled;
    setState(() {
      _analyticsEnabled = enabled;
      _analyticsUpdating = true;
    });
    try {
      await ref.read(analyticsPrivacyControllerProvider).setEnabled(enabled);
    } catch (_) {
      if (!mounted) return;
      setState(() => _analyticsEnabled = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update analytics preference. Try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _analyticsUpdating = false);
      }
    }
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  Future<void> _onResetProgressTap() async {
    final result = await ref
        .read(resetProgressControllerProvider)
        .confirmAndReset(context);
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case ResetProgressResult.success:
        messenger.showSnackBar(
          const SnackBar(content: Text('Progress reset. Starting fresh!')),
        );
      case ResetProgressResult.failed:
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Could not reset progress. Please try again.',
            ),
          ),
        );
      case ResetProgressResult.cancelled:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tier = ProgressionEngine.computeMasteryTier(
      widget.progress.adaptiveHistory,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceMd,
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceXl + 80,
      ),
      children: [
        Text('Settings', style: AethericPulseDark.headlineLg()),
        const SizedBox(height: AethericPulseDark.spaceMd),

        const _SectionLabel('Your Mastery'),
        const SizedBox(height: 8),
        _MasteryCard(
          tier: tier,
          levelCount: widget.progress.adaptiveHistory.length,
        ),
        const SizedBox(height: 16),

        const _SectionLabel('System'),
        const SizedBox(height: 8),
        GlassCard(
          borderRadius: AethericPulseDark.radiusCard,
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: AethericPulseDark.spaceMd,
          ),
          child: Column(
            children: [
              SettingsRow(
                icon: const Icon(Icons.volume_up_outlined),
                title: 'Sound FX',
                trailing: ToggleSwitch(
                  value: _soundEffectsEnabled,
                  onChanged: (v) {
                    AudioService().enabled = v;
                    setState(() => _soundEffectsEnabled = v);
                  },
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              SettingsRow(
                icon: const Icon(Icons.music_note_outlined),
                title: 'Music',
                subtitle: 'Background music during gameplay',
                trailing: ToggleSwitch(
                  value: MusicService().enabled,
                  onChanged: (v) {
                    MusicService().enabled = v;
                    setState(() {});
                  },
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              SettingsRow(
                icon: const Icon(Icons.vibration_outlined),
                title: 'Haptics',
                trailing: ToggleSwitch(
                  value: HapticsService().enabled,
                  onChanged: (v) {
                    HapticsService().enabled = v;
                    setState(() {});
                  },
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              SettingsRow(
                icon: const Icon(Icons.tune_outlined),
                title: 'Adaptive Difficulty',
                subtitle: 'Adjusts puzzles to your skill level',
                trailing: ToggleSwitch(
                  value:
                      widget.progress.difficultyMode == DifficultyMode.adaptive,
                  onChanged: (enabled) async {
                    widget.progress.difficultyMode = enabled
                        ? DifficultyMode.adaptive
                        : DifficultyMode.standard;
                    await ref
                        .read(persistenceProvider)
                        .saveProgress(widget.progress);
                    ref.invalidate(playerProgressProvider);
                  },
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              SettingsRow(
                icon: const Icon(Icons.contrast_rounded),
                title: 'Appearance',
                subtitle: 'System follows iOS; pick Light or Dark to override',
                trailing: _ThemeModeSelector(
                  value: widget.progress.themeModeOverride,
                  onChanged: (v) async {
                    widget.progress.themeModeOverride = v;
                    await ref
                        .read(persistenceProvider)
                        .saveProgress(widget.progress);
                    ref.invalidate(playerProgressProvider);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const _SectionLabel('Privacy'),
        const SizedBox(height: 8),
        GlassCard(
          borderRadius: AethericPulseDark.radiusCard,
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: AethericPulseDark.spaceMd,
          ),
          child: Column(
            children: [
              SettingsRow(
                icon: const Icon(Icons.analytics_outlined),
                title: kAnonymousAnalyticsTitle,
                subtitle: _analyticsEnabled == false
                    ? kAnonymousAnalyticsDisabledEffect
                    : kAnonymousAnalyticsSubtitle,
                trailing: ToggleSwitch(
                        value: _analyticsEnabled,
                        onChanged: _analyticsUpdating
                            ? (_) {}
                            : _onAnalyticsChanged,
                      ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              SettingsRow(
                icon: const Icon(Icons.policy_outlined),
                title: kPrivacyPolicyLinkLabel,
                subtitle: 'How we handle local data and optional analytics',
                onTap: _openPrivacyPolicy,
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 22,
                  color: AethericPulseDark.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GlassCard(
          borderRadius: AethericPulseDark.radiusCard,
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: AethericPulseDark.spaceMd,
          ),
          child: SettingsRow(
            icon: const Icon(Icons.restart_alt_outlined),
            title: 'Reset progress',
            subtitle: 'Clear all progress and stats',
            onTap: _onResetProgressTap,
            trailing: const Icon(
              Icons.chevron_right,
              size: 22,
              color: AethericPulseDark.onSurfaceMuted,
            ),
          ),
        ),
        const SizedBox(height: AethericPulseDark.spaceMd),

        Center(
          child: Text(
            'MITOOSA · V$kShippedAppVersionLabel',
            style: AethericPulseDark.label(
              color: AethericPulseDark.onSurfaceMuted,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: AethericPulseDark.label(color: AethericPulseDark.onSurfaceMuted),
      ),
    );
  }
}

// ─── Theme mode selector ─────────────────────────────────────────────────────

class _ThemeModeSelector extends StatelessWidget {
  final int? value; // null/0 = system, 1 = light, 2 = dark
  final ValueChanged<int?> onChanged;

  const _ThemeModeSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final current = value ?? 0;
    Widget chip(int v, IconData icon, String label) {
      final selected = current == v;
      return Semantics(
        button: true,
        selected: selected,
        label: '$label appearance',
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AethericPulseDark.minTapTarget,
            minHeight: AethericPulseDark.minTapTarget,
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(v == 0 ? null : v),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AethericPulseDark.brandBlue.withValues(alpha: 0.18)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AethericPulseDark.brandBlue.withValues(alpha: 0.45)
                      : AethericPulseDark.glassBorder,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(
                  AethericPulseDark.radiusChip,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: selected
                    ? AethericPulseDark.brandBlue
                    : AethericPulseDark.onSurfaceMuted,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chip(0, Icons.phone_iphone_rounded, 'System'),
        const SizedBox(width: 6),
        chip(1, Icons.light_mode_rounded, 'Light'),
        const SizedBox(width: 6),
        chip(2, Icons.dark_mode_rounded, 'Dark'),
      ],
    );
  }
}

// ─── Mastery card ─────────────────────────────────────────────────────────────

class _MasteryCard extends StatelessWidget {
  final MasteryTier tier;
  final int levelCount;

  const _MasteryCard({required this.tier, required this.levelCount});

  @override
  Widget build(BuildContext context) {
    final (label, color, img) = switch (tier) {
      MasteryTier.gold => (
        'Gold Mastery',
        const Color(0xFFFFD700),
        'assets/images/badges/logic_legend.png',
      ),
      MasteryTier.silver => (
        'Silver Mastery',
        const Color(0xFFC0C0C0),
        'assets/images/badges/memory_marvel.png',
      ),
      MasteryTier.bronze => (
        'Bronze Mastery',
        const Color(0xFFCD7F32),
        'assets/images/badges/novice_mind.png',
      ),
    };

    return GlassCard(
      borderRadius: AethericPulseDark.radiusCard,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Image.asset(img, width: 52, height: 52, fit: BoxFit.contain),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AethericPulseDark.headlineMd(color: color)),
                const SizedBox(height: 4),
                Text(
                  levelCount == 0
                      ? 'Complete levels to build your history.'
                      : 'Based on $levelCount completed level${levelCount == 1 ? '' : 's'}.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
