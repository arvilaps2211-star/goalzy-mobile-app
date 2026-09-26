import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../providers/auth_provider.dart';

/// See splash_screen.dart's doc comment — Login sits outside the shell
/// too, so it's explicitly opted into the Dashboard module for a
/// background and branding consistent with the rest of the app, and to
/// carry the same visual mark shown on the splash screen just before it.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'alex@goalzy.app');
  final _passwordController = TextEditingController(text: 'password');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
    if (mounted && ref.read(authStateProvider).user != null) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return ModuleScope(
      module: GoalzyModule.dashboard,
      child: Builder(
        builder: (context) {
          final theme = context.moduleTheme;
          final g = GoalzyColors.of(context);

          return Scaffold(
            backgroundColor: theme.background,
            body: Stack(
              children: [
                const Positioned.fill(child: ModuleBackground()),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(gradient: theme.gradient, borderRadius: BorderRadius.circular(18)),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 24),
                          Text(
                            'Welcome to\n${AppConstants.appName}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                          ).animate().fadeIn().slideY(begin: 0.2),
                          const SizedBox(height: 8),
                          Text('Sign in to your Life OS', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge)
                              .animate()
                              .fadeIn(delay: 100.ms),
                          const SizedBox(height: 32),
                          GlassCard(
                            useModuleTheme: true,
                            child: Column(
                              children: [
                                GlassInput(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'you@example.com',
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) => v != null && v.contains('@') ? null : 'Enter valid email',
                                ),
                                const SizedBox(height: 16),
                                GlassInput(
                                  controller: _passwordController,
                                  label: 'Password',
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push(AppRoutes.forgotPassword),
                                    child: Text('Forgot password?', style: TextStyle(color: theme.primary)),
                                  ),
                                ),
                                if (auth.error != null) ...[
                                  const SizedBox(height: 12),
                                  Text(auth.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                                ],
                                const SizedBox(height: 24),
                                GlassButton(
                                  label: 'Sign In',
                                  expanded: true,
                                  isLoading: auth.isLoading,
                                  onPressed: _signIn,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(child: Divider(color: g.border)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('or continue with', style: Theme.of(context).textTheme.bodySmall),
                              ),
                              Expanded(child: Divider(color: g.border)),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: GlassButton(
                                  label: 'Google',
                                  icon: Icons.g_mobiledata,
                                  variant: GlassButtonVariant.secondary,
                                  onPressed: () async {
                                    await ref.read(authStateProvider.notifier).signInWithGoogle();
                                    if (mounted) context.go(AppRoutes.home);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassButton(
                                  label: 'Apple',
                                  icon: Icons.apple,
                                  variant: GlassButtonVariant.secondary,
                                  onPressed: () async {
                                    await ref.read(authStateProvider.notifier).signInWithApple();
                                    if (mounted) context.go(AppRoutes.home);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GlassButton(
                            label: 'Continue as Guest',
                            variant: GlassButtonVariant.ghost,
                            expanded: true,
                            onPressed: () async {
                              await ref.read(authStateProvider.notifier).continueAsGuest();
                              if (mounted) context.go(AppRoutes.home);
                            },
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => context.push(AppRoutes.signUp),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(text: "Don't have an account? "),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(color: theme.primary, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
