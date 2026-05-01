import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Estadísticas', style: theme.textTheme.displayMedium)
                  .animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              const SizedBox(height: 28),
              _buildStreakCard(context),
              const SizedBox(height: 20),
              _buildStatsGrid(context),
              const SizedBox(height: 24),
              Text('Racha semanal', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildWeekStreak(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.gradientWarm,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('🔥', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('0 días', style: theme.textTheme.displayMedium?.copyWith(
            color: Colors.white,
          )),
          const SizedBox(height: 4),
          Text('Racha actual', style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          )),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).scale();
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statItem(context, '✅', '0', 'Completadas')),
        const SizedBox(width: 12),
        Expanded(child: _statItem(context, '⭐', '0', 'XP Ganado')),
        const SizedBox(width: 12),
        Expanded(child: _statItem(context, '🏆', '1', 'Nivel')),
      ],
    );
  }

  Widget _statItem(BuildContext context, String icon, String value, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildWeekStreak(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final date = today.subtract(Duration(days: today.weekday - i - 1));
        final isToday = date.day == today.day && date.month == today.month && date.year == today.year;
        final isPast = date.isBefore(today);

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary
                    : isPast
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(weekdays[i],
                  style: TextStyle(
                    color: isToday ? Colors.white : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text('${date.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }
}
