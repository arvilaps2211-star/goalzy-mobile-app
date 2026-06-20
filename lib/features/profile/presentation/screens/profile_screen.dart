import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/gamification.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? MockData.user;
    final achievements = MockData.achievements;
    final analytics = MockData.analytics;

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
                title: const Text('Profile'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('${AppRoutes.home}/settings'),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ProfileHeader(user: user),
                    const SizedBox(height: 20),
                    _GamificationRow(user: user),
                    const SizedBox(height: 20),
                    Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    ...achievements.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AchievementTile(achievement: a),
                        )),
                    const SizedBox(height: 12),
                    Text('Streaks', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StreakCard(
                            label: 'Daily',
                            current: user.streakDays,
                            best: 21,
                            icon: Icons.local_fire_department,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StreakCard(
                            label: 'Habits',
                            current: MockData.habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b),
                            best: 30,
                            icon: Icons.repeat,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    GlassCard(
                      child: Column(
                        children: [
                          _StatRow(
                            label: 'Tasks completed (week)',
                            value: '${analytics.weeklyReport['tasksCompleted']}',
                          ),
                          const Divider(color: AppColors.glassBorder),
                          _StatRow(
                            label: 'Habits logged (week)',
                            value: '${analytics.weeklyReport['habitsLogged']}',
                          ),
                          const Divider(color: AppColors.glassBorder),
                          _StatRow(
                            label: 'Goals advanced (week)',
                            value: '${analytics.weeklyReport['goalsAdvanced']}',
                          ),
                          const Divider(color: AppColors.glassBorder),
                          _StatRow(
                            label: 'XP earned (week)',
                            value: '${analytics.weeklyReport['xpEarned']}',
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.surface.withValues(alpha: 0.5),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withValues(alpha: 0.3),
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: Theme.of(context).textTheme.headlineSmall),
                Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                if (user.isPremium)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Premium', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GamificationRow extends StatelessWidget {
  const _GamificationRow({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                ProgressRing(
                  progress: user.levelProgress,
                  size: 56,
                  child: Text('${user.level}', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 8),
                Text('Level ${user.level}', style: Theme.of(context).textTheme.labelMedium),
                Text('${user.xpToNextLevel} XP to next', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                const Icon(Icons.bolt, color: AppColors.warning, size: 32),
                const SizedBox(height: 8),
                Text('${user.xp}', style: Theme.of(context).textTheme.titleLarge),
                Text('Total XP', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                const Icon(Icons.monetization_on_outlined, color: AppColors.secondary, size: 32),
                const SizedBox(height: 8),
                Text('${user.credits}', style: Theme.of(context).textTheme.titleLarge),
                Text('Credits', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final tierColor = switch (achievement.tier) {
      AchievementTier.bronze => const Color(0xFFCD7F32),
      AchievementTier.silver => const Color(0xFFC0C0C0),
      AchievementTier.gold => const Color(0xFFFFD700),
      AchievementTier.platinum => AppColors.secondary,
    };

    return GlassCard(
      child: Opacity(
        opacity: achievement.isUnlocked ? 1 : 0.5,
        child: Row(
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.title, style: Theme.of(context).textTheme.titleSmall),
                  Text(achievement.description, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: tierColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                achievement.tier.name,
                style: TextStyle(fontSize: 10, color: tierColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.label,
    required this.current,
    required this.best,
    required this.icon,
  });

  final String label;
  final int current;
  final int best;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.warning),
          const SizedBox(height: 8),
          Text('$current days', style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text('Best: $best', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
