import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/theme/module_theme_scope.dart';
import '../../../../core/utils/date_utils.dart' as goalzy_date;
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/gamification.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../../../shared/widgets/components/glass_card.dart';
import '../../../../shared/widgets/components/progress_ring.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

/// Profile — premium, personal, the user's journey (see
/// core/theme/module_theme.dart: near-white, minimal-texture backdrop).
/// This pass fixes the same class of hardcoded-light-palette bugs as the
/// other screens, adds a real "Journey" timeline and "Member since" line
/// using two entity fields (`UserProfile.createdAt`, `Achievement.
/// unlockedAt`) that already existed but were always null in the mock
/// data, and removes a fabricated number: the Daily streak card showed a
/// hardcoded "Best: 21" with no backing data anywhere — dropped rather
/// than invented, while the Habits streak card's "best" now comes from
/// the real `Habit.bestStreak` field it should have used all along.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider) ?? MockData.user;
    final achievements = MockData.achievements;
    final analytics = MockData.analytics;
    final bestHabitStreak = MockData.habits.isEmpty ? 0 : MockData.habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            if (!embedded)
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
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => context.push('${AppRoutes.home}/settings'),
                      ),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ProfileHeader(user: user),
                  const SizedBox(height: 20),
                  _GamificationRow(user: user),
                  const SizedBox(height: 20),
                  _JourneyTimeline(user: user, achievements: achievements),
                  const SizedBox(height: 20),
                  Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...List.generate(achievements.length, (i) {
                    final a = achievements[i];
                    final tile = Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AchievementTile(achievement: a),
                    );
                    return a.isUnlocked
                        ? tile.animate(delay: (i * 80).ms).fadeIn().scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack)
                        : tile.animate(delay: (i * 80).ms).fadeIn();
                  }),
                  const SizedBox(height: 12),
                  Text('Streaks', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StreakCard(
                          label: 'Daily',
                          current: user.streakDays,
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StreakCard(
                          label: 'Habits',
                          current: MockData.habits.isEmpty ? 0 : MockData.habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b),
                          best: bestHabitStreak,
                          icon: Icons.repeat,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('Statistics', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  GlassCard(
                    useModuleTheme: true,
                    child: Column(
                      children: [
                        _StatRow(label: 'Tasks completed (week)', value: '${analytics.weeklyReport['tasksCompleted']}'),
                        Divider(color: GoalzyColors.of(context).border),
                        _StatRow(label: 'Habits logged (week)', value: '${analytics.weeklyReport['habitsLogged']}'),
                        Divider(color: GoalzyColors.of(context).border),
                        _StatRow(label: 'Goals advanced (week)', value: '${analytics.weeklyReport['goalsAdvanced']}'),
                        Divider(color: GoalzyColors.of(context).border),
                        _StatRow(label: 'XP earned (week)', value: '${analytics.weeklyReport['xpEarned']}'),
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final theme = context.moduleTheme;
    final g = GoalzyColors.of(context);

    return GlassCard(
      useModuleTheme: true,
      gradient: LinearGradient(
        colors: [theme.primary.withValues(alpha: 0.12), g.surface.withValues(alpha: 0.5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.primary.withValues(alpha: 0.15),
            child: Text(
              user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: theme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.displayName, style: Theme.of(context).textTheme.headlineSmall),
                Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                if (user.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Member since ${goalzy_date.DateUtils.formatShort(user.createdAt!)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: g.textMuted),
                    ),
                  ),
                if (user.isPremium)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: theme.gradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Premium', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
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
            useModuleTheme: true,
            child: Column(
              children: [
                ProgressRing(
                  progress: user.levelProgress,
                  size: 56,
                  color: context.moduleTheme.primary,
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
            useModuleTheme: true,
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
            useModuleTheme: true,
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

/// A real chronological timeline — account creation plus each achievement
/// actually unlocked (by its own `unlockedAt` date) — rather than a
/// decorative placeholder. The brief's Profile section calls for a
/// "Journey Timeline"; this is the minimal honest version of it given
/// what data the app actually tracks.
class _JourneyTimeline extends StatelessWidget {
  const _JourneyTimeline({required this.user, required this.achievements});

  final UserProfile user;
  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final events = <(DateTime, String, IconData)>[
      if (user.createdAt != null) (user.createdAt!, 'Joined GOALZY', Icons.flag_circle_rounded),
      for (final a in achievements)
        if (a.isUnlocked && a.unlockedAt != null) (a.unlockedAt!, 'Unlocked "${a.title}"', Icons.emoji_events_rounded),
    ]..sort((x, y) => x.$1.compareTo(y.$1));

    if (events.isEmpty) return const SizedBox.shrink();

    final g = GoalzyColors.of(context);
    final theme = context.moduleTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journey', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GlassCard(
          useModuleTheme: true,
          child: Column(
            children: List.generate(events.length, (i) {
              final (date, title, icon) = events[i];
              final isLast = i == events.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: theme.primary.withValues(alpha: 0.12)),
                        child: Icon(icon, size: 16, color: theme.primary),
                      ),
                      if (!isLast) Container(width: 2, height: 32, color: g.border),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 6, bottom: isLast ? 0 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.bodyLarge),
                          Text(goalzy_date.DateUtils.formatShort(date), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
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
      useModuleTheme: true,
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
    this.best,
    required this.icon,
  });

  final String label;
  final int current;
  final int? best;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      useModuleTheme: true,
      child: Column(
        children: [
          Icon(icon, color: AppColors.warning),
          const SizedBox(height: 8),
          Text('$current days', style: Theme.of(context).textTheme.titleMedium),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          if (best != null) Text('Best: $best', style: Theme.of(context).textTheme.labelSmall),
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
