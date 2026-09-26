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
///
/// requestPasswordReset() doesn't touch global AuthState (see auth_provider
/// .dart) — this screen manages its own local loading/sent state, same
/// pattern as GoalCreateScreen and the Tasks quick-add sheet.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSending = true;
      _error = null;
    });
    try {
      await ref.read(authStateProvider.notifier).requestPasswordReset(_emailController.text.trim());
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              _sent ? Icons.mark_email_read_outlined : Icons.lock_reset_rounded,
                              color: theme.primary,
                              size: 28,
                            ),
                          ),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 24),
                        Text(
                          _sent ? 'Check your email' : 'Reset your password',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                        ).animate().fadeIn().slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          _sent
                              ? 'If an account exists for ${_emailController.text.trim()}, a reset link is on its way.'
                              : "Enter your email and we'll send you a reset link",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: 32),
                        if (!_sent)
                          GlassCard(
                            useModuleTheme: true,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  GlassInput(
                                    controller: _emailController,
                                    label: 'Email',
                                    hint: 'you@example.com',
                                    prefixIcon: Icons.email_outlined,
                                    validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                                  ),
                                  if (_error != null) ...[
                                    const SizedBox(height: 12),
                                    Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                                  ],
                                  const SizedBox(height: 24),
                                  GlassButton(
                                    label: 'Send Reset Link',
                                    expanded: true,
                                    isLoading: _isSending,
                                    onPressed: _send,
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: 200.ms)
                        else
                          GlassButton(
                            label: 'Back to Sign In',
                            expanded: true,
                            variant: GlassButtonVariant.secondary,
                            onPressed: () => context.go(AppRoutes.login),
                          ).animate().fadeIn(delay: 200.ms),
                        if (!_sent) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go(AppRoutes.login),
                              child: Text('Back to Sign In', style: TextStyle(color: g.textSecondary)),
                            ),
                          ),
                        ],
                      ],
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
