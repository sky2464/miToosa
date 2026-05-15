import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/world_map_screen.dart';
import '../navigation/world_map_path_screen.dart';
import 'progress_screen.dart';
import 'leaderboard_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../data/player_progress_provider.dart';
import '../../data/telemetry_provider.dart';
import '../../data/telemetry_session_controller.dart';
import '../../theme/design_system.dart';
import '../../widgets/app_header.dart';
import '../../widgets/atmosphere.dart';
import '../../widgets/kinetic_background.dart';

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _selectedIndex = 0;
  late final AppLifecycleListener _lifecycleListener;
  late final TelemetrySessionController _telemetryController;

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
    _telemetryController = ref.read(telemetrySessionControllerProvider);
    _lifecycleListener = AppLifecycleListener(
      onPause: _endTelemetrySession,
      onResume: _startTelemetrySession,
      onDetach: _endTelemetrySession,
    );
    unawaited(_startTelemetrySession());
  }

  Future<void> _startTelemetrySession() async {
    await _telemetryController.startSession();
  }

  Future<void> _endTelemetrySession() async {
    await _telemetryController.endSession();
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
    final coins = ref.watch(playerProgressProvider).maybeWhen(
      data: (p) => p.coins,
      orElse: () => 0,
    );
    return Scaffold(
      backgroundColor: isDark
          ? AethericPulseDark.surface
          : AethericPulseLight.lightSurface,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Aetheric Pulse atmosphere — animated glow blobs + star field
          if (isDark)
            const Positioned.fill(child: Atmosphere(accent: 'blue'))
          else
            const Positioned.fill(child: KineticBackground(child: SizedBox.expand())),
          Column(
            children: [
              _SafeAppHeader(coins: coins),
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _pages,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _FloatingGlassNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ─── Safe app header wrapper ──────────────────────────────────────────────────

class _SafeAppHeader extends StatelessWidget {
  final int coins;
  const _SafeAppHeader({required this.coins});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: AppHeader(credits: coins),
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
        bottomInset > 0 ? bottomInset + 6 : 14,
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AethericPulseDark.radiusCard),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: navFill,
              border: Border.all(color: navBorder, width: 1),
              borderRadius:
                  BorderRadius.circular(AethericPulseDark.radiusCard),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 2,
                child: Center(
                  child: AnimatedContainer(
                    duration: AethericPulseDark.durHover,
                    width: isActive ? 20.0 : 0.0,
                    height: 2,
                    decoration: isActive
                        ? BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: [
                              BoxShadow(
                                color: activeColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              AnimatedContainer(
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
            ],
          ),
        ),
      ),
    );
  }
}
