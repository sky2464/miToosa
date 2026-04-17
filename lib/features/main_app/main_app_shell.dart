import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation/world_map_screen.dart';
import 'progress_screen.dart';
import 'leaderboard_screen.dart';
import '../../data/telemetry_provider.dart';

class MainAppShell extends ConsumerStatefulWidget {
  const MainAppShell({super.key});

  @override
  ConsumerState<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends ConsumerState<MainAppShell> {
  int _selectedIndex = 0;
  late final AppLifecycleListener _lifecycleListener;

  final List<Widget> _pages = const [
    WorldMapScreen(),
    ProgressScreen(),
    LeaderboardScreen(),
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.public_outlined),
            activeIcon: Icon(Icons.public),
            label: 'Tracks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}
