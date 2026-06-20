import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

enum AppThemeMode { dark, light, system }

class SettingsState {
  const SettingsState({
    this.themeMode = AppThemeMode.dark,
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

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.surfaceGradient),
        child: SafeArea(
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
                    _SectionTitle(title: 'Theme'),
                    GlassCard(
                      child: Column(
                        children: AppThemeMode.values.map((mode) {
                          return RadioListTile<AppThemeMode>(
                            title: Text(_themeLabel(mode)),
                            value: mode,
                            groupValue: settings.themeMode,
                            activeColor: AppColors.primary,
                            onChanged: (v) {
                              if (v != null) notifier.setThemeMode(v);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(title: 'Notifications'),
                    GlassCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Push notifications'),
                            value: settings.pushNotifications,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.togglePushNotifications,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          SwitchListTile(
                            title: const Text('Email notifications'),
                            value: settings.emailNotifications,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleEmailNotifications,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          SwitchListTile(
                            title: const Text('Habit reminders'),
                            value: settings.habitReminders,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleHabitReminders,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          SwitchListTile(
                            title: const Text('Task reminders'),
                            value: settings.taskReminders,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleTaskReminders,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          SwitchListTile(
                            title: const Text('AI insights'),
                            value: settings.aiInsights,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleAiInsights,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(title: 'Privacy'),
                    GlassCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Public profile'),
                            subtitle: const Text('Allow others to see your achievements'),
                            value: settings.profilePublic,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleProfilePublic,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          SwitchListTile(
                            title: const Text('Share analytics'),
                            subtitle: const Text('Help improve Goalzy with anonymous usage data'),
                            value: settings.analyticsSharing,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleAnalyticsSharing,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(title: 'Security'),
                    GlassCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Biometric lock'),
                            value: settings.biometricLock,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleBiometricLock,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          SwitchListTile(
                            title: const Text('Two-factor authentication'),
                            value: settings.twoFactorEnabled,
                            activeThumbColor: AppColors.primary,
                            onChanged: notifier.toggleTwoFactor,
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          ListTile(
                            leading: const Icon(Icons.lock_outline),
                            title: const Text('Change password'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionTitle(title: 'Account'),
                    GlassCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: const Text('Edit profile'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('${AppRoutes.home}/profile'),
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
                          ListTile(
                            leading: const Icon(Icons.workspace_premium_outlined),
                            title: const Text('Upgrade to Premium'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {},
                          ),
                          const Divider(color: AppColors.glassBorder, height: 1),
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
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(AppThemeMode mode) => switch (mode) {
        AppThemeMode.dark => 'Dark (Default)',
        AppThemeMode.light => 'Light',
        AppThemeMode.system => 'System',
      };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
