import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/world_map_screen.dart';
import '../navigation/world_map_path_screen.dart';
import 'progress_screen.dart';
import 'leaderboard_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../data/telemetry_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/kinetic_background.dart';

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _selectedIndex = 0;
  late final AppLifecycleListener _lifecycleListener;

  static const _pages = [
    WorldMapScreen(),
    WorldMapPathScreen(),
    ProgressScreen(),
    LeaderboardScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onPause: _endTelemetrySession,
      onResume: _startTelemetrySession,
      onDetach: _endTelemetrySession,
    );
    unawaited(_startTelemetrySession());
  }

  Future<void> _startTelemetrySession() async {
    await ref.read(telemetrySessionControllerProvider).startSession();
  }

  Future<void> _endTelemetrySession() async {
    await ref.read(telemetrySessionControllerProvider).endSession();
  }

  @override
  void dispose() {
    unawaited(_endTelemetrySession());
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AethericPulseDark.surface
          : AethericPulseLight.lightSurface,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: KineticBackground(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _FloatingGlassNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─── Top app bar ──────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceTint = isDark ? const Color(0xA80B0E14) : const Color(0xCCFBFAFF);
    final borderTint = isDark ? const Color(0x14FFFFFF) : const Color(0x1A1A1B2B);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 56 + top,
          padding: EdgeInsets.only(top: top, left: 16, right: 16),
          decoration: BoxDecoration(
            color: surfaceTint,
            border: Border(bottom: BorderSide(color: borderTint, width: 1)),
          ),
          child: Row(
            children: [
              Semantics(
                label: 'Your avatar',
                image: true,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AethericPulseDark.brandBlue
                          : AethericPulseLight.softBlueDeep,
                      width: 1,
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/avatars/avatar_4.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) => (isDark
                        ? AethericPulseDark.gradPrimary
                        : AethericPulseLight.gradient)
                    .createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  'MITOOSA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              const _CreditPill(value: '1,250'),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreditPill extends StatelessWidget {
  final String value;
  const _CreditPill({required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        isDark ? AethericPulseDark.brandBlue : AethericPulseLight.softBlueDeep;
    return Semantics(
      label: '$value credits',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isDark
              ? AethericPulseDark.glassFill
              : AethericPulseLight.lightSurfaceContainer,
          borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
          border: Border.all(
            color: isDark
                ? AethericPulseDark.glassBorder
                : AethericPulseLight.lightOutlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars_rounded, size: 16, color: accent),
            const SizedBox(width: 6),
            Text(
              '$value CR',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: 0.84,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Floating glass bottom navigation ─────────────────────────────────────────

class _FloatingGlassNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _FloatingGlassNav({
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Tracks'),
    (icon: Icons.route_outlined, activeIcon: Icons.route, label: 'Path'),
    (icon: Icons.insights_outlined, activeIcon: Icons.insights, label: 'Progress'),
    (icon: Icons.leaderboard_outlined, activeIcon: Icons.leaderboard, label: 'Leaders'),
    (icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navFill = isDark ? const Color(0xCC0A0D17) : const Color(0xCCFBFAFF);
    final navBorder =
        isDark ? const Color(0x26FFFFFF) : const Color(0x2A1A1B2B);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomInset > 0 ? bottomInset + 6 : 18,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AethericPulseDark.radiusHeroCard),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: navFill,
              border: Border.all(color: navBorder, width: 1),
              borderRadius:
                  BorderRadius.circular(AethericPulseDark.radiusHeroCard),
              boxShadow: isDark
                  ? AethericPulseDark.cardOuter
                  : AethericPulseLight.shadowSoftBlue,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < _items.length; i++)
                  _NavItem(
                    icon: _items[i].icon,
                    activeIcon: _items[i].activeIcon,
                    label: _items[i].label,
                    isActive: selectedIndex == i,
                    onTap: () => onTap(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark
        ? AethericPulseDark.brandBlue
        : AethericPulseLight.softBlueDeep;
    final inactiveColor = isDark
        ? AethericPulseDark.onSurfaceMuted
        : AethericPulseLight.lightOnSurfaceVariant;
    final activeFill = isDark
        ? AethericPulseDark.brandBlue.withValues(alpha: 0.10)
        : AethericPulseLight.softBlue.withValues(alpha: 0.10);
    final activeBorder = isDark
        ? AethericPulseDark.brandBlue.withValues(alpha: 0.35)
        : AethericPulseLight.softBlue.withValues(alpha: 0.35);
    return Semantics(
      button: true,
      selected: isActive,
      label: '$label tab',
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AethericPulseDark.minTapTarget,
          minHeight: AethericPulseDark.minTapTarget,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedContainer(
            duration: AethericPulseDark.durHover,
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 14 : 10,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isActive ? activeFill : Colors.transparent,
              border: Border.all(
                color: isActive ? activeBorder : Colors.transparent,
                width: 1,
              ),
              borderRadius:
                  BorderRadius.circular(AethericPulseDark.radiusCard),
              boxShadow:
                  isActive ? (isDark ? AethericPulseDark.blueGlow : null) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive ? activeColor : inactiveColor,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
