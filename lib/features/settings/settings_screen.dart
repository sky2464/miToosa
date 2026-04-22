import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/engine/progression_engine.dart';
import '../../core/haptics_service.dart';
import '../../core/music_service.dart';
import '../../data/player_progress.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/glass_card.dart';

// ─── Settings screen — Kinetic Obsidian ──────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(playerProgressProvider);
    return progressAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: KineticObsidian.electricCyan)),
      error: (e, _) => Center(
          child: Text('Could not load settings.',
              style: Theme.of(context).textTheme.bodyMedium)),
      data: (progress) => _SettingsBody(progress: progress),
    );
  }
}

bool _soundEffectsEnabled = true;

class _SettingsBody extends ConsumerStatefulWidget {
  final PlayerProgress progress;
  const _SettingsBody({required this.progress});

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  @override
  Widget build(BuildContext context) {
    final tier = ProgressionEngine.computeMasteryTier(
        widget.progress.adaptiveHistory);
    final level = (widget.progress.totalXP ~/ 1000) + 1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceMd,
        KineticObsidian.spaceGutter,
        KineticObsidian.spaceLg + 80,
      ),
      children: [
        Text(
          'Settings',
          style: GoogleFonts.orbitron(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.12,
            color: KineticObsidian.primarySoft,
          ),
        ),
        const SizedBox(height: KineticObsidian.spaceMd),

        // Profile card
        GlassCard(
          borderRadius: KineticObsidian.radiusXl,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: KineticObsidian.electricCyan, width: 1),
                  boxShadow: KineticObsidian.shadowNeonSoft,
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
                      style: GoogleFonts.exo2(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.84,
                        color: KineticObsidian.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Level $level · ${widget.progress.diamonds} CR',
                      style: GoogleFonts.exo2(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.48,
                        color: KineticObsidian.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 22, color: KineticObsidian.onSurfaceVariant),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Mastery badge
        _SectionLabel('Your Mastery'),
        const SizedBox(height: 8),
        _MasteryCard(
            tier: tier,
            levelCount: widget.progress.adaptiveHistory.length),
        const SizedBox(height: 16),

        // Account
        _SectionLabel('Account'),
        const SizedBox(height: 8),
        GlassCard(
          borderRadius: KineticObsidian.radiusXl,
          padding: const EdgeInsets.symmetric(
              vertical: 2, horizontal: KineticObsidian.spaceMd),
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.share_outlined,
                title: 'Share miToosa',
                subtitle: '+40 sessions per invite',
                right: const Icon(Icons.chevron_right,
                    size: 22, color: KineticObsidian.onSurfaceVariant),
              ),
              const Divider(height: 1, color: Color(0x0AFFFFFF)),
              _SettingRow(
                icon: Icons.workspace_premium_outlined,
                title: 'Go VIP',
                subtitle: 'Ad-free + 10 bonus sessions / day',
                right: _PurpleChip(label: 'Upgrade'),
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // System preferences
        _SectionLabel('System'),
        const SizedBox(height: 8),
        GlassCard(
          borderRadius: KineticObsidian.radiusXl,
          padding: const EdgeInsets.symmetric(
              vertical: 2, horizontal: KineticObsidian.spaceMd),
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.volume_up_outlined,
                title: 'Sound FX',
                right: _KineticToggle(
                  value: _soundEffectsEnabled,
                  onChanged: (v) => setState(() => _soundEffectsEnabled = v),
                ),
              ),
              const Divider(height: 1, color: Color(0x0AFFFFFF)),
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
              const Divider(height: 1, color: Color(0x0AFFFFFF)),
              _SettingRow(
                icon: Icons.notifications_outlined,
                title: 'Daily reminder',
                subtitle: 'Nudges if your streak is at risk',
                right: _KineticToggle(
                  value: true,
                  onChanged: (_) {},
                ),
              ),
              const Divider(height: 1, color: Color(0x0AFFFFFF)),
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
              const Divider(height: 1, color: Color(0x0AFFFFFF)),
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
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Danger zone
        GlassCard(
          borderRadius: KineticObsidian.radiusXl,
          padding: const EdgeInsets.symmetric(
              vertical: 2, horizontal: KineticObsidian.spaceMd),
          child: _SettingRow(
            icon: Icons.restart_alt_outlined,
            title: 'Reset progress',
            subtitle: 'Clear all credits and stats',
            right: const Icon(Icons.chevron_right,
                size: 22, color: KineticObsidian.onSurfaceVariant),
            isLast: true,
          ),
        ),
        const SizedBox(height: KineticObsidian.spaceMd),

        Center(
          child: Text(
            'MITOOSA · V1.4.0',
            style: GoogleFonts.exo2(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
              color: KineticObsidian.outline,
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
      padding: const EdgeInsets.only(left: 4, bottom: 0),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.exo2(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.88,
          color: KineticObsidian.onSurfaceVariant,
        ),
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
  final bool isLast;

  const _SettingRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.right,
    this.isLast = false,
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
              color: KineticObsidian.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KineticObsidian.radiusLg),
              border:
                  Border.all(color: KineticObsidian.outlineVariant, width: 1),
            ),
            child: Center(
                child: Icon(icon,
                    size: 20, color: KineticObsidian.electricCyan)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.exo2(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.28,
                    color: KineticObsidian.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.exo2(
                      fontSize: 11,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.44,
                      color: KineticObsidian.onSurfaceVariant,
                    ),
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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: KineticObsidian.durMed,
        width: 46,
        height: 26,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: value ? KineticObsidian.kineticGradient : null,
          color: value ? null : KineticObsidian.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KineticObsidian.radiusFull),
          border: Border.all(
            color: value
                ? KineticObsidian.electricCyan.withValues(alpha: 0.5)
                : KineticObsidian.outlineVariant,
            width: 1,
          ),
          boxShadow: value ? KineticObsidian.shadowNeonSoft : null,
        ),
        child: AnimatedAlign(
          duration: KineticObsidian.durMed,
          curve: KineticObsidian.easeSnappy,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: KineticObsidian.onSurface,
            ),
          ),
        ),
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
        color: KineticObsidian.protonPurple.withValues(alpha: 0.18),
        border: Border.all(
            color: KineticObsidian.protonPurple.withValues(alpha: 0.40),
            width: 1),
        borderRadius: BorderRadius.circular(KineticObsidian.radiusFull),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.exo2(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
          color: KineticObsidian.secondaryFixedDim,
        ),
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
      borderRadius: KineticObsidian.radiusXl,
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
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.64,
                    color: color,
                  ),
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
