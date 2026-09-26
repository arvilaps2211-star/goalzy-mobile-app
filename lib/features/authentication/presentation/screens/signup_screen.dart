import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';
import '../../../../shared/widgets/components/module_background.dart';
import '../providers/auth_provider.dart';

/// See splash_screen.dart's doc comment on why pre-auth screens are
/// explicitly opted into the Dashboard module.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
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
                          Row(
                            children: [
                              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(gradient: theme.gradient, borderRadius: BorderRadius.circular(18)),
                              child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 28),
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 24),
                          Text(
                            'Create your account',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                          ).animate().fadeIn().slideY(begin: 0.2),
                          const SizedBox(height: 8),
                          Text('Start building your Life OS', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge)
                              .animate()
                              .fadeIn(delay: 100.ms),
                          const SizedBox(height: 32),
                          GlassCard(
                            useModuleTheme: true,
                            child: Column(
                              children: [
                                GlassInput(
                                  controller: _nameController,
                                  label: 'Name',
                                  hint: 'Your name',
                                  prefixIcon: Icons.person_outline,
                                  validator: (v) => v != null && v.trim().isNotEmpty ? null : 'Name is required',
                                ),
                                const SizedBox(height: 16),
                                GlassInput(
                                  controller: _emailController,
                                  label: 'Email',
                                  hint: 'you@example.com',
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
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
                                const SizedBox(height: 16),
                                GlassInput(
                                  controller: _confirmController,
                                  label: 'Confirm Password',
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: (v) => v == _passwordController.text ? null : 'Passwords do not match',
                                ),
                                if (auth.error != null) ...[
                                  const SizedBox(height: 12),
                                  Text(auth.error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                                ],
                                const SizedBox(height: 24),
                                GlassButton(
                                  label: 'Create Account',
                                  expanded: true,
                                  isLoading: auth.isLoading,
                                  onPressed: _signUp,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(text: 'Already have an account? '),
                                    TextSpan(
                                      text: 'Sign In',
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
