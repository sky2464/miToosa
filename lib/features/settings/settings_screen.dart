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

// ─── Settings screen — Aetheric Pulse ────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    return KineticBackground(
      child: progressAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AethericPulseDark.brandBlue)),
        error: (e, _) => Center(
            child: Text('Could not load settings.',
                style: Theme.of(context).textTheme.bodyMedium)),
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

  @override
  void initState() {
    super.initState();
    _soundEffectsEnabled = AudioService().enabled;
  }

  @override
  Widget build(BuildContext context) {
    final tier = ProgressionEngine.computeMasteryTier(
        widget.progress.adaptiveHistory);
    final level = (widget.progress.totalXP ~/ 1000) + 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceMd,
        AethericPulseDark.spaceLg,
        AethericPulseDark.spaceXl + 80,
      ),
      children: [
        Text(
          'Settings',
          style: AethericPulseDark.headlineLg(),
        ),
        const SizedBox(height: AethericPulseDark.spaceMd),

        // Profile card
        GlassCard(
          borderRadius: AethericPulseDark.radiusCard,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AethericPulseDark.brandBlue, width: 1),
                  boxShadow: AethericPulseDark.blueGlow,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/avatars/avatar_4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PILOT_042',
                      style: AethericPulseDark.bodyMd(color: AethericPulseDark.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Level $level · ${widget.progress.diamonds} CR',
                      style: AethericPulseDark.label(color: AethericPulseDark.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 22, color: AethericPulseDark.onSurfaceMuted),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mastery badge
        const _SectionLabel('Your Mastery'),
        const SizedBox(height: 8),
        _MasteryCard(
            tier: tier,
            levelCount: widget.progress.adaptiveHistory.length),
        const SizedBox(height: 16),

        // Account
        const _SectionLabel('Account'),
        const SizedBox(height: 8),
        const GlassCard(
          borderRadius: AethericPulseDark.radiusCard,
          padding: EdgeInsets.symmetric(
              vertical: 2, horizontal: AethericPulseDark.spaceMd),
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.share_outlined,
                title: 'Share miToosa',
                subtitle: '+40 sessions per invite',
                right: Icon(Icons.chevron_right,
                    size: 22, color: AethericPulseDark.onSurfaceMuted),
              ),
              Divider(height: 1, color: AethericPulseDark.glassBorder),
              _SettingRow(
                icon: Icons.workspace_premium_outlined,
                title: 'Go VIP',
                subtitle: 'Ad-free + 10 bonus sessions / day',
                right: _PurpleChip(label: 'Upgrade'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // System preferences
        const _SectionLabel('System'),
        const SizedBox(height: 8),
        GlassCard(
          borderRadius: AethericPulseDark.radiusCard,
          padding: const EdgeInsets.symmetric(
              vertical: 2, horizontal: AethericPulseDark.spaceMd),
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.volume_up_outlined,
                title: 'Sound FX',
                right: _KineticToggle(
                  value: _soundEffectsEnabled,
                  onChanged: (v) {
                    AudioService().enabled = v;
                    setState(() => _soundEffectsEnabled = v);
                  },
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              _SettingRow(
                icon: Icons.music_note_outlined,
                title: 'Music',
                subtitle: 'Background music during gameplay',
                right: _KineticToggle(
                  value: MusicService().enabled,
                  onChanged: (v) {
                    MusicService().enabled = v;
                    setState(() {});
                  },
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              _SettingRow(
                icon: Icons.notifications_outlined,
                title: 'Daily reminder',
                subtitle: 'Nudges if your streak is at risk',
                right: _KineticToggle(
                  value: true,
                  onChanged: (_) {},
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              _SettingRow(
                icon: Icons.vibration_outlined,
                title: 'Haptics',
                right: _KineticToggle(
                  value: HapticsService().enabled,
                  onChanged: (v) {
                    HapticsService().enabled = v;
                    setState(() {});
                  },
                ),
              ),
              const Divider(height: 1, color: AethericPulseDark.glassBorder),
              _SettingRow(
                icon: Icons.tune_outlined,
                title: 'Adaptive Difficulty',
                subtitle: 'Adjusts puzzles to your skill level',
                right: _KineticToggle(
                  value: widget.progress.difficultyMode ==
                      DifficultyMode.adaptive,
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
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Danger zone
        const GlassCard(
          borderRadius: AethericPulseDark.radiusCard,
          padding: EdgeInsets.symmetric(
              vertical: 2, horizontal: AethericPulseDark.spaceMd),
          child: _SettingRow(
            icon: Icons.restart_alt_outlined,
            title: 'Reset progress',
            subtitle: 'Clear all credits and stats',
            right: Icon(Icons.chevron_right,
                size: 22, color: AethericPulseDark.onSurfaceMuted),
          ),
        ),
        const SizedBox(height: AethericPulseDark.spaceMd),

        Center(
          child: Text(
            'MITOOSA · V1.4.0',
            style: AethericPulseDark.label(color: AethericPulseDark.onSurfaceMuted),
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

// ─── Setting row ──────────────────────────────────────────────────────────────

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget right;

  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AethericPulseDark.glassFill,
              borderRadius: BorderRadius.circular(AethericPulseDark.radiusWell),
              border:
                  Border.all(color: AethericPulseDark.glassBorder, width: 1),
            ),
            child: Center(
                child: Icon(icon,
                    size: 20, color: AethericPulseDark.brandBlue)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AethericPulseDark.bodyMd(color: AethericPulseDark.onSurface),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AethericPulseDark.label(color: AethericPulseDark.onSurfaceMuted),
                  ),
                ],
              ],
            ),
          ),
          right,
        ],
      ),
    );
  }
}

// ─── Kinetic toggle ───────────────────────────────────────────────────────────

class _KineticToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _KineticToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Material ancestor required by Switch when screen has no Scaffold.
    return Material(
      type: MaterialType.transparency,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AethericPulseDark.brandBlue,
        activeThumbColor: Colors.white,
      ),
    );
  }
}

// ─── Purple chip ──────────────────────────────────────────────────────────────

class _PurpleChip extends StatelessWidget {
  final String label;
  const _PurpleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AethericPulseDark.brandPurple.withValues(alpha: 0.18),
        border: Border.all(
            color: AethericPulseDark.brandPurple.withValues(alpha: 0.40),
            width: 1),
        borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
      ),
      child: Text(
        label.toUpperCase(),
        style: AethericPulseDark.label(color: AethericPulseDark.onSurface),
      ),
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
      MasteryTier.gold =>
        ('Gold Mastery', const Color(0xFFFFD700), 'assets/images/badges/logic_legend.png'),
      MasteryTier.silver =>
        ('Silver Mastery', const Color(0xFFC0C0C0), 'assets/images/badges/memory_marvel.png'),
      MasteryTier.bronze =>
        ('Bronze Mastery', const Color(0xFFCD7F32), 'assets/images/badges/novice_mind.png'),
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
                Text(
                  label,
                  style: AethericPulseDark.headlineMd(color: color),
                ),
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
