import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/stats_providers.dart';

class WeeklyStreak extends StatelessWidget {
  final List<DayStatus> days;

  const WeeklyStreak({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(days.length, (i) {
        final day = days[i];

        late final Color bgColor;
        late final Color fgColor;
        late final Widget child;

        if (day.isToday) {
          bgColor = AppColors.primary;
          fgColor = Colors.white;
          child = Text(
            day.weekdayLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          );
        } else if (day.isCompleted) {
          bgColor = AppColors.success;
          fgColor = Colors.white;
          child = const Icon(Icons.check_rounded, color: Colors.white, size: 18);
        } else {
          bgColor = AppColors.primary.withValues(alpha: 0.08);
          fgColor = AppColors.textSecondaryLight;
          child = Text(
            day.weekdayLabel,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          );
        }

        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: child),
            ).animate().scale(
              duration: 300.ms,
              delay: (i * 80).ms,
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 6),
            Text(
              '${day.date.day}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }
}
