import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';
import '../providers/auth_provider.dart';

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

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'Welcome to\n${AppConstants.appName}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                  ).animate().fadeIn().slideY(begin: 0.2),
                  const SizedBox(height: 8),
                  Text('Sign in to your Life OS', style: Theme.of(context).textTheme.bodyLarge)
                      .animate()
                      .fadeIn(delay: 100.ms),
                  const SizedBox(height: 40),
                  GlassCard(
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
                      const Expanded(child: Divider(color: AppColors.glassBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('or continue with', style: Theme.of(context).textTheme.bodySmall),
                      ),
                      const Expanded(child: Divider(color: AppColors.glassBorder)),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
