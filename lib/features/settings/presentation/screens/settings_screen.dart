import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../shared/widgets/components/glass_button.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/glass_input.dart';
import '../../../../shared/widgets/components/glass_modal.dart';
import '../../../../shared/widgets/components/section_header.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/appearance_provider.dart';

// NOTE: AppThemeMode / SettingsState / SettingsNotifier / settingsProvider
// below are live business logic, not just UI state — main.dart reads
// settingsProvider directly to drive MaterialApp.router's themeMode, so
// toggling the radio buttons on this screen actually switches the whole
// app's light/dark mode. Left completely unchanged; only SettingsScreen's
// build() and the section-title widget were touched in this redesign.

enum AppThemeMode { dark, light, system }

class SettingsState {
  const SettingsState({
    this.themeMode = AppThemeMode.light,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.habitReminders = true,
    this.taskReminders = true,
    this.aiInsights = true,
    this.profilePublic = false,
    this.analyticsSharing = true,
    this.biometricLock = false,
    this.twoFactorEnabled = false,
  });

  final AppThemeMode themeMode;
  final bool pushNotifications;
  final bool emailNotifications;
  final bool habitReminders;
  final bool taskReminders;
  final bool aiInsights;
  final bool profilePublic;
  final bool analyticsSharing;
  final bool biometricLock;
  final bool twoFactorEnabled;

  SettingsState copyWith({
    AppThemeMode? themeMode,
    bool? pushNotifications,
    bool? emailNotifications,
    bool? habitReminders,
    bool? taskReminders,
    bool? aiInsights,
    bool? profilePublic,
    bool? analyticsSharing,
    bool? biometricLock,
    bool? twoFactorEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      habitReminders: habitReminders ?? this.habitReminders,
      taskReminders: taskReminders ?? this.taskReminders,
      aiInsights: aiInsights ?? this.aiInsights,
      profilePublic: profilePublic ?? this.profilePublic,
      analyticsSharing: analyticsSharing ?? this.analyticsSharing,
      biometricLock: biometricLock ?? this.biometricLock,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  void setThemeMode(AppThemeMode mode) => state = state.copyWith(themeMode: mode);
  void togglePushNotifications(bool value) => state = state.copyWith(pushNotifications: value);
  void toggleEmailNotifications(bool value) => state = state.copyWith(emailNotifications: value);
  void toggleHabitReminders(bool value) => state = state.copyWith(habitReminders: value);
  void toggleTaskReminders(bool value) => state = state.copyWith(taskReminders: value);
  void toggleAiInsights(bool value) => state = state.copyWith(aiInsights: value);
  void toggleProfilePublic(bool value) => state = state.copyWith(profilePublic: value);
  void toggleAnalyticsSharing(bool value) => state = state.copyWith(analyticsSharing: value);
  void toggleBiometricLock(bool value) => state = state.copyWith(biometricLock: value);
  void toggleTwoFactor(bool value) => state = state.copyWith(twoFactorEnabled: value);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

/// Settings — elegant, simple, Apple-like (see core/theme/module_theme.dart:
/// deliberately monochrome gray identity, flatter 18px radius, "soft fades
/// only" motion — no slides or scales, unlike every other module). This
/// pass fixes the same class of hardcoded-light-palette bugs as the other
/// screens and adds the leading icon per row that "Beautiful grouped
/// settings... Icons" calls for — every toggle here previously had no
/// icon at all, only the Account section's static links did.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final appearance = ref.watch(appearanceProvider);
    final appearanceNotifier = ref.read(appearanceProvider.notifier);
    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;
    final motion = theme.motion;

    Widget section(int index, Widget child) {
      return child.animate(delay: (index * 50).ms).fadeIn(duration: motion.entranceDuration, curve: motion.entranceCurve);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: const Text('Settings'),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  section(
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Theme', icon: Icons.palette_outlined),
                        GlassCard(
                          useModuleTheme: true,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ...AppThemeMode.values.map((mode) {
                                final selected = settings.themeMode == mode;
                                return ListTile(
                                  leading: Icon(_themeIcon(mode)),
                                  title: Text(_themeLabel(mode)),
                                  trailing: selected ? Icon(Icons.check_rounded, color: theme.primary) : null,
                                  onTap: () => notifier.setThemeMode(mode),
                                );
                              }),
                              Divider(color: g.border, height: 1),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                                child: Row(
                                  children: [
                                    Expanded(child: Text('Accent Color', style: Theme.of(context).textTheme.labelLarge)),
                                    TextButton(
                                      onPressed: appearanceNotifier.reset,
                                      child: const Text('Reset'),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                child: Wrap(
                                  spacing: 14,
                                  runSpacing: 10,
                                  children: AccentPreset.values.map((preset) {
                                    final color = accentColorFor(preset, Theme.of(context).brightness);
                                    final selected = appearance.accent == preset;
                                    return GestureDetector(
                                      onTap: () => appearanceNotifier.setAccent(preset),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 150),
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: color,
                                              border: Border.all(
                                                color: selected ? g.textPrimary : Colors.transparent,
                                                width: 2.5,
                                              ),
                                            ),
                                            child: selected
                                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                                : null,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            accentLabel(preset),
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                  color: selected ? g.textPrimary : g.textMuted,
                                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                                child: Text('Font', style: Theme.of(context).textTheme.labelLarge),
                              ),
                              ...AppFontChoice.values.map((font) {
                                final selected = appearance.font == font;
                                return ListTile(
                                  title: Text(fontLabel(font), style: applyFont(font, Theme.of(context).textTheme).bodyLarge),
                                  trailing: selected ? Icon(Icons.check_rounded, color: theme.primary) : null,
                                  onTap: () => appearanceNotifier.setFont(font),
                                );
                              }),
                              Divider(color: g.border, height: 1),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                                child: Text('Presets', style: Theme.of(context).textTheme.labelLarge),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: appearancePresets.map((preset) {
                                    final isActive = appearance.accent == preset.accent && appearance.font == preset.font;
                                    return ChoiceChip(
                                      label: Text(preset.label),
                                      selected: isActive,
                                      onSelected: (_) => appearanceNotifier.applyPreset(preset),
                                      selectedColor: theme.primary.withValues(alpha: 0.22),
                                      labelStyle: TextStyle(color: isActive ? theme.primary : null, fontWeight: FontWeight.w600),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  section(
                    1,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Notifications', icon: Icons.notifications_outlined),
                        GlassCard(
                          useModuleTheme: true,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.notifications_outlined),
                                title: const Text('Push notifications'),
                                trailing: Switch.adaptive(
                                  value: settings.pushNotifications,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.togglePushNotifications,
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.mail_outline),
                                title: const Text('Email notifications'),
                                trailing: Switch.adaptive(
                                  value: settings.emailNotifications,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleEmailNotifications,
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.repeat),
                                title: const Text('Habit reminders'),
                                trailing: Switch.adaptive(
                                  value: settings.habitReminders,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleHabitReminders,
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.task_alt_outlined),
                                title: const Text('Task reminders'),
                                trailing: Switch.adaptive(
                                  value: settings.taskReminders,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleTaskReminders,
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.auto_awesome_outlined),
                                title: const Text('AI insights'),
                                trailing: Switch.adaptive(
                                  value: settings.aiInsights,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleAiInsights,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  section(
                    2,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Privacy', icon: Icons.shield_outlined),
                        GlassCard(
                          useModuleTheme: true,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.public),
                                title: const Text('Public profile'),
                                subtitle: const Text('Allow others to see your achievements'),
                                trailing: Switch.adaptive(
                                  value: settings.profilePublic,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleProfilePublic,
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.analytics_outlined),
                                title: const Text('Share analytics'),
                                subtitle: const Text('Help improve Goalzy with anonymous usage data'),
                                trailing: Switch.adaptive(
                                  value: settings.analyticsSharing,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleAnalyticsSharing,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  section(
                    3,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Security', icon: Icons.lock_outline),
                        GlassCard(
                          useModuleTheme: true,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.fingerprint),
                                title: const Text('Biometric lock'),
                                trailing: Switch.adaptive(
                                  value: settings.biometricLock,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleBiometricLock,
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.verified_user_outlined),
                                title: const Text('Two-factor authentication'),
                                trailing: Switch.adaptive(
                                  value: settings.twoFactorEnabled,
                                  activeThumbColor: theme.primary,
                                  onChanged: notifier.toggleTwoFactor,
                                ),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.key_outlined),
                                title: const Text('Change password'),
                                trailing: Icon(Icons.chevron_right, color: g.textMuted),
                                onTap: () => _showChangePasswordSheet(context, ref),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  section(
                    4,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Account', icon: Icons.person_outline),
                        GlassCard(
                          useModuleTheme: true,
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: const Text('Edit profile'),
                                trailing: Icon(Icons.chevron_right, color: g.textMuted),
                                onTap: () => context.push('${AppRoutes.home}/profile'),
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.workspace_premium_outlined),
                                title: const Text('Upgrade to Premium'),
                                trailing: Icon(Icons.chevron_right, color: g.textMuted),
                                onTap: () {},
                              ),
                              Divider(color: g.border, height: 1),
                              ListTile(
                                leading: const Icon(Icons.logout, color: AppColors.danger),
                                title: const Text('Sign out', style: TextStyle(color: AppColors.danger)),
                                onTap: () async {
                                  await ref.read(authStateProvider.notifier).signOut();
                                  if (context.mounted) context.go(AppRoutes.login);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(AppThemeMode mode) => switch (mode) {
        AppThemeMode.dark => 'Dark',
        AppThemeMode.light => 'Light (Default)',
        AppThemeMode.system => 'System',
      };

  IconData _themeIcon(AppThemeMode mode) => switch (mode) {
        AppThemeMode.dark => Icons.dark_mode_outlined,
        AppThemeMode.light => Icons.light_mode_outlined,
        AppThemeMode.system => Icons.settings_suggest_outlined,
      };
}

Future<void> _showChangePasswordSheet(BuildContext context, WidgetRef ref) async {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isSaving = false;
  String? error;

  try {
    await GlassModal.show(
      context,
      title: 'Change Password',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassInput(
                  controller: currentController,
                  label: 'Current Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v != null && v.isNotEmpty ? null : 'Required',
                ),
                const SizedBox(height: 16),
                GlassInput(
                  controller: newController,
                  label: 'New Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: 16),
                GlassInput(
                  controller: confirmController,
                  label: 'Confirm New Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v == newController.text ? null : 'Passwords do not match',
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                GlassButton(
                  label: 'Update Password',
                  expanded: true,
                  isLoading: isSaving,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setModalState(() {
                      isSaving = true;
                      error = null;
                    });
                    try {
                      await ref.read(authStateProvider.notifier).changePassword(
                            currentPassword: currentController.text,
                            newPassword: newController.text,
                          );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setModalState(() {
                        error = e.toString();
                        isSaving = false;
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  } finally {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }
}
