import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../providers/auth_provider.dart';

/// Splash and Login (see login_screen.dart) sit outside the bottom-nav
/// shell, so they never pick up a module scope automatically the way
/// every in-app screen does via MainShell's `_ModuleTab`. Both are
/// explicitly opted into the Dashboard module here — the app's primary
/// identity — so the pre-auth experience still gets a module background
/// and consistent branding instead of the flat static gradient it had
/// before.
///
/// Also waits for [AuthState.isRestoring] to clear before navigating —
/// previously this unconditionally sent every user to /login after a
/// fixed delay, even if they'd already signed in during a prior session.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _proceedWhenReady();
  }

  Future<void> _proceedWhenReady() async {
    // Minimum branding delay and session restoration race in parallel —
    // whichever finishes last determines when we actually navigate, so a
    // fast restore never feels like a jarring instant-skip past the logo,
    // and a slow restore never waits longer than it has to beyond that.
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 1400));
    await Future.wait([
      minDelay,
      ref.read(authStateProvider.notifier).ensureRestored(),
    ]);
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    final isSignedIn = authState.isAuthenticated || authState.isGuest;
    context.go(isSignedIn ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScope(
      module: GoalzyModule.dashboard,
      child: Builder(
        builder: (context) {
          final theme = context.moduleTheme;
          return Scaffold(
            backgroundColor: theme.background,
            body: Stack(
              children: [
                const Positioned.fill(child: ModuleBackground()),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: theme.gradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: theme.primary.withValues(alpha: 0.4), blurRadius: 30)],
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 24),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              foreground: Paint()..shader = theme.gradient.createShader(const Rect.fromLTWH(0, 0, 200, 50)),
                            ),
                      ).animate().fadeIn(delay: 300.ms),
                      const SizedBox(height: 8),
                      Text(AppConstants.appTagline, style: Theme.of(context).textTheme.bodyLarge)
                          .animate()
                          .fadeIn(delay: 500.ms),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
