import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../navigation/world_map_screen.dart';
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
    return Scaffold(
      backgroundColor: KineticObsidian.surface,
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
      bottomNavigationBar: _GlassBottomNav(
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
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 56 + top,
          padding: EdgeInsets.only(top: top, left: 16, right: 16),
          decoration: const BoxDecoration(
            color: Color(0xA80B0E14),
            border: Border(
              bottom: BorderSide(color: Color(0x14FFFFFF), width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: KineticObsidian.electricCyan,
                    width: 1,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/avatars/avatar_4.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ShaderMask(
                shaderCallback: (bounds) =>
                    KineticObsidian.kineticGradient.createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  'MITOOSA',
                  style: TextStyle(fontFamily: KineticObsidian.fontDisplay, fontFamilyFallback: KineticObsidian.fontFallback, 
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              _CreditPill(value: '1,250'),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: KineticObsidian.surfaceContainer,
        borderRadius: BorderRadius.circular(KineticObsidian.radiusFull),
        border: Border.all(color: KineticObsidian.outlineVariant, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded,
              size: 16, color: KineticObsidian.electricCyan),
          const SizedBox(width: 6),
          Text(
            '$value CR',
            style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.84,
              color: KineticObsidian.electricCyan,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glass bottom navigation ──────────────────────────────────────────────────

class _GlassBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _GlassBottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.route_outlined, activeIcon: Icons.route, label: 'Tracks'),
    (icon: Icons.insights_outlined, activeIcon: Icons.insights, label: 'Progress'),
    (icon: Icons.leaderboard_outlined, activeIcon: Icons.leaderboard, label: 'Leaders'),
    (icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.only(
            top: 10, left: 8, right: 8,
            bottom: bottom > 0 ? bottom : 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xB30B0E14),
            border: Border(
              top: BorderSide(color: Color(0x14FFFFFF), width: 1),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: KineticObsidian.durMed,
        curve: KineticObsidian.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 14 : 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? KineticObsidian.electricCyan.withValues(alpha: 0.10)
              : Colors.transparent,
          border: Border.all(
            color: isActive
                ? KineticObsidian.electricCyan.withValues(alpha: 0.30)
                : Colors.transparent,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(KineticObsidian.radiusLg),
          boxShadow: isActive ? KineticObsidian.shadowNeonSoft : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 20,
              color: isActive
                  ? KineticObsidian.electricCyan
                  : KineticObsidian.outline,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontFamily: KineticObsidian.fontBody, fontFamilyFallback: KineticObsidian.fontFallback, 
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isActive
                    ? KineticObsidian.electricCyan
                    : KineticObsidian.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
