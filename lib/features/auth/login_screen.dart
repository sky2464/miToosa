import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../navigation/world_map_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../../data/player_progress_provider.dart';
import '../../theme/design_system.dart';
import '../../widgets/kinetic_background.dart';
import '../../widgets/glass_card.dart';
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
      await Future.delayed(const Duration(milliseconds: 500));

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

      final needsOnboarding = !progress.onboardingComplete;

      if (needsOnboarding) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => OnboardingScreen(
              onComplete: () async {
                await persistence.completeOnboarding(playerId);
                if (c.mounted) {
                  Navigator.pushReplacement(
                    c,
                    PageRouteBuilder(
                      pageBuilder: (c2, a3, a4) => const WorldMapScreen(),
                      transitionsBuilder: (c2, anim, a4, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 600),
                    ),
                  );
                }
              },
            ),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (c, a1, a2) => const WorldMapScreen(),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } finally {
      if (mounted && !navigated) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final canStart = authState.maybeWhen(
      data: (value) => value.isNotEmpty,
      orElse: () => false,
    );
    return Scaffold(
      backgroundColor: AethericPulseDark.surface,
      body: KineticBackground(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Animated logo
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
                      boxShadow: AethericPulseDark.blueGlow,
                    ),
                    child: const Icon(Icons.hub_rounded, size: 64, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: AethericPulseDark.spaceLg),
              // Hero glass card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AethericPulseDark.spaceMd),
                child: GlassCard(
                  child: Column(
                    children: [
                      const Text(
                        'miToosa',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                      const SizedBox(height: AethericPulseDark.spaceSm),
                      const Text(
                        'Unlock Your Cognitive Potential',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFE2E8F0),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AethericPulseDark.spaceMd),
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
                              color: AethericPulseDark.nestedWell,
                              borderRadius: BorderRadius.circular(AethericPulseDark.radiusChip),
                              border: Border.all(color: AethericPulseDark.glassBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(item['icon'] as IconData, size: 16, color: AethericPulseDark.onSurfaceSecondary),
                                const SizedBox(width: 8),
                                Text(
                                  item['label'] as String,
                                  style: AethericPulseDark.label(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // CTA Button
              if (_isLoading)
                const CircularProgressIndicator(color: AethericPulseDark.brandBlue)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Opacity(
                          opacity: canStart ? 1.0 : 0.4,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AethericPulseDark.gradPrimary,
                              borderRadius: BorderRadius.circular(AethericPulseDark.radiusPill),
                              boxShadow: AethericPulseDark.blueGlow,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              ),
                              onPressed: canStart ? _performLogin : null,
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
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
                              progress.totalXP += 50;
                              await persistence.saveProgress(progress);
                            },
                            child: const Text('DEBUG +50 XP'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AethericPulseDark.spaceXl),
            ],
          ),
        ),
      ),
    );
  }
}
