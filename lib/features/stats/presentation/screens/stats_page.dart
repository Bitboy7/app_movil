import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../pet/presentation/providers/pet_providers.dart';
import '../providers/stats_providers.dart';
import '../widgets/animated_stat_card.dart';
import '../widgets/category_bar_chart.dart';
import '../widgets/period_selector.dart';
import '../widgets/weekly_streak.dart';
import '../widgets/xp_progress_card.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final period = ref.watch(statsPeriodProvider);
    final pet = ref.watch(petProvider);
    final aggregates = ref.watch(statsAggregatesProvider);
    final streak = ref.watch(streakProvider);
    final weeklyDays = ref.watch(weeklyStatusProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu progreso',
                      style: theme.textTheme.displayMedium,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
                    const SizedBox(height: 16),
                    PeriodSelector(
                      selected: period,
                      onChanged:
                          (p) =>
                              ref.read(statsPeriodProvider.notifier).state = p,
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 20),
                    XpProgressCard(pet: pet),
                    const SizedBox(height: 20),
                    _buildStatsGrid(
                      context,
                      aggregates: aggregates,
                      streak: streak,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Por categoría',
                      style: theme.textTheme.titleLarge,
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    CategoryBarChart(
                      breakdown: aggregates.categoryBreakdown,
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Racha semanal',
                      style: theme.textTheme.titleLarge,
                    ).animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 16),
                    WeeklyStreak(days: weeklyDays),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required StatsAggregates aggregates,
    required int streak,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                value: '${aggregates.completedCount}',
                label: 'Completadas',
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(
                begin: 0.1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.bolt_rounded,
                color: AppColors.accent,
                value: '${aggregates.totalXp}',
                label: 'XP ganado',
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(
                begin: 0.1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.monetization_on_rounded,
                color: AppColors.warning,
                value: '${aggregates.totalCoins}',
                label: 'Monedas',
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(
                begin: 0.1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AnimatedStatCard(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.secondary,
                value: '$streak',
                label: 'Racha',
                gradient: AppColors.gradientWarm,
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(
                begin: 0.1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
