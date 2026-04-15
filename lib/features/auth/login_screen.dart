import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation/world_map_screen.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnim;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _performLogin() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    var navigated = false;

    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      final playerId = ref.playerId;
      if (playerId == null) {
        return;
      }

      final persistence = ref.read(persistenceProvider);
      final progress = await persistence.loadProgress(playerId);
      progress.recordLogin();
      await persistence.saveProgress(progress);

      if (!mounted) return;

      navigated = true;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (c, a1, a2) => const WorldMapScreen(),
          transitionsBuilder: (c, anim, a2, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } finally {
      if (mounted && !navigated) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final canStart = authState.maybeWhen(
      data: (value) => value.isNotEmpty,
      orElse: () => false,
    );
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                  const Color(0xFF3D1566),
                ],
              ),
            ),
          ),
          // Floating shape particles
          ..._buildParticles(context),
          // Content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo
                AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnim.value),
                      child: child,
                    );
                  },
                  child: ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.hub_rounded, size: 64, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: MiToosaTheme.spacingXl),
                // Title
                Text(
                  'miToosa',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 52,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: MiToosaTheme.spacingSm),
                Text(
                  'Unlock Your Cognitive Potential',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: MiToosaTheme.spacingSm),
                // Feature chips
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    {'icon': Icons.psychology_rounded, 'label': 'Memory'},
                    {'icon': Icons.flash_on_rounded, 'label': 'Logic'},
                    {'icon': Icons.brush_rounded, 'label': 'Patterns'},
                  ].map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(item['icon'] as IconData, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                          const SizedBox(width: 8),
                          Text(
                            item['label'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(flex: 2),
                // CTA Button
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton(
                            onPressed: canStart ? _performLogin : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: const Color(0xFF0D0814),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(MiToosaTheme.radiusLg),
                              ),
                              elevation: 0,
                            ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'START TRAINING',
                                  style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          if (kDebugMode) ...[
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () async {
                                final playerId = ref.playerId;
                                if (playerId == null) return;
                                final persistence = ref.read(persistenceProvider);
                                final progress = await persistence.loadProgress(playerId);
                                progress.totalXP += 50; // give 50 XP for debug
                                await persistence.saveProgress(progress);
                              },
                              child: const Text('DEBUG +50 XP'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: MiToosaTheme.spacingXxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles(BuildContext context) {
    final rng = Random(42);
    final screenSize = MediaQuery.of(context).size;

    return List.generate(12, (i) {
      final x = rng.nextDouble() * screenSize.width;
      final y = rng.nextDouble() * screenSize.height;
      final size = 12.0 + rng.nextDouble() * 28;
      final opacity = 0.04 + rng.nextDouble() * 0.08;

      return Positioned(
        left: x,
        top: y,
        child: AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final offset = sin(_floatController.value * pi * 2 + i) * 12;
            return Transform.translate(
              offset: Offset(offset, -offset * 0.5),
              child: child,
            );
          },
          child: Icon(
            [
              Icons.circle,
              Icons.square_rounded,
              Icons.change_history_rounded,
              Icons.star_rounded,
              Icons.hexagon_rounded,
            ][i % 5],
            size: size,
            color: Colors.white.withValues(alpha: opacity),
          ),
        ),
      );
    });
  }
}
